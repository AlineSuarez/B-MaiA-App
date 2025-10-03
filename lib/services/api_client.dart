import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;
  ApiClient._internal();

  static const String _scheme = 'http';
  static const int _port = 8000;

  static String get _host {
    if (kIsWeb) {
      return '127.0.0.1';
    }
    if (Platform.isAndroid) {
      // Android Emulator → localhost de tu PC
      return '10.0.2.2';
    }
    // Windows/macOS/Linux desktop
    return '127.0.0.1';
  }

  static String get base => '$_scheme://$_host:$_port/api/v1';

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
              if (t != null) options.headers['Authorization'] = 'Bearer $t';
              handler.next(options);
            },
          ),
        );

  Future<void> saveToken(String token) =>
      _storage.write(key: 'token', value: token);
  Future<void> clearToken() => _storage.delete(key: 'token');
}
