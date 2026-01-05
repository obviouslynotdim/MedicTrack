import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'analytic_screen.dart';
import 'history_screen.dart';
import 'setting_screen.dart';
import 'add_schedule_screen.dart';
import '../../models/medicine_model.dart';
import '../widgets/custom_bottom_nav.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- DATA PERSISTENCE ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = medicineList.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('medicine_data', jsonList);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('medicine_data');
    if (jsonList != null) {
      setState(() {
        medicineList = jsonList.map((item) => Medicine.fromJson(jsonDecode(item))).toList();
      });
    }
  }

  // --- PROFESSOR STYLE ACTIONS ---

  void _onCreate() async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddScheduleScreen(),
    );

    if (result != null) {
      setState(() => medicineList.add(result));
      _saveData();
    }
  }

  void _onEdit(Medicine medicine) async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddScheduleScreen(medicine: medicine),
    );

    if (result != null) {
      setState(() {
        final index = medicineList.indexWhere((m) => m.id == result.id);
        if (index != -1) medicineList[index] = result;
      });
      _saveData();
    }
  }

  void _onDelete(String id) {
    setState(() => medicineList.removeWhere((m) => m.id == id));
    _saveData();
  }

  void _onMarkAsTaken(String id) {
    setState(() {
      final index = medicineList.indexWhere((m) => m.id == id);
      if (index != -1) {
      medicineList[index].status = MedicineStatus.taken;
    }
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        medicines: medicineList,
        onDelete: _onDelete,
        onEdit: _onEdit,
        onTake: _onMarkAsTaken,
        onAddTap: _onCreate,
      ),
      AnalyticScreen(medicines: medicineList),
      HistoryScreen(medicines: medicineList),
      SettingsScreen(isDarkMode: widget.isDarkMode, onDarkModeChanged: widget.onDarkModeChanged),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBody: true,
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