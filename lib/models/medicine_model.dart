enum MedicineStatus { pending, taken, missed }

class Medicine {
  String id;
  String name;
  String amount;
  String type;
  DateTime dateTime;
  int iconIndex;
  bool isRemind;
  String? comments;
  MedicineStatus status;

  DateTime? lastTakenAt;

  Medicine({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.dateTime,
    required this.iconIndex,
    this.isRemind = true,
    this.comments,
    this.status = MedicineStatus.pending,
    this.lastTakenAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'type': type,
        'dateTime': dateTime.toIso8601String(),
        'iconIndex': iconIndex,
        'isRemind': isRemind ? 1 : 0, // SQLite prefers integers for booleans
        'comments': comments,
        'status': status.index,
        'lastTakenAt': lastTakenAt?.toIso8601String(),
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        type: json['type'],
        dateTime: DateTime.parse(json['dateTime']),
        iconIndex: json['iconIndex'],
        isRemind: json['isRemind'] == 1 || json['isRemind'] == true,
        comments: json['comments'],
        status: MedicineStatus.values[json['status'] ?? 0],
        lastTakenAt: json['lastTakenAt'] != null
            ? DateTime.parse(json['lastTakenAt'])
            : null,
      );
}
