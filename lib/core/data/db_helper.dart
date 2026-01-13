import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/medicine_model.dart';
import '../../models/history_entry.dart';

class DBHelper {
  static Database? _db;
  static const _dbVersion = 3;

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
            lastTakenAt TEXT,
            schedule TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE history (
            id TEXT PRIMARY KEY,
            medicineId TEXT,
            takenTime TEXT,
            status INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE medicines ADD COLUMN schedule TEXT');
        }
      },
    );
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
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Medicine med) async {
    final dbClient = await db;
    return await dbClient.update(
      'medicines',
      med.toJson(),
      where: 'id = ?',
      whereArgs: [med.id],
    );
  }

  Future<int> delete(String id) async {
    final dbClient = await db;
    return await dbClient.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertHistory(HistoryEntry entry) async {
    final dbClient = await db;
    await dbClient.insert('history', entry.toJson());
  }

  Future<void> clearDatabase() async {
    final dbClient = await db;
    await dbClient.delete('medicines');
    await clearHistory();
  }

  Future<void> clearHistory() async {
    final dbClient = await db;
    await dbClient.delete('history');
  }

  Future<List<HistoryEntry>> getHistory() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('history');
    return List.generate(maps.length, (i) => HistoryEntry.fromJson(maps[i]));
  }
}
