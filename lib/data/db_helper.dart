import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "medicines.db");
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE medicines (
          id TEXT PRIMARY KEY, 
          name TEXT, 
          amount TEXT, 
          type TEXT, 
          dateTime TEXT, 
          iconIndex INTEGER, 
          isRemind INTEGER, 
          status INTEGER
        )
      ''');
    });
  }

  Future<int> insert(Medicine medicine) async {
    var dbClient = await db;
    return await dbClient.insert('medicines', medicine.toJson());
  }

  Future<List<Medicine>> getMedicines() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query('medicines');
    return maps.map((item) => Medicine.fromJson(item)).toList();
  }
}