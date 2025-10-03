import 'api_client.dart';

class ProfileService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> me() async {
    final res = await _api.dio.get('/user'); // -> /api/v1/user (con token)
    return Map<String, dynamic>.from(res.data);
  }

  // si luego quieres actualizar datos:
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.dio.patch('/me', data: payload);
    return Map<String, dynamic>.from(res.data);
  }
}
