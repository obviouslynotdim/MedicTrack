// lib/ui/screens/dashboard/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/medicine_model.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final pending = medicines
        .where((m) => m.status == MedicineStatus.pending)
        .toList();
    const Color brandTeal = Color(0xFF2AAAAD);

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
            DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // WEEKLY CALENDAR STRIP
          _buildWeeklyCalendar(brandTeal),
          const SizedBox(height: 20),

          // REMINDER BANNER
          _buildBanner(brandTeal),

          const SizedBox(height: 30),

          // SECTION HEADER
          const Text(
            "Today's Schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // 5. MEDICINE LIST
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

  // --- WIDGET: WEEKLY CALENDAR ---
  Widget _buildWeeklyCalendar(Color brandColor) {
    final now = DateTime.now();
    // Calculate the start of the current week (Monday)
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = firstDayOfWeek.add(Duration(days: index));
        final bool isToday = day.day == now.day && day.month == now.month;

        return Column(
          children: [
            Text(
              DateFormat('E').format(day)[0], // M, T, W...
              style: TextStyle(
                color: isToday ? brandColor : Colors.grey,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isToday ? brandColor : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday
                    ? null
                    : Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- WIDGET: BANNER ---
  Widget _buildBanner(Color brandColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: brandColor,
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
                  onPressed: onAddTap,
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

  // ... (Keep your existing _buildMedicineCard and _buildEmptyState methods)
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
        onDismissed: (_) => onDelete(med.id),
        child: GestureDetector(
          onTap: () => onEdit(med),
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
                  color: const Color(0xFF2AAAAD).withValues(alpha: 0.1),
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
                // Check if it's today
                "${med.dateTime.day == DateTime.now().day && med.dateTime.month == DateTime.now().month ? 'Today' : DateFormat('MMM d').format(med.dateTime)} "
                "at ${DateFormat('hh:mm a').format(med.dateTime)}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF2AAAAD),
                ),
                onPressed: () => onTake(med.id),
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
          "No medicines for now.",
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
