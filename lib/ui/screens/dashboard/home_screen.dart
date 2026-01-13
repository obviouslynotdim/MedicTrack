import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../models/medicine_model.dart';
import '../../../models/schedule.dart';
import '../../widgets/repeat_icon.dart';
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
  DateTime? _selectedDay; // NEW: track selected day

  @override
  Widget build(BuildContext context) {
    // Default: show today's pending medicines
    final pending = widget.medicines
        .where((m) => m.status == MedicineStatus.pending)
        .toList();

    // If a day is selected, filter medicines for that day
    final dayMeds = _selectedDay == null
        ? pending
        : widget.medicines
              .where((m) => m.isScheduledFor(_selectedDay!))
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
          if (_selectedDay != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Reset to Today",
              onPressed: () {
                setState(() {
                  _selectedDay = null;
                  _selectedFullCalendarDate = null;
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

          // Calendar
          _isCalendarExpanded
              ? _buildFullCalendar(brandTeal)
              : _buildWeeklyCalendar(brandTeal),

          const SizedBox(height: 20),
          _buildBanner(brandTeal),
          const SizedBox(height: 30),

          Text(
            _selectedDay == null
                ? "Today's Schedule"
                : "Schedule for ${DateFormat('dd MMM yyyy').format(_selectedDay!)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          dayMeds.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayMeds.length,
                  itemBuilder: (context, index) {
                    final med = dayMeds[index];
                    return _buildMedicineCard(context, med);
                  },
                ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Weekly Calendar
  Widget _buildWeeklyCalendar(Color brandColor) {
  final now = DateTime.now();
  final firstDay = now.subtract(Duration(days: now.weekday - 1));

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(7, (i) {
      final day = firstDay.add(Duration(days: i));
      final isToday =
          day.day == now.day && day.month == now.month && day.year == now.year;

      final hasMeds = widget.medicines.any(
        (m) => m.schedule?.isActiveOn(day) ?? false,
      );

      return GestureDetector(
        onTap: () {
          setState(() {
            if (isToday) {
              _selectedDay = null;
              _selectedFullCalendarDate = null;
            } else {
              _selectedDay = day;
              _selectedFullCalendarDate = day;
            }
          });
        },
        child: Column(
          children: [
            Text(
              DateFormat('E').format(day)[0], // M T W T F S S
              style: TextStyle(
                color: isToday ? brandColor : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
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
                    ),
                  ),
                ),
                if (hasMeds)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }),
  );
}


  // Full Calendar
  Widget _buildFullCalendar(Color brandColor) {
    final now = DateTime.now();
    final year = now.year;
    DateTime displayedMonth = _selectedFullCalendarDate ?? now;

    Color getStatusColor(DateTime date) {
      final medsForDay = widget.medicines.where((m) {
        if (m.schedule == null) {
          return m.dateTime.year == date.year &&
              m.dateTime.month == date.month &&
              m.dateTime.day == date.day;
        } else {
          return m.schedule!.isActiveOn(date);
        }
      }).toList();

      if (medsForDay.isEmpty) return Colors.transparent;
      if (medsForDay.any((m) => m.status == MedicineStatus.missed)) {
        return Colors.red.withOpacity(0.5);
      } else if (medsForDay.any((m) => m.status == MedicineStatus.pending)) {
        return Colors.orange.withOpacity(0.5);
      } else if (medsForDay.every((m) => m.status == MedicineStatus.taken)) {
        return Colors.green.withOpacity(0.5);
      }
      return Colors.transparent;
    }

    Widget buildLegendDot(Color color, String label) {
      return Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
    }

    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  displayedMonth = DateTime(
                    displayedMonth.year,
                    displayedMonth.month - 1,
                    1,
                  );
                  _selectedFullCalendarDate = displayedMonth;
                });
              },
            ),
            DropdownButton<int>(
              value: displayedMonth.month,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                    DateFormat.MMMM().format(DateTime(year, index + 1)),
                  ),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    displayedMonth = DateTime(year, val, 1);
                    _selectedFullCalendarDate = displayedMonth;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  displayedMonth = DateTime(
                    displayedMonth.year,
                    displayedMonth.month + 1,
                    1,
                  );
                  _selectedFullCalendarDate = displayedMonth;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DateUtils.getDaysInMonth(
            displayedMonth.year,
            displayedMonth.month,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, dayIndex) {
            final day = dayIndex + 1;
            final dayDate = DateTime(
              displayedMonth.year,
              displayedMonth.month,
              day,
            );

            final isToday =
                dayDate.day == now.day &&
                dayDate.month == now.month &&
                dayDate.year == now.year;

            final isSelected =
                _selectedFullCalendarDate != null &&
                dayDate.year == _selectedFullCalendarDate!.year &&
                dayDate.month == _selectedFullCalendarDate!.month &&
                dayDate.day == _selectedFullCalendarDate!.day;

            final dayColor = getStatusColor(dayDate);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFullCalendarDate = dayDate;
                  final now = DateTime.now();
                  if (dayDate.year == now.year &&
                      dayDate.month == now.month &&
                      dayDate.day == now.day) {
                    _selectedDay = null;
                  } else {
                    _selectedDay = dayDate;
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? brandColor
                      : isToday
                      ? brandColor.withOpacity(0.7)
                      : dayColor,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isSelected || isToday
                        ? Colors.white
                        : dayColor != Colors.transparent
                        ? Colors.black
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildLegendDot(Colors.red, "Missed"),
            buildLegendDot(Colors.orange, "Pending"),
            buildLegendDot(Colors.green, "Completed"),
          ],
        ),
        const SizedBox(height: 8),
      ],
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
                    onPressed: () async {
  final med = await showModalBottomSheet<Medicine>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddScheduleScreen(preselectedDate: _selectedDay ?? DateTime.now()),
  );

  if (med != null) {
    setState(() {
      widget.onEdit(med); 
    });
  }
},
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

  // Empty State
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
              subtitle: Row(
                children: [
                  Text(
                    "${getDateText(med.dateTime)} at ${DateFormat('hh:mm a').format(med.dateTime)}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  if (med.schedule != null)
                    RepeatIcon(
                      schedule: med.schedule,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                ],
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

  // Repeat Picker
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
        startDate: newDateTime,
        customDates: [
          if (med.schedule?.customDates != null) ...med.schedule!.customDates!,
          picked,
        ],
      ),
    );

    widget.onEdit(updated);
  }
}
