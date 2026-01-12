import 'medicine_model.dart';

class HistoryEntry {
  final String id;
  final String medicineId;
  final DateTime takenTime;
  final MedicineStatus status;

  HistoryEntry({
    required this.id,
    required this.medicineId,
    required this.takenTime,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'takenTime': takenTime.toIso8601String(),
      'status': status.index,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
  int statusIndex;

  if (json['status'] is String) {
    statusIndex = int.parse(json['status']);
  } else if (json['status'] is int) {
    statusIndex = json['status'];
  } else {
    statusIndex = 0; 
  }

  return HistoryEntry(
    id: json['id'],
    medicineId: json['medicineId'],
    takenTime: DateTime.parse(json['takenTime']),
    status: MedicineStatus.values[statusIndex],
  );
}

  @override
  String toString() {
    return "HistoryEntry(id: $id, medicineId: $medicineId, takenTime: $takenTime, status: $status)";
  }
}