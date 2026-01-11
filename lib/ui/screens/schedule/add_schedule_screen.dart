import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../models/medicine_model.dart';
import '../../../models/schedule.dart';
import '../../../models/repeat_pattern.dart';

const Uuid uuid = Uuid();

class AddScheduleScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddScheduleScreen({super.key, this.medicine});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  RepeatPattern _repeatPattern = RepeatPattern.none;
  DateTime? _endDate;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentsController = TextEditingController();

  late int _selectedIconIndex;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedType;
  late bool _remindMe;

  final List<String> _medicineTypes = ["Pill", "Piece", "mg", "gr"];

  @override
  void initState() {
    super.initState();
    final later = DateTime.now().add(const Duration(minutes: 1));

    if (widget.medicine != null) {
      final med = widget.medicine!;
      _nameController.text = med.name;
      _amountController.text = med.amount;
      _commentsController.text = med.comments ?? "";
      _selectedIconIndex = med.iconIndex;
      _selectedDate = med.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(med.dateTime);
      _selectedType = med.type;
      _remindMe = med.isRemind;
      _repeatPattern = med.schedule?.repeatPattern ?? RepeatPattern.none;
      _endDate = med.schedule?.endDate;
    } else {
      _nameController.text = "";
      _amountController.text = "1";
      _commentsController.text = "";
      _selectedIconIndex = 0;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay(hour: later.hour, minute: later.minute);
      _selectedType = "Pill";
      _remindMe = true;
      _repeatPattern = RepeatPattern.none;
      _endDate = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final schedule = Schedule(
        id: uuid.v4(),
        medicineId: widget.medicine?.id ?? uuid.v4(),
        repeatPattern: _repeatPattern,
        endDate: _endDate,
      );

      final med = Medicine(
        id: widget.medicine?.id ?? uuid.v4(),
        status: widget.medicine?.status ?? MedicineStatus.pending,
        name: _nameController.text.trim(),
        amount: _amountController.text.trim(),
        type: _selectedType,
        dateTime: dateTime,
        iconIndex: _selectedIconIndex,
        isRemind: _remindMe,
        comments: _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
        schedule: schedule,
      );

      Navigator.pop(context, med);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.medicine != null;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                isEditing ? "Edit Schedule" : "Add Schedule",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose Icon",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final String assetPath = "assets/pill${index + 1}.png";
                  final bool isSelected = _selectedIconIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2AAAAD).withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2AAAAD)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(assetPath, width: 50, height: 50),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // --- Your new fields go here ---
              TextFormField(
                controller: _nameController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Enter name" : null,
                decoration: InputDecoration(
                  labelText: "Medicine Name",
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Amount + Type row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _medicineTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                      decoration: InputDecoration(
                        labelText: "Type",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date + Time row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text:
                                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          ),
                          style: TextStyle(color: Colors.grey[700]),
                          decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: _selectedTime.format(context),
                          ),
                          style: TextStyle(color: Colors.grey[700]),
                          decoration: InputDecoration(
                            labelText: "Time",
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Repeat pattern
              DropdownButtonFormField<RepeatPattern>(
                value: _repeatPattern,
                items: RepeatPattern.values.map((pattern) {
                  return DropdownMenuItem(
                    value: pattern,
                    child: Text(pattern.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _repeatPattern = val!),
                decoration: InputDecoration(
                  labelText: "Repeat",
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_repeatPattern != RepeatPattern.none)
                ListTile(
                  title: Text(
                    _endDate == null
                        ? "Select End Date"
                        : "End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              const SizedBox(height: 20),

              SwitchListTile(
                activeThumbColor: const Color(0xFF2AAAAD),
                title: const Text("Remind Me"),
                value: _remindMe,
                onChanged: (val) => setState(() => _remindMe = val),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _commentsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  hintText: "Add any notes here...",
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2AAAAD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _onSave,
                  child: Text(
                    isEditing ? "Update Schedule" : "Save Schedule",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
