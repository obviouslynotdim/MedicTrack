import 'repeat_pattern.dart';

class Schedule {
  final String id;
  final String medicineId;
  final RepeatPattern repeatPattern;
  final DateTime? endDate;

  Schedule({
    required this.id,
    required this.medicineId,
    required this.repeatPattern,
    required this.endDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      medicineId: json['medicineId'],
      repeatPattern: RepeatPattern.fromString(json['repeatPattern']),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'repeatPattern': repeatPattern.name,
      'endDate': endDate?.toIso8601String(),
    };
  }
}
