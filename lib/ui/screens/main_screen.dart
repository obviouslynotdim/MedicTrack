import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'analytic_screen.dart';
import 'history_screen.dart';
import 'setting_screen.dart';
import 'add_schedule_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AnalyticScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onAddTap: () {
          // This creates the pop-up effect
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Allows the sheet to go full height if needed
            backgroundColor: Colors.transparent, // Allows for rounded corners
            builder: (context) => const AddScheduleScreen(),
          );
        },
      ),
    );
  }
}