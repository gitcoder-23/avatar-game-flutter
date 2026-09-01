import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('avatar_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  FutureOr<void> _createDB(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        hero_name TEXT NOT NULL DEFAULT 'Avatar Kael',
        hero_level INTEGER NOT NULL DEFAULT 1,
        hero_xp INTEGER NOT NULL DEFAULT 0,
        gold INTEGER NOT NULL DEFAULT 500,
        crystals INTEGER NOT NULL DEFAULT 50,
        atk_level INTEGER NOT NULL DEFAULT 1,
        hp_level INTEGER NOT NULL DEFAULT 1,
        def_level INTEGER NOT NULL DEFAULT 1,
        mp_level INTEGER NOT NULL DEFAULT 1,
        tutorial_completed INTEGER NOT NULL DEFAULT 0,
        sound_enabled INTEGER NOT NULL DEFAULT 1,
        music_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        last_login TEXT NOT NULL
      )
    ''');

    // Stage Progress Table
    await db.execute('''
      CREATE TABLE stage_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        stage_id INTEGER NOT NULL,
        stars INTEGER NOT NULL DEFAULT 0,
        high_score INTEGER NOT NULL DEFAULT 0,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        best_time_seconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE (user_id, stage_id)
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
