import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medicine_model.dart';

class HistoryScreen extends StatelessWidget {
  final List<Medicine> medicines;
  const HistoryScreen({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: medicines.isEmpty
          ? const Center(
              child: Text(
                "No history yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final med = medicines[index];
                return ListTile(
                  title: Text(med.name),
                  subtitle: Text(DateFormat('MM/dd hh:mm').format(med.dateTime)),
                  trailing: Text(
                    med.status.name.toUpperCase(),
                    style: TextStyle(
                      color: med.status == MedicineStatus.taken
                          ? Colors.teal
                          : Colors.orange,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
