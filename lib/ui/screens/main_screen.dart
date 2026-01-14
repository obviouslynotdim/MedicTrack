import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
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
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _initApp();
    Timer.periodic(const Duration(seconds: 30), (_) {
      _checkMissedMedicines();
    });
  }

  Future<void> _initApp() async {
    await _notifications.init();
    await _loadSettings();
    await _loadData();
    _applySettings();
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

    for (var med in medicineList) {
      final graceTime = med.dateTime.add(const Duration(seconds: 30));
      if (med.status == MedicineStatus.pending && graceTime.isBefore(now)) {
        med.status = MedicineStatus.missed;

        final entry = HistoryEntry(
          id: UniqueKey().toString(),
          medicineId: med.id,
          takenTime: med.dateTime,
          status: MedicineStatus.missed,
        );

        await _storage.addHistory(entry);
        await _storage.updateMedicine(med);

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
  }

  void _applySettings() {
    _notifications.applyGlobalSettings(
      enableNotifications: _notificationsEnabled,
      sound: _soundEnabled,
      vibration: _vibrationEnabled,
      volume: _volume,
      dailyReminderTime: _dailyReminderTime,
    );

    // reschedule all pending notifications
    for (var med in medicineList) {
      if (med.isRemind &&
          med.status == MedicineStatus.pending &&
          med.dateTime.isAfter(DateTime.now())) {
        _notifications.scheduleNotification(med);
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

      if (result.isRemind && result.schedule != null) {
        await _notifications.scheduleNotification(result);
      }
    }
  }

  void _onDelete(String id) async {
    setState(() => medicineList.removeWhere((m) => m.id == id));
    await _storage.deleteMedicine(id);
    await _notifications.cancelNotification(id);
  }

  void _onEdit(Medicine medicine) async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddScheduleScreen(medicine: medicine),
    );

    if (result != null) {
      final idx = medicineList.indexWhere((m) => m.id == result.id);

      if (idx != -1) {
        setState(() => medicineList[idx] = result);
        await _storage.updateMedicine(result); // updates remarks too
      } else {
        setState(() => medicineList.add(result));
        await _storage.addMedicine(result);
      }

      if (result.isRemind) {
        await _notifications.scheduleNotification(result);
      } else {
        await _notifications.cancelNotification(result.id);
      }
    }
  }

  void _onMarkAsTaken(String id, [DateTime? forDay]) async {
    final now = DateTime.now();
    final markDay = forDay ?? now; // use selected day if provided

    // check if already taken on this day
    final exists = historyList.any(
      (h) => h.medicineId == id && _isSameDay(h.takenTime, markDay),
    );
    if (exists) return;

    final idx = medicineList.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    // Use the original medicine time, but override the day with markDay
    final med = medicineList[idx];
    final takenTime = DateTime(
      markDay.year,
      markDay.month,
      markDay.day,
      med.dateTime.hour,
      med.dateTime.minute,
      med.dateTime.second,
    );

    final entry = HistoryEntry(
      id: UniqueKey().toString(),
      medicineId: id,
      takenTime: takenTime,
      status: MedicineStatus.taken,
    );

    // update medicine only if marking for today or its scheduled day
    // if (_isSameDay(med.dateTime, markDay)) {
      medicineList[idx].status = MedicineStatus.taken;
    // }
    medicineList[idx].lastTakenAt = takenTime;

    await _storage.addHistory(entry);
    await _storage.updateMedicine(medicineList[idx]);
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
        history: historyList,
        onDelete: _onDelete,
        onEdit: _onEdit,
        onTake: _onMarkAsTaken,
        onAddTap: _onCreate,
      ),
      AnalyticScreen(medicines: medicineList),
      HistoryScreen(medicines: medicineList, history: historyList),
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
