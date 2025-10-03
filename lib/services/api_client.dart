import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;
  ApiClient._internal();

  // === Base de la API ===
  // Esquema/host/puerto pensados para local + emulador Android
  static const String _scheme = 'http';
  static const int _port = 8000;

  static String get _host {
    if (kIsWeb) return '127.0.0.1';
    if (Platform.isAndroid) return '10.0.2.2'; // localhost de tu PC
    return '127.0.0.1'; // Desktop
  }

  /// Base completa incluida la versión de API.
  /// Resultado: http://10.0.2.2:8000/api/v1
  static String get base => '$_scheme://$_host:$_port/api/v1';

  /// Origin (sin /api ni versión) para resolver URLs relativas de imágenes.
  /// Resultado: http://10.0.2.2:8000
  static String get origin => '$_scheme://$_host:$_port';

  final _storage = const FlutterSecureStorage();

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: base,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
            headers: {'Accept': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final t = await _storage.read(key: 'token');
              if (t != null && t.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $t';
              }
              handler.next(options);
            },
          ),
        )
        // Log de respuesta para depuración (puedes desactivar responseBody en prod)
        ..interceptors.add(
          LogInterceptor(
            requestHeader: false,
            requestBody: false,
            responseHeader: false,
            responseBody: true,
          ),
        );

  Future<void> saveToken(String token) =>
      _storage.write(key: 'token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'token');
}
