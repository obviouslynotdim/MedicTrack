// lib/ui/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/analytic_screen.dart';
import 'schedule/history_screen.dart';
import 'settings/setting_screen.dart';
import 'schedule/add_schedule_screen.dart';
import '../../models/medicine_model.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Medicine> medicineList = [];

  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();

  // Global settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _notifications.init();
    await _loadSettings();
    await _loadData();
  }

  // Separate data loading to allow refreshing
  Future<void> _loadData() async {
    final data = await _storage.loadMedicines();
    setState(() {
      medicineList = data;
    });

    // Check for any medicines that were missed while the app was closed
    _checkMissedMedicines();

    for (var med in medicineList) {
      if (med.isRemind && med.status == MedicineStatus.pending) {
        await _notifications.scheduleNotification(med);
      }
    }
  }

  // FIX: Logic to change "Pending" to "Missed" automatically if time has passed
  void _checkMissedMedicines() {
    bool updated = false;
    final now = DateTime.now();

    for (var med in medicineList) {
      // If status is pending but the scheduled time is in the past (e.g., 5 mins ago)
      if (med.status == MedicineStatus.pending &&
          med.dateTime.add(const Duration(minutes: 5)).isBefore(now)) {
        med.status = MedicineStatus.missed;
        _storage.updateMedicine(med); // Update database
        updated = true;
      }
    }

    if (updated) {
      setState(() {}); // Refresh UI
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.7;
      _dailyReminderTime = TimeOfDay(
        hour: prefs.getInt('reminderHour') ?? 9,
        minute: prefs.getInt('reminderMinute') ?? 0,
      );
    });
    _applySettings();
  }

  void _applySettings() {
    _notifications.applyGlobalSettings(
      enableNotifications: _notificationsEnabled,
      sound: _soundEnabled,
      vibration: _vibrationEnabled,
      volume: _volume,
      dailyReminderTime: _dailyReminderTime,
    );

    // Re-schedule all pending notifications
    for (var med in medicineList) {
      if (med.isRemind && med.status == MedicineStatus.pending) {
        _notifications.scheduleNotification(med);
      }
    }
  }

  // --- CRUD Handlers ---
  void _onCreate() async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddScheduleScreen(),
    );

    if (result != null) {
      setState(() => medicineList.add(result));
      await _storage.addMedicine(result);
      if (result.isRemind) await _notifications.scheduleNotification(result);
    }
  }

  void _onDelete(String id) async {
    setState(() => medicineList.removeWhere((m) => m.id == id));
    await _storage.deleteMedicine(id);
    await _notifications.cancelNotification(id);
  }

  void _onEdit(Medicine existingMed) async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddScheduleScreen(medicine: existingMed),
    );

    if (result != null) {
      final idx = medicineList.indexWhere((m) => m.id == result.id);
      if (idx != -1) {
        setState(() => medicineList[idx] = result);
        await _storage.updateMedicine(result);

        if (result.isRemind) {
          await _notifications.scheduleNotification(result);
        } else {
          await _notifications.cancelNotification(result.id);
        }
      }
    }
  }

  void _onMarkAsTaken(String id) async {
    final idx = medicineList.indexWhere((m) => m.id == id);
    if (idx != -1) {
      medicineList[idx].status = MedicineStatus.taken;
      medicineList[idx].lastTakenAt = DateTime.now();
      await _storage.updateMedicine(medicineList[idx]);
      await _notifications.cancelNotification(id);
      setState(() {});
    }
  }

  // inside main_screen.dart
  Future<void> _handleClearAllData() async {
    // Delete from Database via StorageService
    await _storage.deleteAllMedicines();

    // Stop all scheduled notifications in the system tray
    await _notifications.cancelAllNotifications();

    // Update the UI state so the list empties immediately
    setState(() {
      medicineList = [];
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All data and alerts have been cleared!"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, 
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        medicines: medicineList,
        onDelete: _onDelete,
        onEdit: _onEdit,
        onTake: _onMarkAsTaken,
        onAddTap: _onCreate,
      ),
      AnalyticScreen(medicines: medicineList),
      HistoryScreen(medicines: medicineList),
      SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
        onClearData: _handleClearAllData,
        onSettingsChanged: _applySettings,
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.isDarkMode
          ? Colors.grey[900]
          : Colors.grey.shade100,
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreate,
        backgroundColor: const Color(0xFF2AAAAD),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 35, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Auto-check for missed meds whenever switching tabs
          _checkMissedMedicines();
        },
        onAddTap: _onCreate,
      ),
    );
  }
}
