import 'package:flutter/material.dart';

class AnalyticScreen extends StatelessWidget {
  const AnalyticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A2530),
        title: const Text("Health Monitoring", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF83CFD1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics, color: Color(0xFF2AAAAD), size: 40),
                  SizedBox(width: 16),
                  Text(
                    "Weekly Progress: 85%",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2AAAAD)),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(child: Text("Analytics charts will appear here")),
            ),
          ],
        ),
      ),
    );
  }
}