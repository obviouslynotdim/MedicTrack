import 'schedule.dart';

enum MedicineStatus { pending, taken, missed }

class Medicine {
  final String id;
  final String name;
  final String amount;
  final String type;
  final DateTime dateTime;
  final int iconIndex;
  final bool isRemind;
  final String? comments;
  final MedicineStatus status;
  final Schedule? schedule;

  Medicine({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.dateTime,
    required this.iconIndex,
    required this.isRemind,
    required this.comments,
    required this.status,
    required this.schedule,
  });

 Medicine copyWith({
  String? id,
  String? name,
  String? amount,
  String? type,
  DateTime? dateTime,
  int? iconIndex,
  bool? isRemind,
  String? comments,
  MedicineStatus? status,
  Schedule? schedule,
}) {
  return Medicine(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    dateTime: dateTime ?? this.dateTime,
    iconIndex: iconIndex ?? this.iconIndex,
    isRemind: isRemind ?? this.isRemind,
    comments: comments ?? this.comments,
    status: status ?? this.status,
    schedule: schedule ?? this.schedule,
  );
}



  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      type: json['type'],
      dateTime: DateTime.parse(json['dateTime']),
      iconIndex: json['iconIndex'],
      isRemind: json['isRemind'] == true || json['isRemind'] == 1,
      comments: json['comments'],
      status: MedicineStatus.values[json['status']],
      schedule: json['schedule'] != null
          ? Schedule.fromJson(json['schedule'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'iconIndex': iconIndex,
      'isRemind': isRemind,
      'comments': comments,
      'status': status.index,
      'schedule': schedule?.toJson(),
    };
  }
}
