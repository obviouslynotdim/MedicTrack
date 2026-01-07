import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db_helper.dart';
import '../../models/medicine_model.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final DBHelper _dbHelper = DBHelper();

  /// Loads medicines from SQL (Mobile) or SharedPreferences (Web)
  Future<List<Medicine>> loadMedicines() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('medicine_data') ?? [];
      return list.map((item) => Medicine.fromJson(jsonDecode(item))).toList();
    }
    return await _dbHelper.getMedicines();
  }

  /// Adds a medicine and triggers a JSON check for your submission
  Future<void> addMedicine(Medicine med) async {
    if (kIsWeb) {
      final list = await loadMedicines();
      list.add(med);
      await _saveWeb(list);
    } else {
      await _dbHelper.insert(med);
    }
    // Checking submission:
    await debugPrintJson();
  }

  /// Updates a medicine (preserving remarks)
  Future<void> updateMedicine(Medicine med) async {
    if (kIsWeb) {
      final list = await loadMedicines();
      final idx = list.indexWhere((m) => m.id == med.id);
      if (idx != -1) {
        list[idx] = med;
        await _saveWeb(list);
      }
    } else {
      await _dbHelper.update(med);
    }
    await debugPrintJson();
  }

  Future<void> deleteMedicine(String id) async {
    if (kIsWeb) {
      final list = await loadMedicines();
      list.removeWhere((m) => m.id == id);
      await _saveWeb(list);
    } else {
      await _dbHelper.delete(id);
    }
  }

  /// PROPER LOGIC: Verification Method
  /// Call this to see your data formatted as JSON in the console
  Future<void> debugPrintJson() async {
  if (kDebugMode) { // Only runs when you are developing, not for users
    final list = await loadMedicines();
    final jsonString = jsonEncode(list.map((m) => m.toJson()).toList());
    debugPrint("📋 Current Submission Data (JSON): $jsonString");
    }
  }

  /// Private helper for Web-based JSON storage
  Future<void> _saveWeb(List<Medicine> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'medicine_data',
      list.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }
}