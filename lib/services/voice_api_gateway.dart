import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../models/region_lite.dart';
import '../models/comuna_lite.dart';
import '../models/pending_job.dart';

class VoiceApiGateway {
  final ApiClient apiClient;

  VoiceApiGateway({required this.apiClient});

  Future<List<RegionLite>> regiones() async {
    final Response res = await apiClient.dio.get('/api/v1/regiones');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(RegionLite.fromJson).toList();
  }

  Future<List<ComunaLite>> comunas() async {
    final Response res = await apiClient.dio.get('/api/v1/comunas');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(ComunaLite.fromJson).toList();
  }

  Future<Map<String, dynamic>> crearApiarioOnline(
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.dio.post('/api/v1/apiarios', data: payload);
    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    // fallback por si el backend devuelve algo distinto
    return {'raw': res.data};
  }

  /// Método que usa tu SyncWorker
  Future<Response> enviarJob(PendingJob job) async {
    return await apiClient.dio.request(
      job.endpoint,
      data: job.payload,
      options: Options(
        method: job.method,
        headers: job.headers,
        responseType: ResponseType.json,
      ),
    );
  }
}
