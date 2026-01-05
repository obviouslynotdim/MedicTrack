import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });


  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Brand Color
  final Color brandTeal = const Color(0xFF2AAAAD);

  // State variables for settings toggles
  bool _notificationsEnabled = true;
  // bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  double _volume = 0.7;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          _sectionHeader("General Settings"),
          
          _buildSwitchTile(
            Icons.notifications_active_outlined,
            "Enable Notifications",
            _notificationsEnabled,
            (v) => setState(() => _notificationsEnabled = v),
          ),
          
          _buildSwitchTile(
            Icons.dark_mode_outlined,
            "Dark Mode",
            widget.isDarkMode,
            widget.onDarkModeChanged,
          ),

          const Divider(height: 40),
          _sectionHeader("Sound & Reminders"),

          _buildSwitchTile(
            Icons.volume_up_outlined,
            "Sound Effects",
            _soundEnabled,
            (v) => setState(() => _soundEnabled = v),
          ),

          _buildSwitchTile(
            Icons.vibration,
            "Vibration",
            _vibrationEnabled,
            (v) => setState(() => _vibrationEnabled = v),
          ),

          // Volume Slider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Notification Volume", style: TextStyle(fontSize: 16)),
                Slider(
                  value: _volume,
                  activeColor: brandTeal,
                  // ignore: deprecated_member_use
                  inactiveColor: brandTeal.withOpacity(0.2),
                  onChanged: (v) => setState(() => _volume = v),
                ),
              ],
            ),
          ),

          // Time Picker Tile
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.access_time, color: brandTeal),
            title: const Text("Daily Reminder Time"),
            subtitle: Text(_reminderTime.format(context)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) {
                setState(() => _reminderTime = picked);
              }
            },
          ),

          const Divider(height: 40),
          _sectionHeader("Support"),

          _buildActionTile(Icons.help_outline, "Help & Support"),
          _buildActionTile(Icons.info_outline, "About App"),
          
          // Danger Zone
          _buildActionTile(
            Icons.delete_forever_outlined, 
            "Clear All Data", 
            textColor: Colors.red, 
            iconColor: Colors.red
          ),
          
          const SizedBox(height: 100), // Bottom padding for FAB clearance
        ],
      ),
    );
  }

  // header for sections
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // toggle tile builder
  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: brandTeal),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeThumbColor: brandTeal,
        onChanged: onChanged,
      ),
    );
  }

  // handler for Action Tiles
  Widget _buildActionTile(IconData icon, String title, {Color? textColor, Color? iconColor}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? brandTeal),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Handle tap
      },
    );
  }
}