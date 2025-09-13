import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  static Database? _database;
  static const String _databaseName = 'agsapp.db';
  static const int _databaseVersion = 1;

  SqliteService._();

  static SqliteService? _instance;
  static SqliteService get instance => _instance ??= SqliteService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables here
    // Example table creation:
    // await db.execute('''
    //   CREATE TABLE users (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     name TEXT NOT NULL,
    //     email TEXT NOT NULL
    //   )
    // ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
