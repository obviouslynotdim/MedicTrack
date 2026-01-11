import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/medicine_model.dart';
import '../../../models/repeat_pattern.dart';

class HomeScreen extends StatefulWidget {
  final List<Medicine> medicines;
  final Function(String) onDelete;
  final Function(Medicine) onEdit;
  final Function(String) onTake;
  final VoidCallback onAddTap;

  const HomeScreen({
    super.key,
    required this.medicines,
    required this.onDelete,
    required this.onEdit,
    required this.onTake,
    required this.onAddTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  static const Color brandTeal = Color(0xFF2AAAAD);

  /// Helper: does this medicine occur on the selected day?
  bool _occursOnDay(Medicine m, DateTime day) {
    final DateTime start = DateTime(
      m.dateTime.year,
      m.dateTime.month,
      m.dateTime.day,
    );
    final DateTime d = DateTime(day.year, day.month, day.day);

    final end = m.schedule?.endDate == null
        ? null
        : DateTime(
            m.schedule!.endDate!.year,
            m.schedule!.endDate!.month,
            m.schedule!.endDate!.day,
          );

    if (d.isBefore(start)) return false;
    if (end != null && d.isAfter(end)) return false;

    switch (m.schedule?.repeatPattern) {
      case RepeatPattern.daily:
        return true;
      case RepeatPattern.weekly:
        return d.weekday == start.weekday;
      case RepeatPattern.monthly:
        return d.day == start.day;
      case RepeatPattern.none:
      default:
        return d == start;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    // Filter medicines by selected day using repeat logic
    final pending = widget.medicines.where((m) {
      return m.status == MedicineStatus.pending &&
          _occursOnDay(m, _selectedDay);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          const Text(
            "Welcome to MedicTracker!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            DateFormat('EEEE, d MMMM').format(_selectedDay),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          _buildWeeklyCalendar(),
          const SizedBox(height: 20),
          _buildBanner(),
          const SizedBox(height: 30),

          Text(
            "${DateFormat('EEEE').format(_selectedDay)}'s Schedule",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          pending.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final med = pending[index];
                    return _buildMedicineCard(med);
                  },
                ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final day = firstDayOfWeek.add(Duration(days: index));
          final bool isSelected = DateUtils.isSameDay(day, _selectedDay);

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(day), // Mon, Tue, etc.
                    style: TextStyle(
                      color: isSelected ? brandTeal : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? brandTeal : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: brandTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FORGETTING\nTO TAKE\nYOUR PILLS?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: widget.onAddTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Add Schedule"),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Image.asset('assets/user_home.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine med) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(med.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => widget.onDelete(med.id),
        child: GestureDetector(
          onTap: () => widget.onEdit(med),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brandTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/pill${med.iconIndex + 1}.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                med.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${DateFormat('MMM d').format(_selectedDay)} "
                "at ${DateFormat('hh:mm a').format(med.dateTime)}"
                " • ${med.schedule?.repeatPattern.name ?? 'once'}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline, color: brandTeal),
                onPressed: () => widget.onTake(med.id),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          "No medicines scheduled for this day.",
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
