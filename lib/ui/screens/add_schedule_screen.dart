import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicine_model.dart';
import 'package:intl/intl.dart';

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
              IconPicker(
                selectedIndex: _selectedIconIndex,
                onSelect: (index) => setState(() => _selectedIconIndex = index),
                ),

const SizedBox(height: 20),
const Text("Choose Date & Time", style: TextStyle(fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
Row(
  children: [
    // DATE PICKER
    Expanded(
      child: InkWell(
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now(), // prevent past dates
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                _selectedDate.hour,
                _selectedDate.minute,
              );
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.calendar_today, color: Color(0xFF2AAAAD)),
            ],
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    // TIME PICKER
    Expanded(
      child: InkWell(
        onTap: () async {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_selectedDate),
          );
          if (pickedTime != null) {
            setState(() {
              _selectedDate = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('hh:mm a').format(_selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.access_time, color: Color(0xFF2AAAAD)),
            ],
          ),
        ),
      ),
    ),
  ],
),

  const Text("Medicine Name", style: TextStyle(fontWeight: FontWeight.bold)),
TextField(
  controller: _nameController,
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
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

class IconPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const IconPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> medicineIcons = [
      Icons.medication,       
      Icons.vaccines,         
      Icons.local_drink,     
      Icons.local_hospital,      
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(medicineIcons.length, (index) => IconButton(
        icon: Icon(
          medicineIcons[index],
          color: selectedIndex == index ? Colors.teal : Colors.grey,
          size: 30,
        ),
        onPressed: () => onSelect(index),
      )),
    );
  }
}