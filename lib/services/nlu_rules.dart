import 'text_norm.dart';

class IntentResult {
  final String intent; // 'crear_apiario' | 'consulta_apiarios' | 'otro'
  final Map<String, String> slots; // nombre, region, comuna
  IntentResult(this.intent, this.slots);
}

class NluRules {
  static IntentResult detect(String text) {
    final t = norm(text);

    if (t.contains('crear apiario')) {
      String nombre = '';
      final mNom = RegExp(
        r'(llamado|nombre)\\s+([a-z0-9\\s\\-]+)',
      ).firstMatch(t);
      if (mNom != null) nombre = mNom.group(2)!.trim();
      if (nombre.isEmpty) {
        final m2 = RegExp(
          r'crear apiario\\s+([^,]+?)(?=\\s+en\\s+|$|,)',
        ).firstMatch(t);
        if (m2 != null) nombre = m2.group(1)!.trim();
      }
      final region =
          RegExp(r'region\\s+([a-z\\s\\-]+)').firstMatch(t)?.group(1)?.trim() ??
          '';
      final comuna =
          RegExp(r'comuna\\s+([a-z\\s\\-]+)').firstMatch(t)?.group(1)?.trim() ??
          '';
      return IntentResult('crear_apiario', {
        'nombre': nombre,
        'region': region,
        'comuna': comuna,
      });
    }

    if (t.contains('cuantos apiarios') || t.contains('cantidad de apiarios')) {
      return IntentResult('consulta_apiarios', {});
    }

    return IntentResult('otro', {});
  }
}
