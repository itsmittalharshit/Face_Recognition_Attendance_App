import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class AttendanceDB {
  static final AttendanceDB instance = AttendanceDB._init();
  static Database? _database;
  AttendanceDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertAttendance(String name) async {
    final db = await database;
    final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await db.insert('attendance', {'name': name, 'date': date});
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    return await db.query('attendance', orderBy: 'date DESC');
  }
}
