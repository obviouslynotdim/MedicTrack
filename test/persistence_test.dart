// import 'dart:convert';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:finalproject/models/medicine_model.dart';

// void main() {
//   test('Data should persist in SharedPreferences', () async {
//     // 1. Setup Mock SharedPreferences
//     SharedPreferences.setMockInitialValues({});
//     final prefs = await SharedPreferences.getInstance();

//     // 2. Create a dummy medicine
//     final med = Medicine(
//       id: '1',
//       name: 'Test Pill',
//       amount: '1',
//       type: 'Tablet',
//       dateTime: DateTime.now(),
//       iconIndex: 0,
//     );

//     // 3. Manually trigger a save (Simulating _saveData from MainScreen)
//     // Using the logic from your MainScreen
//     List<String> jsonList = [jsonEncode(med.toJson())]; 
//     await prefs.setStringList('medicine_data', jsonList);

//     // 4. Verify data is stored
//     final savedData = prefs.getStringList('medicine_data');
//     expect(savedData, isNotNull);
//     expect(savedData!.length, 1);
//     expect(savedData[0], contains('Test Pill'));
//   });
// }