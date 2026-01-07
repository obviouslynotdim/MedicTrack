import 'package:flutter/material.dart';
import 'dashboard/home_screen.dart';
import 'dashboard/analytic_screen.dart';
import 'schedule/history_screen.dart';
import 'settings/setting_screen.dart';
import 'schedule/add_schedule_screen.dart';
import '../../models/medicine_model.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../core/services.dart/storage_service.dart'; 
import '../../core/services.dart/notification_service.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  const MainScreen({super.key, required this.isDarkMode, required this.onDarkModeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Medicine> medicineList = [];
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _notifications.init();
    final data = await _storage.loadMedicines();
    setState(() => medicineList = data);
  }

  void _onCreate() async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddScheduleScreen(),
    );

    if (result != null) {
      setState(() => medicineList.add(result));
      await _storage.addMedicine(result);
      await _notifications.scheduleNotification(result);
    }
  }

  void _onEdit(Medicine med) async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddScheduleScreen(medicine: med),
    );

    if (result != null) {
      setState(() {
        final idx = medicineList.indexWhere((m) => m.id == result.id);
        if (idx != -1) medicineList[idx] = result;
      });
      await _storage.updateMedicine(result);
      // Refresh notification: cancel old and schedule updated one
      await _notifications.cancelNotification(result.id);
      await _notifications.scheduleNotification(result);
    }
  }

  void _onDelete(String id) async {
    setState(() => medicineList.removeWhere((m) => m.id == id));
    await _storage.deleteMedicine(id);
    await _notifications.cancelNotification(id);
  }

  void _onMarkAsTaken(String id) async {
    final idx = medicineList.indexWhere((m) => m.id == id);
    if (idx != -1) {
      setState(() => medicineList[idx].status = MedicineStatus.taken);
      await _storage.updateMedicine(medicineList[idx]);
      await _notifications.cancelNotification(id); // Stop reminding if already taken
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(medicines: medicineList, onDelete: _onDelete, onEdit: _onEdit, onTake: _onMarkAsTaken, onAddTap: _onCreate),
      AnalyticScreen(medicines: medicineList),
      HistoryScreen(medicines: medicineList),
      SettingsScreen(isDarkMode: widget.isDarkMode, onDarkModeChanged: widget.onDarkModeChanged),
    ];

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.grey.shade100,
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
        onTap: (index) => setState(() => _currentIndex = index),
        onAddTap: _onCreate,
      ),
    );
  }
}