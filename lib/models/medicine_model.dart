import 'dart:convert';
import 'schedule.dart';

enum MedicineStatus { pending, taken, missed }

class Medicine {
  final String id;
  final String name;
  final int iconIndex;
  final String amount;
  final String type;
  final DateTime dateTime;
  final bool isRemind;
  final String? comments;

  MedicineStatus status;
  Schedule? schedule;
  DateTime? lastTakenAt;

  Medicine({
    required this.id,
    required this.name,
    required this.iconIndex,
    required this.amount,
    required this.type,
    required this.dateTime,
    this.isRemind = true,
    this.comments,
    this.status = MedicineStatus.pending,
    this.schedule,
    this.lastTakenAt,
  });

  Medicine copyWith({
    DateTime? dateTime,
    MedicineStatus? status,
    Schedule? schedule,
    DateTime? lastTakenAt,
  }) {
    return Medicine(
      id: id,
      name: name,
      iconIndex: iconIndex,
      amount: amount,
      type: type,
      dateTime: dateTime ?? this.dateTime,
      isRemind: isRemind,
      comments: comments,
      status: status ?? this.status,
      schedule: schedule ?? this.schedule,
      lastTakenAt: lastTakenAt ?? this.lastTakenAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type,
        'dateTime': dateTime.toIso8601String(),
        'iconIndex': iconIndex,
        'isRemind': isRemind ? 1 : 0,
        'comments': comments,
        'status': status.index,
        'lastTakenAt': lastTakenAt?.toIso8601String(),
        'schedule': schedule != null ? jsonEncode(schedule!.toJson()) : null,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    final statusIndex = json['status'] is int
        ? json['status']
        : int.tryParse(json['status'].toString()) ?? 0;

    return Medicine(
      id: json['id'],
      name: json['name'],
      iconIndex: json['iconIndex'],
      amount: json['amount'],
      type: json['type'],
      dateTime: DateTime.parse(json['dateTime']),
      isRemind: json['isRemind'] == 1 || json['isRemind'] == true,
      comments: json['comments'],
      status: MedicineStatus.values[statusIndex],
      lastTakenAt: json['lastTakenAt'] != null
          ? DateTime.parse(json['lastTakenAt'])
          : null,
      schedule: json['schedule'] != null
          ? Schedule.fromJson(jsonDecode(json['schedule']))
          : null,
    );
  }
}

extension MedicineScheduleX on Medicine {
  bool isScheduledFor(DateTime day) {
    if (schedule == null) {
      return dateTime.year == day.year &&
          dateTime.month == day.month &&
          dateTime.day == day.day;
    }

    return schedule!.isActiveOn(day);
  }
}
