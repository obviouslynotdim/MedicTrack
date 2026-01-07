import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/medicine_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "medicines.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Proper Logic: Structure includes 'comments' to preserve your remarks
        await db.execute('''
          CREATE TABLE medicines (
            id TEXT PRIMARY KEY, 
            name TEXT, 
            amount TEXT, 
            type TEXT, 
            dateTime TEXT, 
            iconIndex INTEGER, 
            isRemind INTEGER, 
            status INTEGER,
            comments TEXT
          )
        ''');
      },
    );
  }

  // Save or Overwrite
  Future<int> insert(Medicine med) async {
    final dbClient = await db;
    return await dbClient.insert(
      'medicines', 
      med.toJson(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update specific entry
  Future<int> update(Medicine med) async {
    final dbClient = await db;
    return await dbClient.update(
      'medicines', 
      med.toJson(), 
      where: 'id = ?', 
      whereArgs: [med.id],
    );
  }

  // Delete entry
  Future<int> delete(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'medicines', 
      where: 'id = ?', 
      whereArgs: [id],
    );
  }
  
  // Fetch all
  Future<List<Medicine>> getMedicines() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('medicines');
    return maps.map((item) => Medicine.fromJson(item)).toList();
  }
}