import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'outbox_models.dart';

class OutboxDao {
  Future<int> insert(OutboxOperation op) async {
    final db = await AppDatabase().db;
    return await db.insert(
      'outbox',
      op.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<OutboxOperation>> pending({int limit = 20}) async {
    final db = await AppDatabase().db;
    final rows = await db.query(
      'outbox',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'id ASC',
      limit: limit,
    );
    return rows.map(OutboxOperation.fromMap).toList();
  }

  Future<void> markSyncing(int id) async {
    final db = await AppDatabase().db;
    await db.update(
      'outbox',
      {'status': 'syncing'},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<void> markDone(int id) async {
    final db = await AppDatabase().db;
    await db.update(
      'outbox',
      {'status': 'done'},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed(int id, String error, {int? attempts}) async {
    final db = await AppDatabase().db;
    await db.update(
      'outbox',
      {
        'status': 'failed',
        'last_error': error,
        if (attempts != null) 'attempts': attempts,
      },
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<void> bumpAttempts(int id, int attempts, {String? lastError}) async {
    final db = await AppDatabase().db;
    await db.update(
      'outbox',
      {
        'status': 'pending',
        'attempts': attempts + 1,
        if (lastError != null) 'last_error': lastError,
      },
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
