// lib/ui/screens/dashboard/analytic_screen.dart
import 'package:flutter/material.dart';
import '../../../models/medicine_model.dart';
import '../../../core/utils/streak_calculator.dart';

class AnalyticScreen extends StatelessWidget {
  final List<Medicine> medicines;
  const AnalyticScreen({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    int streak = StreakCalculator.calculateStreak(medicines);
    int totalCount = medicines.length;
    int takenCount = medicines.where((m) => m.status == MedicineStatus.taken).length;
    int missedCount = medicines.where((m) => m.status == MedicineStatus.missed).length;
    double progress = totalCount == 0 ? 0 : takenCount / totalCount;

    const Color brandTeal = Color(0xFF2AAAAD);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Behavior Analysis"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // STREAK CARD
                    _buildStreakCard(streak, brandTeal),
                    
                    const SizedBox(height: 40),

                    // CIRCULAR PROGRESS (CENTERED)
                    _buildProgressCircle(progress, brandTeal),

                    const SizedBox(height: 40),

                    // STATS GRID
                    Row(
                      children: [
                        _buildStatBox("Total", totalCount.toString(), Colors.blueGrey),
                        const SizedBox(width: 12),
                        _buildStatBox("Taken", takenCount.toString(), Colors.green),
                        const SizedBox(width: 12),
                        _buildStatBox("Missed", missedCount.toString(), Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(int streak, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 32),
          const SizedBox(width: 12),
          Text(
            "$streak Day Streak!",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double progress, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 14,
            backgroundColor: Colors.grey[200],
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          children: [
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
            ),
            const Text("Compliance", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}