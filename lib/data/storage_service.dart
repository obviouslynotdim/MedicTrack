import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'json_storage.dart';
import '../models/medicine_model.dart';

class StorageService {
  final JsonStorage _fileStorage = JsonStorage();

  Future<List<Medicine>> loadMedicines() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('medicine_data');
      if (jsonList == null) return [];
      return jsonList.map((item) => Medicine.fromJson(jsonDecode(item))).toList();
    } else {
      return await _fileStorage.loadMedicines();
    }
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = medicines.map((m) => jsonEncode(m.toJson())).toList();
      await prefs.setStringList('medicine_data', jsonList);
    } else {
      await _fileStorage.saveMedicines(medicines);
    }
  }
}