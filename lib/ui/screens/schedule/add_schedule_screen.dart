import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/medicine_model.dart';
import '../../../models/schedule.dart';

const Uuid uuid = Uuid();

class AddScheduleScreen extends StatefulWidget {
  final Medicine? medicine;
  final DateTime? preselectedDate;

  const AddScheduleScreen({super.key, this.medicine, this.preselectedDate});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentsController = TextEditingController();

  // State variables
  late int _selectedIconIndex;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late DateTime? _endDate;
  late String _selectedType;
  late bool _remindMe;

  Schedule? _selectedSchedule;

  final List<String> _medicineTypes = ["Pill", "Piece", "Mg", "Gr"];

  @override
  void initState() {
    super.initState();
    final nowPlusMinute = DateTime.now().add(const Duration(minutes: 1));

    if (widget.medicine != null) {
      // Edit Mode
      final med = widget.medicine!;
      _nameController.text = med.name;
      _amountController.text = med.amount;
      _commentsController.text = med.comments ?? "";
      _selectedIconIndex = med.iconIndex;
      _selectedDate = med.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(med.dateTime);
      _selectedType = med.type;
      _remindMe = med.isRemind;
      _selectedSchedule = med.schedule ??
          Schedule(
            id: uuid.v4(),
            repeatType: RepeatType.none,
            startDate: _selectedDate,
            endDate: null,
          );
      _endDate = _selectedSchedule?.endDate;
    } else {
      // Add Mode
      _nameController.text = "";
      _amountController.text = "1";
      _commentsController.text = "";
      _selectedIconIndex = 0;
      _selectedDate = widget.preselectedDate ?? DateTime.now();
      _selectedTime = TimeOfDay(hour: nowPlusMinute.hour, minute: nowPlusMinute.minute);
      _selectedType = "Pill";
      _remindMe = true;
      _selectedSchedule = Schedule(
        id: uuid.v4(),
        repeatType: RepeatType.none,
        startDate: _selectedDate,
        endDate: null,
      );
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
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final med = Medicine(
      id: widget.medicine?.id ?? uuid.v4(),
      status: widget.medicine?.status ?? MedicineStatus.pending,
      name: _nameController.text,
      amount: _amountController.text,
      type: _selectedType,
      dateTime: dateTime,
      iconIndex: _selectedIconIndex,
      isRemind: _remindMe,
      comments: _commentsController.text,
      schedule: _selectedSchedule?.copyWith(
            startDate: _selectedDate,
            endDate: _endDate,
          ) ??
          Schedule(
            id: uuid.v4(),
            repeatType: RepeatType.none,
            startDate: _selectedDate,
            endDate: _endDate,
          ),
    );

    Navigator.pop(context, med);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return "Please enter a medicine name";
    if (value.length < 2) return "Name is too short";
    return null;
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

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _addCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedSchedule?.customDates ??= [];
        _selectedSchedule!.customDates!.add(picked);
      });
    }
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text("Choose Icon", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isSelected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2AAAAD).withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2AAAAD) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        "assets/pill${index + 1}.png",
                        width: 50,
                        height: 50,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                validator: _validateName,
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

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter amount' : null,
                      decoration: InputDecoration(
                        labelText: "Amount",
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
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _medicineTypes.map(
                        (type) => DropdownMenuItem(value: type, child: Text(type)),
                      ).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                      decoration: InputDecoration(
                        labelText: "Type",
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

              // Start & End Date + Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Start Date",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                              text:
                                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
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
                          decoration: InputDecoration(
                            labelText: "Time",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          controller:
                              TextEditingController(text: _selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // End Date
              GestureDetector(
                onTap: _pickEndDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "End Date (Optional)",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                        text: _endDate != null
                            ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                            : ""),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                activeThumbColor: const Color(0xFF2AAAAD),
                title: const Text("Remind Me"),
                value: _remindMe,
                onChanged: (val) => setState(() => _remindMe = val),
              ),
              const SizedBox(height: 10),

              // Repeat Picker
              DropdownButtonFormField<RepeatType>(
                value: _selectedSchedule?.repeatType ?? RepeatType.none,
                items: RepeatType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSchedule = Schedule(
                      id: _selectedSchedule?.id ?? uuid.v4(),
                      repeatType: val!,
                      startDate: _selectedDate,
                      endDate: _endDate,
                      customDates: val == RepeatType.custom
                          ? _selectedSchedule?.customDates ?? []
                          : null,
                    );
                  });
                },
                decoration: InputDecoration(
                  labelText: "Repeat",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_selectedSchedule?.repeatType == RepeatType.custom)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ...?_selectedSchedule?.customDates?.map((d) => Chip(
                            label: Text("${d.day}/${d.month}/${d.year}"),
                          )),
                      ActionChip(
                        label: const Text("Add Date"),
                        onPressed: _addCustomDate,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _commentsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Remarks",
                  hintText: "Add any notes here...",
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
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2AAAAD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isEditing ? "Update Schedule" : "Save Schedule",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
