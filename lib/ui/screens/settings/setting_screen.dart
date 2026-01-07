import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _notifsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.7;
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    
    widget.onSettingsChanged(); // Notify MainScreen to re-apply
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitchTile("Enable Notifications", _notifsEnabled, (v) {
            setState(() => _notifsEnabled = v);
            _updateSetting('notificationsEnabled', v);
          }),
          _buildSwitchTile("Dark Mode", widget.isDarkMode, widget.onDarkModeChanged),
          const Divider(),
          _buildSwitchTile("Sound", _soundEnabled, (v) {
            setState(() => _soundEnabled = v);
            _updateSetting('soundEnabled', v);
          }),
          _buildSwitchTile("Vibration", _vibrationEnabled, (v) {
            setState(() => _vibrationEnabled = v);
            _updateSetting('vibrationEnabled', v);
          }),
          const Text("Volume"),
          Slider(
            value: _volume,
            onChanged: (v) => setState(() => _volume = v),
            onChangeEnd: (v) => _updateSetting('volume', v), // Only save when let go
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Clear All Data", style: TextStyle(color: Colors.red)),
            onTap: widget.onClearData,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool val, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: val,
      activeThumbColor: brandTeal,
      onChanged: onChanged,
    );
  }
}