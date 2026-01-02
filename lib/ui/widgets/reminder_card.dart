import 'package:flutter/material.dart';
import '../../models/medicine.dart';

class ReminderCard extends StatelessWidget {
  final Medicine medicine;

  const ReminderCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: const Icon(Icons.medication),
        title: Text(medicine.name),
        subtitle: Text(medicine.time),
        trailing: Switch(
          value: medicine.taken,
          onChanged: (value) {},
        ),
      ),
    );
  }
}
