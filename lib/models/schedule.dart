class Schedule {
  final String id;
  final String medicineId; 
  final String repeatPattern;
  final DateTime? endDate;

  Schedule({
    required this.id,
    required this.medicineId,
    required this.repeatPattern,
    this.endDate,
  });

  DateTime getNextOccurrence(DateTime fromDate) {
    switch (repeatPattern.toLowerCase()) {
      case "daily":
        return fromDate.add(const Duration(days: 1));
      case "weekly":
        return fromDate.add(const Duration(days: 7));
      case "monthly":
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      default:
        return fromDate;
    }
  }

  @override
  String toString() {
    return "Schedule(id: $id, medicineId: $medicineId, repeat: $repeatPattern, endDate: $endDate)";
  }
}
