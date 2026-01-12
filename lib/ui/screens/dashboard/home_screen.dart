import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../models/medicine_model.dart';
import '../../../models/schedule.dart';
import '../schedule/add_schedule_screen.dart';

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
  bool _isCalendarExpanded = false;
  DateTime? _selectedFullCalendarDate;

  @override
  Widget build(BuildContext context) {
    final pending = widget.medicines
        .where((m) => m.status == MedicineStatus.pending)
        .toList();

    const Color brandTeal = Color(0xFF2AAAAD);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: Icon(
              _isCalendarExpanded ? Icons.view_week : Icons.calendar_today,
            ),
            onPressed: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
          ),
        ],
      ),
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
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          _isCalendarExpanded
              ? _buildFullCalendar(brandTeal)
              : _buildWeeklyCalendar(brandTeal),

          const SizedBox(height: 20),
          _buildBanner(brandTeal),
          const SizedBox(height: 30),

          const Text(
            "Today's Schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    return _buildMedicineCard(context, med);
                  },
                ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // weekly calender
  Widget _buildWeeklyCalendar(Color brandColor) {
    final now = DateTime.now();
    final firstDay = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = firstDay.add(Duration(days: i));
        final isToday =
            day.day == now.day &&
            day.month == now.month &&
            day.year == now.year;

        return Column(
          children: [
            Text(
              DateFormat('E').format(day)[0],
              style: TextStyle(
                color: isToday ? brandColor : Colors.grey,
                fontWeight: FontWeight.bold,
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
                style: TextStyle(color: isToday ? Colors.white : Colors.black),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Calender
  Widget _buildFullCalendar(Color brandColor) {
  final now = DateTime.now();
  final year = now.year;

  return Column(
    children: List.generate(12, (monthIndex) {
      final month = monthIndex + 1;
      final daysInMonth = DateUtils.getDaysInMonth(year, month);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.MMMM().format(DateTime(year, month)),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: brandColor),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, dayIndex) {
                final day = dayIndex + 1;
                final dayDate = DateTime(year, month, day);

                // Check if any medicine is scheduled on this day
                final hasMedicine = widget.medicines.any((med) =>
                    med.schedule != null && med.schedule!.isActiveOn(dayDate));

                final isToday = dayDate.day == now.day &&
                    dayDate.month == now.month &&
                    dayDate.year == now.year;

                final isSelected = _selectedFullCalendarDate != null &&
                    dayDate.year == _selectedFullCalendarDate!.year &&
                    dayDate.month == _selectedFullCalendarDate!.month &&
                    dayDate.day == _selectedFullCalendarDate!.day;

                return GestureDetector(
                  onTap: () async {
                    // Set selected date
                    setState(() => _selectedFullCalendarDate = dayDate);

                    // Open AddScheduleScreen with selected date
                    final newMedicine = await showModalBottomSheet<Medicine>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddScheduleScreen(
                        preselectedDate: dayDate,
                      ),
                    );

                    if (newMedicine != null) {
                      widget.onEdit(newMedicine); // reuse existing edit callback
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? brandColor
                          : isToday
                              ? brandColor.withOpacity(0.7)
                              : hasMedicine
                                  ? brandColor.withOpacity(0.3)
                                  : Colors.transparent,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? Colors.white
                                : hasMedicine
                                    ? Colors.black
                                    : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }),
  );
}

  // Banner
  Widget _buildBanner(Color brandColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        width: double.infinity,
        color: brandColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
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
                  const Spacer(),
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
              child: SizedBox(
                width: 140,
                child: Image.asset('assets/user_home.png', fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          "No medicines for now.",
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  // Medicine Card
  Widget _buildMedicineCard(BuildContext context, Medicine med) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: Key(med.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => openRepeatPicker(context, med),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.repeat,
              label: 'Repeat',
            ),
            SlidableAction(
              onPressed: (_) => widget.onDelete(med.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => widget.onEdit(med),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2AAAAD).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/pill${med.iconIndex + 1}.png',
                  width: 30,
                  height: 30,
                ),
              ),
              title: Text(
                med.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${getDateText(med.dateTime)} at ${DateFormat('hh:mm a').format(med.dateTime)}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF2AAAAD),
                ),
                onPressed: () => widget.onTake(med.id),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getDateText(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Today";
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  // Reepat Picker
  Future<void> openRepeatPicker(BuildContext context, Medicine med) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    final newDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      med.dateTime.hour,
      med.dateTime.minute,
    );

    final updated = Medicine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: med.name,
      iconIndex: med.iconIndex,
      amount: med.amount,
      type: med.type,
      dateTime: newDateTime,
      isRemind: med.isRemind,
      comments: med.comments,
      status: med.status,
      lastTakenAt: med.lastTakenAt,
      schedule: Schedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        repeatType: RepeatType.custom,
        customDates: [...?med.schedule?.customDates, picked],
      ),
    );

    widget.onEdit(updated);
  }
}
