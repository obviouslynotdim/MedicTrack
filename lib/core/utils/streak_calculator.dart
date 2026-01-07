// Suggested location: lib/core/utils/streak_calculator.dart

import '../../models/medicine_model.dart';

class StreakCalculator {
  static int calculateStreak(List<Medicine> medicines) {
    if (medicines.isEmpty) return 0;

    // Group medicines by date (ignoring time)
    Map<DateTime, List<Medicine>> grouped = {};
    for (var med in medicines) {
      DateTime dateOnly = DateTime(med.dateTime.year, med.dateTime.month, med.dateTime.day);
      grouped.putIfAbsent(dateOnly, () => []).add(med);
    }

    // Get sorted list of dates in descending order (newest first)
    List<DateTime> sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (int i = 0; i < sortedDates.length; i++) {
      DateTime currentDay = sortedDates[i];
      List<Medicine> dayMeds = grouped[currentDay]!;

      // Check if all medicines for this specific day were taken
      bool allTaken = dayMeds.every((m) => m.status == MedicineStatus.taken);

      if (allTaken) {
        streak++;
      } else {
        // If they missed one today, the streak might still be alive from yesterday
        // If they missed one on a previous day, the streak breaks.
        if (currentDay.isBefore(today)) break; 
      }
    }
    return streak;
  }
}