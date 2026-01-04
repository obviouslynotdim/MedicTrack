import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';

class AnalyticScreen extends StatelessWidget {
  final List<Medicine> medicines;
  const AnalyticScreen({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    int taken = medicines.where((m) => m.status == MedicineStatus.taken).length;
    double progress = medicines.isEmpty ? 0 : taken / medicines.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Behavior Analysis")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150, width: 150,
              child: CircularProgressIndicator(value: progress, strokeWidth: 12, backgroundColor: Colors.grey[200], color: Colors.teal),
            ),
            const SizedBox(height: 30),
            Text("${(progress * 100).toInt()}% Taken", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("User Compliance Rate"),
          ],
        ),
      ),
    );
  }
}