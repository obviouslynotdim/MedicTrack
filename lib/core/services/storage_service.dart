import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db_helper.dart';
import '../../models/medicine_model.dart';

class StorageService {
  final DBHelper _dbHelper = DBHelper();
  static const String _webKey = 'medicine_data';

  /// Loads medicines from SQL (Mobile) or SharedPreferences (Web)
  Future<List<Medicine>> loadMedicines() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_webKey) ?? [];
      try {
        return list.map((item) => Medicine.fromJson(jsonDecode(item))).toList();
      } catch (e) {
        debugPrint("❌ Error decoding web storage: $e");
        return [];
      }
    }
    return await _dbHelper.getMedicines();
  }

  /// Adds a medicine
  Future<void> addMedicine(Medicine med) async {
    if (kIsWeb) {
      final list = await loadMedicines();
      list.add(med);
      await _saveWeb(list);
    } else {
      await _dbHelper.insert(med);
    }
    _debugPrintJson();
  }

  /// Updates a medicine
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
    _debugPrintJson();
  }

  /// Deletes a medicine
  Future<void> deleteMedicine(String id) async {
    if (kIsWeb) {
      final list = await loadMedicines();
      list.removeWhere((m) => m.id == id);
      await _saveWeb(list);
    } else {
      await _dbHelper.delete(id);
    }
  }

  /// Clears all data (Used for your new Settings feature)
  Future<void> deleteAllMedicines() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webKey);
    } else {
      await _dbHelper.clearDatabase();
    }
  }

  /// Private helper for Web storage
  Future<void> _saveWeb(List<Medicine> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_webKey, data);
  }

  /// Debug helper - only runs in debug mode
  void _debugPrintJson() async {
    if (kDebugMode) {
      final list = await loadMedicines();
      final json = jsonEncode(list.map((m) => m.toJson()).toList());
      debugPrint("📋 Current Data: $json");
    }
  }
}