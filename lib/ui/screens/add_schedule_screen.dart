import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicine_model.dart';

class AddScheduleScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddScheduleScreen({super.key, this.medicine});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _nameController = TextEditingController();
  int _selectedIconIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _selectedIconIndex = widget.medicine!.iconIndex;
      _selectedDate = widget.medicine!.dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Fixes keyboard overflow
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView( // Fixes height overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text("Add Schedule", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            const Text("Choose Icon", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => IconButton(
                icon: Icon(Icons.medication, color: _selectedIconIndex == index ? Colors.teal : Colors.grey, size: 30),
                onPressed: () => setState(() => _selectedIconIndex = index),
              )),
            ),

            const SizedBox(height: 20),
            const Text("Medicine Name", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2AAAAD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  if (_nameController.text.isEmpty) return;
                  final med = Medicine(
                    id: widget.medicine?.id ?? const Uuid().v4(),
                    name: _nameController.text,
                    amount: "1", type: "Pill",
                    dateTime: _selectedDate,
                    iconIndex: _selectedIconIndex,
                  );
                  Navigator.pop(context, med);
                },
                child: const Text("Save Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}