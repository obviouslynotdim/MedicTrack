import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/medicine_model.dart';

class JsonStorage {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/schedule.json');
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    final file = await _getFile();
    final jsonData = jsonEncode(medicines.map((m) => m.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  Future<List<Medicine>> loadMedicines() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((item) => Medicine.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
}