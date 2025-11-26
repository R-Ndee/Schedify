import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class AppDatabase {
  static Database? _database;
  static const String _dbName = 'calendar_app.db';
  static const int _dbVersion = 2; // Update version untuk migration

  // Table names
  static const String tableEvents = 'events';

  // Singleton
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableEvents(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        category TEXT DEFAULT 'Personal',
        color TEXT DEFAULT '#2196F3',
        isCompleted INTEGER DEFAULT 0,
        hasReminder INTEGER DEFAULT 1,
        reminderMinutes INTEGER DEFAULT 15,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration dari versi 1 ke 2 (tambah reminder fields)
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $tableEvents ADD COLUMN hasReminder INTEGER DEFAULT 1
      ''');
      await db.execute('''
        ALTER TABLE $tableEvents ADD COLUMN reminderMinutes INTEGER DEFAULT 15
      ''');
      
      developer.log('✅ Database upgraded to version 2: Added reminder fields', name: 'AppDatabase');
    }
  }
  
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}