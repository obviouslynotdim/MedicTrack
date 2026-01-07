// lib/core/data/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/medicine_model.dart';

class DBHelper {
  static Database? _db;

  static const _dbVersion = 2; // incremented version

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "medicines.db");

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
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
            comments TEXT,
            lastTakenAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add missing column safely without losing existing data
          await db.execute('ALTER TABLE medicines ADD COLUMN lastTakenAt TEXT');
        }
      },
    );
  }

  Future<void> clearDatabase() async {
    final dbClient = await db;
    await dbClient.delete('medicines');
  }

  Future<List<Medicine>> getMedicines() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('medicines');
    return List.generate(maps.length, (i) => Medicine.fromJson(maps[i]));
  }

  Future<int> insert(Medicine med) async {
    final dbClient = await db;
    return await dbClient.insert(
      'medicines', 
      med.toJson(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<int> update(Medicine med) async {
    final dbClient = await db;
    return await dbClient.update(
      'medicines', 
      med.toJson(), 
      where: 'id = ?', 
      whereArgs: [med.id]
    );
  }

  Future<int> delete(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'medicines', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }
}
