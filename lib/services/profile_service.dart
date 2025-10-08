import 'api_client.dart';

class ProfileService {
  final _api = ApiClient();

  // Devuelve el objeto del usuario autenticado
  // Tu backend responde en /api/v1/user (base seteada en ApiClient)
  Future<Map<String, dynamic>> me() async {
    final res = await _api.dio.get('/user');
    return Map<String, dynamic>.from(res.data);
  }

  // Ejemplo para futuras ediciones de perfil
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.dio.patch('/me', data: payload);
    return Map<String, dynamic>.from(res.data);
  }
}
