import 'schedule.dart';

enum MedicineStatus { pending, taken, missed }

class Medicine {
  final String amount;
  final String type;
  final DateTime dateTime;
  final bool isRemind;
  final String? comments;
  MedicineStatus status;
  Schedule? schedule;
  DateTime? lastTakenAt;
  final String id;
  final String name;
  final int iconIndex;

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
  };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    int statusIndex;

    if (json['status'] is String) {
      statusIndex = int.tryParse(json['status']) ?? 0;
    } else if (json['status'] is int) {
      statusIndex = json['status'];
    } else {
      statusIndex = 0;
    }

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
    );
  }
}
