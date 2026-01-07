import 'medicine_model.dart';

class HistoryEntry {
  String id;
  String medicineId;
  DateTime takenTime;
  MedicineStatus status;

  HistoryEntry({
    required this.id,
    required this.medicineId,
    required this.takenTime,
    required this.status,
  });

  @override
  String toString() {
    return "HistoryEntry(id: $id, medicineId: $medicineId, takenTime: $takenTime, status: $status)";
  }
}
