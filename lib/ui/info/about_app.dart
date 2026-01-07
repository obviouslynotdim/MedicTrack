import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "MedicTrack",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "MedicTrack helps you stay on top of your medication schedule "
              "by sending reminders and tracking your history.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Key Features:\n"
              "• Flexible medicine reminders\n"
              "• History tracking of taken/missed doses\n"
              "• Analysis page for progress\n"
              "• Customizable settings including Dark Mode",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Developed by Vathanak & Mony\n"
              "Cambodia Academy of Digital Technology (CADT)\n"
              "Version 1.0.0 — January 2026",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
