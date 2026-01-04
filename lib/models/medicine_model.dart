enum MedicineStatus { pending, taken, missed }

class Medicine {
  String id;
  String name;
  String amount;
  String type;
  DateTime dateTime;
  int iconIndex; 
  bool isRemind;
  MedicineStatus status;

  Medicine({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.dateTime,
    required this.iconIndex,
    this.isRemind = true,
    this.status = MedicineStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'type': type,
    'dateTime': dateTime.toIso8601String(),
    'iconIndex': iconIndex,
    'isRemind': isRemind,
    'status': status.index, // store enum as index
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'],
    name: json['name'],
    amount: json['amount'],
    type: json['type'],
    dateTime: DateTime.parse(json['dateTime']),
    iconIndex: json['iconIndex'],
    isRemind: json['isRemind'],
    status: MedicineStatus.values[json['status']],
  );
}