import 'package:flutter/material.dart';
import 'ui/routes/app_routes.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';


void main() {
  runApp(const MedicTrackApp());
}

class MedicTrackApp extends StatefulWidget {
  const MedicTrackApp({super.key});

  @override
  State<MedicTrackApp> createState() => _MedicTrackAppState();
}

class _MedicTrackAppState extends State<MedicTrackApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedicTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.start,
      routes: {
        ...AppRoutes.routes,
        AppRoutes.main: (context) => MainScreen(
          isDarkMode: _isDarkMode,
          onDarkModeChanged: _toggleDarkMode,
            ),
      },
    );
  }
}
