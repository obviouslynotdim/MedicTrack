import 'package:flutter/material.dart';
import '../screens/start_screen.dart';
import '../screens/main_screen.dart';
import '../screens/add_schedule_screen.dart';

class AppRoutes {
  static const start = '/';
  static const main = '/main';
  static const add = '/add';

  static Map<String, WidgetBuilder> routes = {
    start: (context) => const StartScreen(),
    main: (context) => const MainScreen(),
    add: (context) => const AddScheduleScreen(),
  };
}
