import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mydiary/diary.dart';

class DatabaseHelper {
  static final _databaseName = "mydiary.db";
  static final _databaseVersion = 1;
  static final tableName = 'tbl_diary';

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _db;

  //database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            date TEXT,
            imagename TEXT
          )
        ''');
      },
    );
  }

  //create
  Future<int> insertDiary(Diary diary) async {
    final db = await database;
    final data = diary.toMap();
    data.remove('id'); //auto increment
    return await db.insert(tableName, data);
  }

  //readAll
  Future<List<Diary>> getAllDiaries() async {
    final db = await database;
    final result =
        await db.query(tableName, orderBy: 'id DESC');
    return result.map((e) => Diary.fromMap(e)).toList();
  }

  //readById
  Future<Diary?> getDiaryById(int id) async {
    final db = await database;
    final result =
        await db.query(tableName, where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Diary.fromMap(result.first);
    }
    return null;
  }

  //update
  Future<int> updateDiary(Diary diary) async {
    final db = await database;
    return await db.update(
      tableName,
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  //delete
  Future<int> deleteDiary(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //closeDB
  Future<void> closeDb() async {
    final db = await database;
    await db.close();
  }
}
