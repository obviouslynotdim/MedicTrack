import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A2530),
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(Icons.notifications_active_outlined, "Notifications", true),
          _buildSettingsTile(Icons.dark_mode_outlined, "Dark Mode", false),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF2AAAAD)),
            title: const Text("Help & Support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF2AAAAD)),
            title: const Text("About App"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, bool value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2AAAAD)),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: const Color(0xFF2AAAAD),
        onChanged: (bool newValue) {},
      ),
    );
  }
}