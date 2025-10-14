class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://www.bmaia.cl/api',
  );

  // Paths frecuentes por si quieres reusar en otras pantallas
  static const String v1 = '/v1';
  static const String me = '$v1/me';
  static const String profile = '$v1/profile';
  static const String avatar = '$v1/profile/avatar';
  static const String regiones = '$v1/regiones';
  static const String comunas = '$v1/comunas';

  // Timeouts de referencia
  static const int connectSeconds = 8;
  static const int sendSeconds = 12;
  static const int recvSeconds = 12;
}
