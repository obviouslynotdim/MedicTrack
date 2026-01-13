enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  custom,
}

class Schedule {
  final String id;
  final RepeatType repeatType;
  final List<int>? weekdays;
  final List<DateTime>? customDates;
  final DateTime? endDate;

  Schedule({
    required this.id,
    required this.repeatType,
    this.weekdays,
    this.customDates,
    this.endDate,
  });

  bool isActiveOn(DateTime day) {
    if (endDate != null && day.isAfter(endDate!)) return false;

    switch (repeatType) {
      case RepeatType.daily:
        return true;

      case RepeatType.weekly:
        return weekdays?.contains(day.weekday) ?? false;

      case RepeatType.monthly:
        return true;

      case RepeatType.custom:
        return customDates?.any((d) =>
              d.year == day.year &&
              d.month == day.month &&
              d.day == day.day) ??
            false;

      case RepeatType.none:
        return false;
    }
  }
}