import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A2530),
        title: const Text("Medicine History", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.check_circle, color: Color(0xFF2AAAAD)),
          title: Text("Medicine Name ${index + 1}"),
          subtitle: const Text("Taken at 09:00 AM"),
          trailing: const Text("Yesterday", style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}