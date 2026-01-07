import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & Support")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Welcome to Help & Support",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Here you can find answers to common questions:\n\n"
              "• How to add a reminder?\n"
              "Go to the Add Reminder screen and fill in the medicine details.\n\n"
              "• How to clear history?\n"
              "Use the Clear All Data option in Settings.\n\n"
              "• Need more help?\n"
              "Telegram: +855 66634389",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
