import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/medicine_model.dart';
import '../../../models/history_entry.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryEntry> history;
  final List<Medicine> medicines;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    final mergedList = <HistoryEntry>[];

    mergedList.addAll(history);

    for (var med in medicines) {
      final existsInHistory =
          history.any((h) => h.medicineId == med.id);
      if (!existsInHistory) {
        mergedList.add(
          HistoryEntry(
            id: UniqueKey().toString(),
            medicineId: med.id,
            takenTime: med.dateTime,
            status: MedicineStatus.pending,
          ),
        );
      }
    }

    mergedList.sort((a, b) => b.takenTime.compareTo(a.takenTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine History"),
      ),
      body: mergedList.isEmpty
          ? const Center(
              child: Text(
                "No history yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mergedList.length,
              itemBuilder: (context, index) {
                final entry = mergedList[index];

                // Find medicine details
                final med = medicines.firstWhere(
                  (m) => m.id == entry.medicineId,
                  orElse: () => Medicine(
                    id: '0',
                    name: 'Unknown',
                    iconIndex: 0,
                    amount: '',
                    type: '',
                    dateTime: DateTime.now(),
                    isRemind: false,
                    status: MedicineStatus.pending,
                  ),
                );

                return HistoryCard(entry: entry, medicine: med);
              },
            ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final Medicine medicine;

  const HistoryCard({
    super.key,
    required this.entry,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final med = medicine;
    final takenTime = entry.takenTime;

    Color statusColor;
    switch (entry.status) {
      case MedicineStatus.taken:
        statusColor = Colors.teal;
        break;
      case MedicineStatus.missed:
        statusColor = Colors.red;
        break;
      case MedicineStatus.pending:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/pill${med.iconIndex + 1}.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            med.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.status.name.toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    _buildDetailRow("Amount:", med.amount),
                    _buildDetailRow("Type:", med.type),
                    _buildDetailRow(
                      "Taken at:",
                      DateFormat('dd MMM yyyy • HH:mm').format(takenTime),
                    ),
                    _buildDetailRow("Remind:", med.isRemind ? "Yes" : "No"),
                    const SizedBox(height: 8),
                    Text(
                      "Notes:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      med.comments ?? "No notes available.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/pill${med.iconIndex + 1}.png',
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy • HH:mm').format(takenTime),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
