import 'schedule.dart';
import 'medicine_base.dart';

enum MedicineStatus { pending, taken, missed }

class Medicine extends MedicineBase {
  final String amount;
  final String type;
  final DateTime dateTime;
  final bool isRemind;
  final String? comments;
  MedicineStatus status;
  Schedule? schedule;
  DateTime? lastTakenAt;

  Medicine({
    required super.id,
    required super.name,
    required super.iconIndex,
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

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'],
    name: json['name'],
    iconIndex: json['iconIndex'],
    amount: json['amount'],
    type: json['type'],
    dateTime: DateTime.parse(json['dateTime']),
    isRemind: json['isRemind'] == 1 || json['isRemind'] == true,
    comments: json['comments'],
    status: MedicineStatus.values[json['status'] ?? 0],
  );
}
