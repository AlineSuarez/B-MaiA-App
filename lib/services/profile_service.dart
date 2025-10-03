import 'api_client.dart';

class ProfileService {
  final _api = ApiClient();

  /// Devuelve el usuario autenticado
  /// Base: http://.../api/v1 ; Endpoint: /user
  Future<Map<String, dynamic>> me() async {
    final res = await _api.dio.get('/user');
    return Map<String, dynamic>.from(res.data);
  }

  /// Actualización parcial de perfil (si tu backend lo soporta)
  /// Base: http://.../api/v1 ; Endpoint: /me
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.dio.patch('/me', data: payload);
    return Map<String, dynamic>.from(res.data);
  }
}
