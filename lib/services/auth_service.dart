import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient(); // usa el singleton

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String device = 'flutter-app',
  }) async {
    try {
      final res = await _api.dio.post(
        '/login',
        data: {'email': email, 'password': password, 'device': device},
      );

      final data = Map<String, dynamic>.from(res.data);
      final token = data['token'] as String?;
      if (token == null) {
        throw Exception('Respuesta inválida del servidor');
      }
      await _api.saveToken(token);
      return data; // { token, user:{...} }
    } on DioException catch (e) {
      String? serverMsg;
      final body = e.response?.data;
      if (body is Map && body['message'] != null) {
        serverMsg = body['message'].toString();
      }
      throw Exception(
        serverMsg ??
            (e.type == DioExceptionType.connectionTimeout ||
                    e.type == DioExceptionType.receiveTimeout
                ? 'Tiempo de conexión agotado'
                : 'No se pudo iniciar sesión'),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String device = 'flutter-app',
  }) async {
    try {
      // Muchos backends exigen password_confirmation
      final res = await _api.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'device': device,
        },
      );

      final data = Map<String, dynamic>.from(res.data);
      final token = data['token'] as String?;
      if (token == null) throw Exception('Respuesta inválida del servidor');

      await _api.saveToken(token);
      return data; // { token, user:{...} }
    } on DioException catch (e) {
      final body = e.response?.data;
      final serverMsg = body is Map
          ? (body['message'] ??
                (body['errors']?.values?.first?.first ?? body.toString()))
          : null;
      throw Exception(serverMsg ?? 'No se pudo registrar');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _api.dio.get('/user'); // en tu backend es /api/v1/user
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/logout');
    } catch (_) {}
    await _api.clearToken();
  }
}
