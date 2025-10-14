import 'package:flutter/foundation.dart';

/// Servicio mínimo para detectar la palabra de activación (wake word) en texto.
/// No abre el micrófono: solo recibe texto ya reconocido y avisa si encontró el hotword.
class WakeWordService {
  /// Expresiones regulares de los hotwords permitidos.
  final List<RegExp> hotwords;

  /// Tiempo mínimo entre disparos consecutivos (para evitar “rebotes”).
  final Duration cooldown;

  DateTime? _lastTrigger;

  WakeWordService({
    List<String>? phrases,
    this.cooldown = const Duration(seconds: 3),
  }) : hotwords = _compile(
         phrases ?? const ['maia', 'b maia', 'hey maia', 'oye maia'],
       );

  /// Devuelve `true` si el texto contiene el hotword y no estamos en cooldown.
  bool heardHotword(String text) {
    final now = DateTime.now();
    if (_lastTrigger != null && now.difference(_lastTrigger!) < cooldown) {
      return false;
    }
    for (final rx in hotwords) {
      if (rx.hasMatch(text)) {
        _lastTrigger = now;
        if (kDebugMode) {
          debugPrint(
            '[WakeWordService] Hotword detectado con: "${rx.pattern}" en "$text"',
          );
        }
        return true;
      }
    }
    return false;
  }

  /// Compila una lista de frases a regex con límites de palabra e ignore case.
  static List<RegExp> _compile(List<String> phrases) {
    return phrases
        .map(
          (p) => RegExp(
            r'\b' + RegExp.escape(p.trim()) + r'\b',
            caseSensitive: false,
          ),
        )
        .toList();
  }
}
