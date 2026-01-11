import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/medicine_model.dart';
import '../../models/schedule.dart';
import '../../models/repeat_pattern.dart';
import '../../models/history_entry.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'medicine.db');
    return await openDatabase(
      path,
      version: 2,
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
            comments TEXT,
            status INTEGER,
            repeatPattern TEXT,
            endDate TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE history (
            id TEXT PRIMARY KEY,
            medicineId TEXT,
            status INTEGER,
            timestamp TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migrate history table from "action TEXT" to "status INTEGER"
          await db.execute('ALTER TABLE history RENAME TO history_old');
          await db.execute('''
            CREATE TABLE history (
              id TEXT PRIMARY KEY,
              medicineId TEXT,
              status INTEGER,
              timestamp TEXT
            )
          ''');
          // You could migrate old rows here if needed
        }
      },
    );
  }

  Future<void> insert(Medicine med) async {
    final dbClient = await db;
    await dbClient.insert(
      'medicines',
      {
        'id': med.id,
        'name': med.name,
        'amount': med.amount,
        'type': med.type,
        'dateTime': med.dateTime.toIso8601String(),
        'iconIndex': med.iconIndex,
        'isRemind': med.isRemind ? 1 : 0,
        'comments': med.comments,
        'status': med.status.index,
        'repeatPattern': med.schedule?.repeatPattern.name,
        'endDate': med.schedule?.endDate?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Medicine med) async {
    final dbClient = await db;
    await dbClient.update(
      'medicines',
      {
        'id': med.id,
        'name': med.name,
        'amount': med.amount,
        'type': med.type,
        'dateTime': med.dateTime.toIso8601String(),
        'iconIndex': med.iconIndex,
        'isRemind': med.isRemind ? 1 : 0,
        'comments': med.comments,
        'status': med.status.index,
        'repeatPattern': med.schedule?.repeatPattern.name,
        'endDate': med.schedule?.endDate?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [med.id],
    );
  }

  Future<void> delete(String id) async {
    final dbClient = await db;
    await dbClient.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Medicine>> getMedicines() async {
  final dbClient = await db;
  final maps = await dbClient.query('medicines');

  return maps.map((map) {
    final schedule = Schedule(
      id: map['id'] as String,
      medicineId: map['id'] as String,
      repeatPattern: RepeatPattern.fromString(
        (map['repeatPattern'] as String?) ?? 'none',
      ),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'] as String)
          : null,
    );

    return Medicine(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as String,
      type: map['type'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      iconIndex: (map['iconIndex'] as int),
      isRemind: (map['isRemind'] as int) == 1,
      comments: map['comments'] as String?, // nullable
      status: MedicineStatus.values[(map['status'] as int)],
      schedule: schedule,
    );
  }).toList();
}


  // -------- History --------

  Future<void> insertHistory(HistoryEntry entry) async {
    final dbClient = await db;
    await dbClient.insert(
      'history',
      {
        'id': entry.id,
        'medicineId': entry.medicineId,
        'status': entry.status.index,
        'timestamp': entry.takenTime.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryEntry>> getHistory() async {
    final dbClient = await db;
    final rows = await dbClient.query('history');
    return rows.map((r) {
      return HistoryEntry(
        id: r['id'] as String,
        medicineId: r['medicineId'] as String,
        takenTime: DateTime.parse(r['timestamp'] as String),
        status: MedicineStatus.values[r['status'] as int],
      );
    }).toList();
  }

  Future<void> clearDatabase() async {
    final dbClient = await db;
    await dbClient.delete('medicines');
  }

  Future<void> clearHistory() async {
    final dbClient = await db;
    await dbClient.delete('history');
  }
}