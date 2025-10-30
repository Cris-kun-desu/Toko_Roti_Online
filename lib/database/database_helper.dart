import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'roti_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // tabel user
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // tabel roti
    await db.execute('''
      CREATE TABLE roti(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        harga REAL NOT NULL
      )
    ''');

    // tabel transaksi
    await db.execute('''
      CREATE TABLE transaksi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pembeli INTEGER NOT NULL,
        id_roti INTEGER NOT NULL,
        jumlah INTEGER NOT NULL,
        total_harga REAL NOT NULL,
        latitude REAL,
        longitude REAL,
        status TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        FOREIGN KEY (id_pembeli) REFERENCES users(id),
        FOREIGN KEY (id_roti) REFERENCES roti(id)
      )
    ''');

    // insert default admin
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'nama': 'Administrator',
      'role': 'admin'
    });
  }

  // method user
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> isUsernameExists(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // method roti
  Future<int> insertRoti(Map<String, dynamic> roti) async {
    Database db = await database;
    return await db.insert('roti', roti);
  }

  Future<List<Map<String, dynamic>>> getRotiList() async {
    Database db = await database;
    return await db.query('roti');
  }

  Future<int> updateRoti(int id, Map<String, dynamic> roti) async {
    Database db = await database;
    return await db.update('roti', roti, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteRoti(int id) async {
    Database db = await database;
    return await db.delete('roti', where: 'id = ?', whereArgs: [id]);
  }

  // method transaksi
  Future<int> insertTransaksi(Map<String, dynamic> transaksi) async {
    Database db = await database;
    return await db.insert('transaksi', transaksi);
  }

  Future<List<Map<String, dynamic>>> getTransaksiByPembeli(int idPembeli) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT t.*, r.nama as nama_roti, r.harga 
      FROM transaksi t
      JOIN roti r ON t.id_roti = r.id
      WHERE t.id_pembeli = ?
      ORDER BY t.tanggal DESC
    ''', [idPembeli]);
  }

  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT t.*, r.nama as nama_roti, u.nama as nama_pembeli
      FROM transaksi t
      JOIN roti r ON t.id_roti = r.id
      JOIN users u ON t.id_pembeli = u.id
      ORDER BY t.tanggal DESC
    ''');
  }

  Future<int> updateStatusTransaksi(int id, String status) async {
    Database db = await database;
    return await db.update(
      'transaksi',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
