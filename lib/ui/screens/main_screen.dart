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
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Medicine> medicineList = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data from disk on startup
  }

  // --- PERSISTENCE LOGIC ---

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert Medicine objects to JSON strings for storage
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

  // --- MEDICINE ACTIONS ---

  void _addOrUpdateMedicine(Medicine medicine) {
    setState(() {
      int index = medicineList.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        medicineList[index] = medicine; // Edit existing
      } else {
        medicineList.add(medicine); // Add new
      }
    });
    _saveData();
  }

  void _deleteMedicine(String id) {
    setState(() {
      medicineList.removeWhere((m) => m.id == id);
    });
    _saveData();
  }

  void _markAsTaken(String id) {
    setState(() {
      final index = medicineList.indexWhere((m) => m.id == id);
      if (index != -1) {
        medicineList[index].status = MedicineStatus.taken;
      }
    });
    _saveData();
  }

  void _showAddScheduleSheet({Medicine? medicineToEdit}) async {
    final result = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScheduleScreen(medicine: medicineToEdit),
    );

    if (result != null) {
      _addOrUpdateMedicine(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pages to display based on navigation index
    final List<Widget> pages = [
      HomeScreen(
        medicines: medicineList,
        onDelete: _deleteMedicine,
        onEdit: (m) => _showAddScheduleSheet(medicineToEdit: m),
        onTake: _markAsTaken,
        onAddTap: () => _showAddScheduleSheet(), // Connected to the teal banner button
      ),
      AnalyticScreen(medicines: medicineList),
      HistoryScreen(medicines: medicineList),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBody: true, // Crucial for the notched nav bar effect
      body: pages[_currentIndex],
      
      // THE ADD BUTTON (FAB)
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () => _showAddScheduleSheet(),
          backgroundColor: const Color(0xFF2AAAAD),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 35, color: Colors.white),
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onAddTap: () => _showAddScheduleSheet(),
      ),
    );
  }
}