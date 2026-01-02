import 'package:flutter/material.dart';
import '../../data/medicine_data.dart';
import '../widgets/reminder_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const Icon(Icons.menu, color: Color(0xFF2AAAAD)),
        centerTitle: true,
        title: Column(
          children: [
            Text("Welcome to", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const Text(
              "MedicTrack App",
              style: TextStyle(
                color: Color(0xFF1A2530),
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          
          // Day Selector with Checkmarks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Mo", "Tu", "Wed", "Th", "Fr", "Sa", "Su"].map((day) {
              bool isSelected = (day == "Mo" || day == "Tu" || day == "Wed");
              return Column(
                children: [
                  Container(
                    width: 45,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF83CFD1).withOpacity(0.5) : const Color(0xFFF1F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF2AAAAD) : Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Reminder Banner (Teal Box with Character)
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF2AAAAD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "FORGETTING\nTO TAKE\nYOUR PILLS?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Add Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Image.asset(
                    'assets/user_home.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Your Reminder",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...medicineList.map((medicine) => ReminderCard(medicine: medicine)).toList(),
        ],
      ),
      

    );
  }
}