import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../services/api_client.dart';
import '../services/voice_api_gateway.dart';
import '../services/cache_repository.dart';
import '../services/queue_repository.dart';
import '../services/sync_worker.dart';
import '../services/text_norm.dart';

import '../models/pending_job.dart';
// OJO: quitamos job_status.dart porque no lo usamos directamente aquí
import '../models/region_lite.dart';
import '../models/comuna_lite.dart';

class VoiceProvider extends ChangeNotifier {
  final ApiClient apiClient;

  // Motores
  final stt.SpeechToText sttEngine = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  late final VoiceApiGateway api;
  final cache = CacheRepository();
  final queue = QueueRepository();
  late final SyncWorker sync;

  StreamSubscription<dynamic>? _connSub;

  // Estado UI
  String uiStatus = '';
  bool isListening = false;
  String lastHeard = '';
  String lastFinalUtterance = '';

  // Slots del wizard
  final Map<String, String> _slots = {'nombre': '', 'region': '', 'comuna': ''};

  VoiceProvider({required this.apiClient}) {
    api = VoiceApiGateway(apiClient: apiClient);
    sync = SyncWorker(queueRepo: queue, api: api);

    _connSub = Connectivity().onConnectivityChanged.listen((event) async {
      final list = _asList(event);
      final online = list.any((r) => r != ConnectivityResult.none);
      if (online) {
        await _refreshLookupsIfOnline();
        await sync.drainOnce();
      }
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  // ===== Helpers de estado =====
  void _setStatus(String s) {
    uiStatus = s;
    notifyListeners();
  }

  void _setListening(bool v) {
    isListening = v;
    notifyListeners();
  }

  List<ConnectivityResult> _asList(dynamic value) {
    if (value is List<ConnectivityResult>) return value;
    return [value as ConnectivityResult];
  }

  Future<bool> _online() async {
    final res = await Connectivity().checkConnectivity();
    final list = _asList(res);
    return list.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _say(String s) async {
    try {
      await tts.stop();
      await tts.setSpeechRate(0.9);
      await tts.setPitch(1.0);
      await _configureTtsSpanish();
      await tts.speak(s);
    } catch (_) {}
  }

  Future<void> _configureTtsSpanish() async {
    try {
      final raw = await tts.getVoices;
      final voices = (raw is List) ? raw.cast<Map>() : <Map>[];
      if (voices.isNotEmpty) {
        final normalized = voices.map<Map<String, String>>((m) {
          final mm = Map<String, dynamic>.from(m);
          final name = (mm['name'] ?? '').toString();
          final locale = (mm['locale'] ?? '').toString();
          return {'name': name, 'locale': locale};
        }).toList();

        Map<String, String> picked = normalized.firstWhere(
          (v) => (v['locale'] ?? '').toLowerCase() == 'es_cl',
          orElse: () => normalized.firstWhere(
            (v) => (v['locale'] ?? '').toLowerCase().startsWith('es'),
            orElse: () => normalized.first,
          ),
        );

        final loc = picked['locale'] ?? 'es-ES';
        await tts.setLanguage(loc);
        await tts.setVoice({
          if ((picked['name'] ?? '').isNotEmpty) 'name': picked['name']!,
          'locale': loc,
        });
      } else {
        await tts.setLanguage('es-ES');
      }
    } catch (_) {
      await tts.setLanguage('es-ES');
    }
    await tts.setVolume(1.0);
  }

  Future<void> _refreshLookupsIfOnline() async {
    if (await _online()) {
      try {
        final regs = await api.regiones(); // List<RegionLite>
        final coms = await api.comunas(); // List<ComunaLite>

        // Guarda directamente listas de modelos en tu cache
        await cache.saveRegions(regs);
        await cache.saveComunas(coms);

        _setStatus('Catálogos sincronizados (regiones/comunas).');
      } catch (_) {}
    }
  }

  // ======= API pública esperada por tu VoiceDemoScreen =======

  /// Iniciar el “asistente” (en nuestro caso, lanza el wizard de creación).
  Future<void> startAssistant() async {
    await startCreateApiarioWizard();
  }

  /// Detener el “asistente” (detiene escucha si está activa).
  Future<void> stopAssistant() async {
    if (sttEngine.isListening) {
      await sttEngine.stop();
      _setListening(false);
    }
    _setStatus('Asistente detenido.');
  }

  /// Para el badge de pendientes en VoiceDemoScreen (si lo usas allí).
  Future<int> pendingCount() async {
    final items = await queue.load();
    // Si tienes JobStatus en tu modelo, puedes filtrar diferente.
    return items.length;
  }

  /// Enviar texto manual (campo debug) y que el wizard lo interprete.
  Future<void> debugCreateFromText(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    // Heurística simple: si está “preguntando” por slots, úsalo como respuesta.
    if (_needsSlots()) {
      await _fillSlots(clean);
      return;
    }

    // nombre
    final nameMatch = RegExp(
      r'crear\s+apiario\s+(llamado|con\s+nombre)\s+([^\.,]+)',
      caseSensitive: false,
    ).firstMatch(clean);
    if (nameMatch != null && nameMatch.groupCount >= 2) {
      _slots['nombre'] = nameMatch.group(2)!.trim();
    }

    // región
    final regionMatch = RegExp(
      r'región\s+([^\.,]+)',
      caseSensitive: false,
    ).firstMatch(clean);
    if (regionMatch != null && regionMatch.groupCount >= 1) {
      _slots['region'] = regionMatch.group(1)!.trim();
    }

    // comuna
    final comunaMatch = RegExp(
      r'comuna\s+([^\.,]+)',
      caseSensitive: false,
    ).firstMatch(clean);
    if (comunaMatch != null && comunaMatch.groupCount >= 1) {
      _slots['comuna'] = comunaMatch.group(1)!.trim();
    }

    if (_needsSlots()) {
      // Si aún faltan cosas, asume que todo el texto era el nombre (caso simple).
      if ((_slots['nombre'] ?? '').isEmpty) {
        _slots['nombre'] = clean;
      }
      await _promptForMissing();
    } else {
      await _confirmAndCreateApiario();
    }
  }

  // ======== Wizard de creación (sin hotword) ========
  Future<void> startCreateApiarioWizard() async {
    await sttEngine.initialize();
    await _refreshLookupsIfOnline();

    _slots.updateAll((key, value) => '');
    lastHeard = '';
    lastFinalUtterance = '';
    notifyListeners();

    _setStatus('Creación de apiario por voz');
    await _say('Vamos a crear un apiario. ¿Cuál es el nombre del apiario?');
    await _listenOnce(onFinal: (text) => _slots['nombre'] = text.trim());

    if ((_slots['nombre'] ?? '').isEmpty) {
      await _say('No entendí el nombre. Inténtalo de nuevo más tarde.');
      _setStatus('Nombre no capturado.');
      return;
    }

    await _say('¿En qué región estará el apiario?');
    await _listenOnce(onFinal: (text) => _slots['region'] = text.trim());

    if ((_slots['region'] ?? '').isEmpty) {
      await _say('No entendí la región. Inténtalo de nuevo más tarde.');
      _setStatus('Región no capturada.');
      return;
    }

    await _say('¿En qué comuna?');
    await _listenOnce(onFinal: (text) => _slots['comuna'] = text.trim());

    if ((_slots['comuna'] ?? '').isEmpty) {
      await _say('No entendí la comuna. Inténtalo de nuevo más tarde.');
      _setStatus('Comuna no capturada.');
      return;
    }

    await _confirmAndCreateApiario();
  }

  Future<void> _listenOnce({required void Function(String) onFinal}) async {
    _setListening(true);
    await sttEngine.listen(
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'es_CL', // ajusta según necesidad: es_ES, es_MX, etc.
      onResult: (r) async {
        if (r.recognizedWords.isNotEmpty) {
          lastHeard = r.recognizedWords;
          notifyListeners();
        }
        if (r.finalResult) {
          final finalText = r.recognizedWords.trim();
          lastFinalUtterance = finalText;
          notifyListeners();

          await sttEngine.stop();
          _setListening(false);

          if (finalText.isNotEmpty) {
            onFinal(finalText);
          }
        }
      },
    );

    await Future<void>.delayed(const Duration(seconds: 9));
    if (sttEngine.isListening) {
      await sttEngine.stop();
      _setListening(false);
    }
  }

  bool _needsSlots() {
    return _slots['nombre']!.isEmpty ||
        _slots['region']!.isEmpty ||
        _slots['comuna']!.isEmpty;
  }

  Future<void> _fillSlots(String utterance) async {
    final low = utterance.toLowerCase();

    if (_slots['nombre']!.isEmpty && utterance.trim().isNotEmpty) {
      _slots['nombre'] = utterance.trim();
    } else {
      if (_slots['region']!.isEmpty && low.contains('región')) {
        _slots['region'] = utterance
            .replaceAll(RegExp(r'.*región', caseSensitive: false), '')
            .trim();
      }
      if (_slots['comuna']!.isEmpty && low.contains('comuna')) {
        _slots['comuna'] = utterance
            .replaceAll(RegExp(r'.*comuna', caseSensitive: false), '')
            .trim();
      }
    }

    if (_needsSlots()) {
      await _promptForMissing();
    } else {
      await _confirmAndCreateApiario();
    }
  }

  Future<void> _promptForMissing() async {
    if (_slots['nombre']!.isEmpty) {
      _setStatus('Falta nombre.');
      await _say('¿Cuál será el nombre del apiario?');
      await _listenOnce(onFinal: (text) => _slots['nombre'] = text.trim());
      return;
    }

    if (_slots['region']!.isEmpty) {
      _setStatus('Falta región.');
      await _say('¿En qué región?');
      await _listenOnce(onFinal: (text) => _slots['region'] = text.trim());
      return;
    }

    if (_slots['comuna']!.isEmpty) {
      _setStatus('Falta comuna.');
      await _say('¿En qué comuna?');
      await _listenOnce(onFinal: (text) => _slots['comuna'] = text.trim());
      return;
    }

    await _confirmAndCreateApiario();
  }

  Future<void> _confirmAndCreateApiario() async {
    final nombre = _slots['nombre']!.trim();
    final region = _slots['region']!.trim();
    final comuna = _slots['comuna']!.trim();

    // Mapear a IDs
    final regiones = await cache.loadRegions();
    final comunas = await cache.loadComunas();

    final rn = norm(region);
    final reg = regiones.firstWhere(
      (r) => norm(r.name) == rn || norm(r.name).contains(rn),
      orElse: () => RegionLite(id: -1, name: ''),
    );
    if (reg.id == -1) {
      _setStatus('Región no encontrada: $region');
      await _say('No encontré la región $region.');
      return;
    }

    final cn = norm(comuna);
    final cand = comunas.where((c) => c.regionId == reg.id).toList();
    final com = cand.firstWhere(
      (c) => norm(c.name) == cn || norm(c.name).contains(cn),
      orElse: () => ComunaLite(id: -1, name: '', regionId: reg.id),
    );
    if (com.id == -1) {
      _setStatus('Comuna no encontrada: $comuna para región ${reg.name}');
      await _say('No encontré la comuna $comuna para esa región.');
      return;
    }

    final payload = <String, dynamic>{
      'nombre': nombre,
      'tipo_apiario': 'fijo',
      'tipo_manejo': 'convencional',
      'objetivo_produccion': 'miel',
      'region_id': reg.id,
      'comuna_id': com.id,
      'latitud': null,
      'longitud': null,
      'localizacion': null,
      'num_colmenas': 0,
      'activo': true,
      'es_temporal': false,
      'temporada_produccion': DateTime.now().year,
      'url': null,
      'foto': null,
      'registro_sag': null,
    };

    if (await _online()) {
      try {
        final created = await api.crearApiarioOnline(payload);
        _setStatus('Creado: $nombre ✅ (ID: ${created['id'] ?? '-'})');
        await _say('Listo, creé el apiario $nombre.');
      } catch (e) {
        _setStatus('Error al crear online. Encolando para reintento…');
        await _say('Hubo un error del servidor. Lo intentaré de nuevo.');
        await _enqueueCreate(payload, nombre);
      }
    } else {
      await _enqueueCreate(payload, nombre);
    }

    // Reset
    _slots.updateAll((key, value) => '');
  }

  Future<void> _enqueueCreate(
    Map<String, dynamic> payload,
    String nombre,
  ) async {
    final job = PendingJob(
      id: const Uuid().v4(),
      endpoint: '/api/v1/apiarios',
      method: 'POST',
      headers: {
        'Idempotency-Key': const Uuid().v4(),
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      payload: payload,
      createdAt: DateTime.now(),
    );
    await queue.add(job);
    _setStatus('Sin conexión. En cola: $nombre ⏳');
    await _say('Sin conexión. Lo enviaré cuando tenga señal.');
  }
}
