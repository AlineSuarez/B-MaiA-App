import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'outbox_dao.dart';
import 'outbox_models.dart';

class OutboxService {
  final OutboxDao _dao;
  final Dio _dio;

  OutboxService(this._dao, this._dio);

  Future<void> enqueue({
    required String intent,
    required String method,
    required String path,
    required Map<String, dynamic> payload,
    Map<String, String>? headers,
    String? idemKey,
  }) async {
    final key = idemKey ?? const Uuid().v4();
    final op = OutboxOperation(
      idemKey: key,
      intent: intent,
      method: method.toUpperCase(),
      path: path,
      payloadJson: jsonEncode(payload),
      headersJson: headers == null ? null : jsonEncode(headers),
      createdAt: DateTime.now().toIso8601String(),
      status: 'pending',
    );
    await _dao.insert(op);
  }

  /// Procesa lote de pendientes con reintentos exponenciales ligeros
  Future<void> processPending({int batch = 10}) async {
    final items = await _dao.pending(limit: batch);
    for (final op in items) {
      await _dao.markSyncing(op.id!);
      try {
        final headers = <String, dynamic>{
          'Content-Type': 'application/json',
          'Idempotency-Key': op.idemKey,
        };
        if (op.headersJson != null) {
          headers.addAll(
            Map<String, dynamic>.from(jsonDecode(op.headersJson!)),
          );
        }
        final data = jsonDecode(op.payloadJson);
        Response res;
        switch (op.method) {
          case 'POST':
            res = await _dio.post(
              op.path,
              data: data,
              options: Options(headers: headers),
            );
            break;
          case 'PUT':
            res = await _dio.put(
              op.path,
              data: data,
              options: Options(headers: headers),
            );
            break;
          case 'DELETE':
            res = await _dio.delete(
              op.path,
              data: data,
              options: Options(headers: headers),
            );
            break;
          default:
            throw Exception('Método no soportado: ${op.method}');
        }

        if (res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! < 300) {
          await _dao.markDone(op.id!);
        } else {
          // reintento
          await _dao.bumpAttempts(
            op.id!,
            op.attempts,
            lastError: 'HTTP ${res.statusCode}',
          );
        }
      } catch (e) {
        // backoff ligero: dejamos en pending y subimos attempts
        await _dao.bumpAttempts(op.id!, op.attempts, lastError: e.toString());
      }
    }
  }
}
