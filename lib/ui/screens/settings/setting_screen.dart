import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_service.dart';
import '../../info/about_app.dart';
import '../../info/help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onClearData;
  final VoidCallback onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onClearData,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color brandTeal = const Color(0xFF2AAAAD);
  final NotificationService _notifications = NotificationService();

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.7;

      final hour = prefs.getInt('reminderHour') ?? 9;
      final minute = prefs.getInt('reminderMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  // Save preferences and apply to NotificationService
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setDouble('volume', _volume);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);

    _notifications.applyGlobalSettings(
      enableNotifications: _notificationsEnabled,
      sound: _soundEnabled,
      vibration: _vibrationEnabled,
      volume: _volume,
      dailyReminderTime: _reminderTime,
    );

    // Notify parent to re-schedule notifications
    widget.onSettingsChanged();
  }

  // Add this dialog helper in _SettingsScreenState
void _showDeleteConfirmation() {
  showDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) => AlertDialog(
      title: const Text("Clear All Data?"),
      content: const Text("This will delete all your schedules and history. This action cannot be undone."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            widget.onClearData();   // Trigger the logic in MainScreen
          },
          child: const Text("Clear Everything", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            (v) => setState(() {
              _notificationsEnabled = v;
              _saveSettings();
            }),
          ),
          _buildSwitchTile(
            Icons.dark_mode_outlined,
            "Dark Mode",
            widget.isDarkMode,
            (v) => widget.onDarkModeChanged(v),
          ),
          const Divider(height: 40),
          _sectionHeader("Sound & Reminders"),
          _buildSwitchTile(
            Icons.volume_up_outlined,
            "Sound Effects",
            _soundEnabled,
            (v) => setState(() {
              _soundEnabled = v;
              _saveSettings();
            }),
          ),
          _buildSwitchTile(
            Icons.vibration,
            "Vibration",
            _vibrationEnabled,
            (v) => setState(() {
              _vibrationEnabled = v;
              _saveSettings();
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Notification Volume",
                  style: TextStyle(fontSize: 16),
                ),
                Slider(
                  value: _volume,
                  activeColor: brandTeal,
                  inactiveColor: brandTeal.withOpacity(0.2),
                  onChanged: (v) => setState(() {
                    _volume = v;
                    _saveSettings();
                  }),
                ),
              ],
            ),
          ),
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
                setState(() {
                  _reminderTime = picked;
                  _saveSettings();
                });
              }
            },
          ),
          const Divider(height: 40),
          _sectionHeader("Support"),
          _buildActionTile(
            Icons.help_outline,
            "Help & Support",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _buildActionTile(
            Icons.info_outline,
            "About App",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
          _buildActionTile(
            Icons.delete_forever_outlined,
            "Clear All Data",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () =>
                _showDeleteConfirmation(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
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

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: brandTeal),
    title: Text(title),
    trailing: Switch(
      value: value,
      activeThumbColor: brandTeal,
      onChanged: onChanged,
    ),
  );

  Widget _buildActionTile(
    IconData icon,
    String title, {
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: iconColor ?? brandTeal),
    title: Text(title, style: TextStyle(color: textColor)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  );
}
