import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _i = AppDatabase._();
  AppDatabase._();
  factory AppDatabase() => _i;

  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'bmaia.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE outbox(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idem_key TEXT NOT NULL UNIQUE,
          intent TEXT NOT NULL,
          method TEXT NOT NULL,
          path TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          headers_json TEXT,
          created_at TEXT NOT NULL,
          status TEXT NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT
        )''');

        await db.execute('''
        CREATE TABLE cache_apiarios(
          id INTEGER PRIMARY KEY,
          nombre TEXT,
          region_id INTEGER,
          comuna_id INTEGER,
          num_colmenas INTEGER,
          updated_at TEXT
        )''');

        await db.execute('''
        CREATE TABLE cache_colmenas(
          id INTEGER PRIMARY KEY,
          apiario_id INTEGER,
          nombre TEXT,
          numero TEXT,
          color_etiqueta TEXT,
          codigo_qr TEXT,
          updated_at TEXT
        )''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_outbox_status ON outbox(status)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_colmenas_apiario ON cache_colmenas(apiario_id)',
        );
      },
    );
  }
}
