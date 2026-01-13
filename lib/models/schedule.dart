enum RepeatType { none, daily, weekly, monthly, custom }

class Schedule {
  final String id;
  final RepeatType repeatType;
  final DateTime startDate;
  final List<int>? weekdays; 
  List<DateTime>? customDates;
  final DateTime? endDate;

  Schedule({
    required this.id,
    required this.repeatType,
    required this.startDate,
    this.weekdays,
    this.customDates,
    this.endDate,
  });

  bool isActiveOn(DateTime day) {
  if (day.isBefore(startDate)) return false;

  if (endDate != null && day.isAfter(endDate!)) return false;

  switch (repeatType) {
    case RepeatType.daily:
      return true;
    case RepeatType.weekly:
      return weekdays?.contains(day.weekday) ?? false;
    case RepeatType.monthly:
      return day.day == startDate.day;
    case RepeatType.custom:
      return customDates?.any((d) =>
            d.year == day.year &&
            d.month == day.month &&
            d.day == day.day) ?? false;
    case RepeatType.none:
      return day.year == startDate.year &&
             day.month == startDate.month &&
             day.day == startDate.day;
  }
}

  Map<String, dynamic> toJson() => {
        'id': id,
        'repeatType': repeatType.index,
        'startDate': startDate.toIso8601String(),
        'weekdays': weekdays,
        'customDates': customDates?.map((d) => d.toIso8601String()).toList(),
        'endDate': endDate?.toIso8601String(),
      };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'],
        repeatType: RepeatType.values[json['repeatType']],
        startDate: DateTime.parse(json['startDate']),
        weekdays: json['weekdays']?.cast<int>(),
        customDates: (json['customDates'] as List?)
            ?.map((d) => DateTime.parse(d))
            .toList(),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      );
}
