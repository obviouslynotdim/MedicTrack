import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medicine_model.dart';

class HomeScreen extends StatelessWidget {
  final List<Medicine> medicines;
  final Function(String) onDelete;
  final Function(Medicine) onEdit;
  final Function(String) onTake;
  final VoidCallback onAddTap; // Connects the banner button to the MainScreen logic

  const HomeScreen({
    super.key,
    required this.medicines,
    required this.onDelete,
    required this.onEdit,
    required this.onTake,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    // Only show pending medicines on the home screen
    final pending = medicines.where((m) => m.status == MedicineStatus.pending).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Home")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          
          // --- REMINDER BANNER (Teal Box with user_home asset) ---
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
                        onPressed: onAddTap, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Add Schedule", 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Image.asset(
                    'assets/user_home.png', // Using your specific asset
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          // --- SECTION HEADER ---
          const Text(
            "Today's Schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // --- MEDICINE LIST ---
          pending.isEmpty 
            ? _buildEmptyState() 
            : ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: pending.length,
                itemBuilder: (context, index) {
                  final med = pending[index];
                  return _buildMedicineCard(med);
                },
              ),
          
          const SizedBox(height: 100), // Space for the FAB notch
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine med) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(med.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => onDelete(med.id),
        child: GestureDetector(
          onTap: () => onEdit(med),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2AAAAD).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication, color: Color(0xFF2AAAAD)),
              ),
              title: Text(
                med.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('hh:mm a').format(med.dateTime),
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Color(0xFF2AAAAD)),
                onPressed: () => onTake(med.id),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          "No medicines for now.",
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}