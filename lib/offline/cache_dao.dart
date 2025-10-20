import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class CacheDao {
  Future<void> upsertApiario(Map<String, Object?> a) async {
    final db = await AppDatabase().db;
    await db.insert(
      'cache_apiarios',
      a,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertColmena(Map<String, Object?> c) async {
    final db = await AppDatabase().db;
    await db.insert(
      'cache_colmenas',
      c,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> colmenasDeApiario(int apiarioId) async {
    final db = await AppDatabase().db;
    return db.query(
      'cache_colmenas',
      where: 'apiario_id=?',
      whereArgs: [apiarioId],
      orderBy: 'numero ASC',
    );
  }

  Future<Map<String, Object?>?> buscarColmenaPorQR(String qr) async {
    final db = await AppDatabase().db;
    final r = await db.query(
      'cache_colmenas',
      where: 'codigo_qr=?',
      whereArgs: [qr],
      limit: 1,
    );
    return r.isEmpty ? null : r.first;
  }
}
