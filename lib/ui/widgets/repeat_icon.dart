import 'package:flutter/material.dart';
import '../../models/schedule.dart';

class RepeatIcon extends StatelessWidget {
  final Schedule? schedule;
  final double size;
  final Color? color;

  const RepeatIcon({
    super.key,
    required this.schedule,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    final tooltip = _getTooltip();

    return Tooltip(
      message: tooltip,
      child: Icon(
        iconData,
        size: size,
        color: color ?? Colors.grey.shade600,
      ),
    );
  }

  IconData _getIcon() {
    if (schedule == null) return Icons.event;

    switch (schedule!.repeatType) {
      case RepeatType.daily:
        return Icons.repeat;

      case RepeatType.weekly:
        return Icons.date_range;

      case RepeatType.monthly:
        return Icons.calendar_month;

      case RepeatType.custom:
        return Icons.edit_calendar;

      case RepeatType.none:
        return Icons.event;
    }
  }

  String _getTooltip() {
    if (schedule == null) return 'One time';

    switch (schedule!.repeatType) {
      case RepeatType.daily:
        return 'Repeats daily';

      case RepeatType.weekly:
        return 'Repeats weekly';

      case RepeatType.monthly:
        return 'Repeats monthly';

      case RepeatType.custom:
        return 'Custom dates';

      case RepeatType.none:
        return 'One time';
    }
  }
}
