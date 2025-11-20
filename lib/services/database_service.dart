import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lead.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'leads.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'newLead',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // CRUD Operations
  Future<Lead> insertLead(Lead lead) async {
    final db = await database;
    final id = await db.insert('leads', {
      'name': lead.name,
      'contact': lead.contact,
      'notes': lead.notes,
      'status': lead.status.name,
      'createdAt': lead.createdAt.toIso8601String(),
      'updatedAt': lead.updatedAt.toIso8601String(),
    });
    return lead.copyWith(id: id);
  }

  Future<List<Lead>> getAllLeads() async {
    final db = await database;
    final maps = await db.query('leads', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Lead.fromMap(maps[i]));
  }

  Future<Lead?> getLeadById(int id) async {
    final db = await database;
    final maps = await db.query('leads', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Lead.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateLead(Lead lead) async {
    final db = await database;
    return db.update(
      'leads',
      {
        'name': lead.name,
        'contact': lead.contact,
        'notes': lead.notes,
        'status': lead.status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [lead.id],
    );
  }

  Future<int> deleteLead(int id) async {
    final db = await database;
    return db.delete('leads', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
