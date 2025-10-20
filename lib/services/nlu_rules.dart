String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[áàä]'), 'a')
    .replaceAll(RegExp(r'[éèë]'), 'e')
    .replaceAll(RegExp(r'[íìï]'), 'i')
    .replaceAll(RegExp(r'[óòö]'), 'o')
    .replaceAll(RegExp(r'[úùü]'), 'u');

class NluRules {
  /// Debe existir este método (lo llama AssistantProvider)
  Future<Map<String, dynamic>> parse(
    String text, {
    Map<String, dynamic>? meta,
  }) async {
    final t = _norm(text);
    final slots = {...(meta ?? {})};

    // DEMO 1: visita inspección
    if (t.contains('crear') && t.contains('visita') && t.contains('inspe')) {
      final required = [
        'apiario_id',
        'fecha_visita',
        'num_colmenas_inspeccionadas',
      ];
      slots['fecha_visita'] ??= DateTime.now().toIso8601String().substring(
        0,
        10,
      );
      final missing = required
          .where((k) => slots[k] == null || slots[k].toString().isEmpty)
          .toList();
      return {
        'tipo': 'cmd',
        'intent': 'crear_visita_inspeccion',
        'slots': slots,
        'required': required,
        'missing': missing,
        'prompt': missing.isNotEmpty ? _prompt(missing.first) : null,
        'offline_allowed': true,
        'endpoint': {'method': 'POST', 'path': '/api/v1/visitas/inspeccion'},
        'needs_online': false,
        'cache_ok_offline': false,
      };
    }

    // DEMO 2: por defecto listar colmenas de un apiario
    final required = ['apiario_id'];
    final missing = required
        .where((k) => slots[k] == null || slots[k].toString().isEmpty)
        .toList();
    return {
      'tipo': 'query',
      'intent': 'listar_colmenas_apiario',
      'slots': slots,
      'required': required,
      'missing': missing,
      'prompt': missing.isNotEmpty ? _prompt(missing.first) : null,
      'offline_allowed': true,
      'endpoint': null,
      'needs_online': false,
      'cache_ok_offline': true,
    };
  }

  String _prompt(String key) {
    switch (key) {
      case 'apiario_id':
        return '¿ID del apiario?';
      case 'fecha_visita':
        return '¿Fecha de la visita?';
      case 'num_colmenas_inspeccionadas':
        return '¿Cuántas colmenas inspeccionaste?';
    }
    return 'Me falta $key, ¿cuál es?';
  }
}
