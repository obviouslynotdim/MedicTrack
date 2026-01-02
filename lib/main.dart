import 'package:flutter/material.dart';
import 'ui/routes/app_routes.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const MedicTrackApp());
}

class MedicTrackApp extends StatelessWidget {
  const MedicTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedicTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.start,
      routes: AppRoutes.routes,
    );
  }
}
