import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/medicine_model.dart';

// Define global utility outside the state class
const Uuid uuid = Uuid();

class AddScheduleScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddScheduleScreen({super.key, this.medicine});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  // a GlobalKey for Form validation
  final _formKey = GlobalKey<FormState>();

  // Inputs
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentsController = TextEditingController();

  // State variables
  late int _selectedIconIndex;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedType;
  late bool _remindMe;

  final List<String> _medicineTypes = ["Pill", "Piece", "mg", "gr"];

  @override
  void initState() {
    super.initState();
    // Explicit initialization in initState with if/else for Edit mode
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _amountController.text = widget.medicine!.amount;
      _commentsController.text = widget.medicine!.comments ?? "";
      _selectedIconIndex = widget.medicine!.iconIndex;
      _selectedDate = widget.medicine!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.medicine!.dateTime);
      _selectedType = widget.medicine!.type;
      _remindMe = widget.medicine!.isRemind;
    } else {
      _nameController.text = "";
      _amountController.text = "1";
      _commentsController.text = "";
      _selectedIconIndex = 0;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedType = "Pill";
      _remindMe = true;
    }
  }

  @override
  void dispose() {
    // Always dispose of controllers
    _nameController.dispose();
    _amountController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  // Centralized Save logic with validation
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final med = Medicine(
        // Keep the original ID if editing, otherwise generate a new one
        id: widget.medicine?.id ?? uuid.v4(),

        // Keep the original status if editing, otherwise default to pending
        status: widget.medicine?.status ?? MedicineStatus.pending,

        name: _nameController.text,
        amount: _amountController.text,
        type: _selectedType,
        dateTime: dateTime,
        iconIndex: _selectedIconIndex,
        isRemind: _remindMe,
        comments: _commentsController.text,
      );

      Navigator.pop(context, med);
    }
  }

  // Custom validation function
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a medicine name";
    }
    if (value.length < 2) {
      return "Name is too short";
    }
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

  @override
  Widget build(BuildContext context) {
    // Dynamic labeling
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
        // Use Form widget
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
                  // Construct path: assets/pill1.png, assets/pill2.png, etc.
                  final String assetPath = "assets/pill${index + 1}.png";
                  final bool isSelected = _selectedIconIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2AAAAD).withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2AAAAD)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        assetPath,
                        width: 50,
                        height: 50,
                        // If the images aren't colored, you can use color: isSelected ? ... : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Switched to TextFormField for validation
              TextFormField(
                key: const Key('name_field'),
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
                      key: const Key('amount_field'),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter amount';
                        }
                        return null;
                      },
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
                      initialValue: _selectedType,
                      items: _medicineTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
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

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey[700]),
                          decoration: InputDecoration(
                            labelText: "Date",
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
                                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
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
                          style: TextStyle(color: Colors.grey[700]),
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
                          controller: TextEditingController(
                            text: _selectedTime.format(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SwitchListTile(
                activeThumbColor: const Color(0xFF2AAAAD),
                title: const Text("Remind Me"),
                value: _remindMe,
                onChanged: (val) => setState(() => _remindMe = val),
              ),
              const SizedBox(height: 10),

              TextFormField(
                key: const Key('remarks_field'),
                controller: _commentsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Remarks",
                  labelStyle: TextStyle(color: Colors.grey[600]),
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
