import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/analytic_screen.dart';
import 'schedule/history_screen.dart';
import 'settings/setting_screen.dart';
import 'schedule/add_schedule_screen.dart';
import '../../models/medicine_model.dart';
import '../../models/history_entry.dart';
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
  List<HistoryEntry> historyList = [];

  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();

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

  Future<void> _loadData() async {
    final meds = await _storage.loadMedicines();
    final history = await _storage.loadHistory();

    setState(() {
      medicineList = meds;
      historyList = history;
    });

    _checkMissedMedicines();
  }

  void _checkMissedMedicines() async {
    final now = DateTime.now();

    for (var idx = 0; idx < medicineList.length; idx++) {
      final med = medicineList[idx];
      if (med.status == MedicineStatus.pending && med.dateTime.isBefore(now)) {
        final updated = med.copyWith(
          status: MedicineStatus.missed,
        ); // ✅ use copyWith
        medicineList[idx] = updated;
        await _storage.updateMedicine(updated);

        final entry = HistoryEntry(
          id: UniqueKey().toString(),
          medicineId: updated.id,
          takenTime: updated.dateTime,
          status: MedicineStatus.missed,
        );

        await _storage.addHistory(entry);
        historyList.add(entry);
      }
    }

    setState(() {});
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

    for (var med in medicineList) {
      if (med.isRemind && med.status == MedicineStatus.pending) {
        _notifications.scheduleNotification(med, dailyRepeat: true);
      }
    }
  }

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
      if (result.isRemind) {
        await _notifications.scheduleNotification(result, dailyRepeat: true);
      }
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
          await _notifications.scheduleNotification(result, dailyRepeat: true);
        } else {
          await _notifications.cancelNotification(result.id);
        }
      }
    }
  }

  void _onMarkAsTaken(String id) async {
    final idx = medicineList.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final now = DateTime.now();

    final updated = medicineList[idx].copyWith(status: MedicineStatus.taken);
    medicineList[idx] = updated;
    await _storage.updateMedicine(updated);

    final entry = HistoryEntry(
      id: UniqueKey().toString(),
      medicineId: updated.id,
      takenTime: now,
      status: MedicineStatus.taken,
    );

    await _storage.addHistory(entry);
    await _notifications.cancelNotification(id);

    setState(() {
      historyList.add(entry);
    });
  }

  Future<void> _handleClearAllData() async {
    await _storage.deleteAllMedicines();
    await _storage.clearAllHistory();
    await _notifications.cancelAllNotifications();

    setState(() {
      medicineList = [];
      historyList = [];
    });
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
      AnalyticScreen(medicines: medicineList, history: historyList),
      HistoryScreen(
        medicines: medicineList,
        history: historyList,
        onDeleteHistory: (id) {
          setState(() {
            historyList.removeWhere((h) => h.id == id);
          });
        },
      ),

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
          _checkMissedMedicines();
        },
        onAddTap: _onCreate,
      ),
    );
  }
}
