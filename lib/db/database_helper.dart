import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('offline_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT,
            phone TEXT,
            address TEXT,
            latlong TEXT,
            confirm_password TEXT,
            image TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final db = await database;
    return await db.query('users', where: 'synced = 0');
  }

  Future<int> updateUserSynced(int id) async {
    final db = await database;
    return await db.update('users', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
