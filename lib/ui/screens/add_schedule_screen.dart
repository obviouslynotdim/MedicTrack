import 'package:flutter/material.dart';

class AddScheduleScreen extends StatelessWidget {
  const AddScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Content defines the height
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Add New Schedule",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          
          // Placeholder for your form fields
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text("Medicine Form will go here"),
            ),
          ),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Save Schedule", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}