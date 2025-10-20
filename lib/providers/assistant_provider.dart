import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

import '../services/api_client.dart';
import '../services/queue_repository.dart';
import '../services/cache_repository.dart';
import '../services/nlu_rules.dart';
import '../services/ai_service.dart';
import '../services/profile_service.dart';
import '../services/sync_worker.dart';
import '../models/pending_job.dart';

class AssistantState {
  final String conversationId;
  final String? prompt;
  final Map<String, dynamic> slots;
  final String? lastMessage;
  final bool busy;
  final bool requiresNetwork;
  final String? error;
  final Map<String, dynamic>? lastResponse;

  AssistantState({
    required this.conversationId,
    this.prompt,
    this.slots = const {},
    this.lastMessage,
    this.busy = false,
    this.requiresNetwork = false,
    this.error,
    this.lastResponse,
  });

  AssistantState copyWith({
    String? conversationId,
    String? prompt,
    Map<String, dynamic>? slots,
    String? lastMessage,
    bool? busy,
    bool? requiresNetwork,
    String? error,
    Map<String, dynamic>? lastResponse,
  }) => AssistantState(
    conversationId: conversationId ?? this.conversationId,
    prompt: prompt ?? this.prompt,
    slots: slots ?? this.slots,
    lastMessage: lastMessage ?? this.lastMessage,
    busy: busy ?? this.busy,
    requiresNetwork: requiresNetwork ?? this.requiresNetwork,
    error: error,
    lastResponse: lastResponse ?? this.lastResponse,
  );
}

class AssistantProvider extends ChangeNotifier {
  final ApiClient api;
  final QueueRepository queue;
  final CacheRepository cache;
  final NluRules nlu;
  final AIService? ai; // ✅ nombre correcto
  final ProfileService profile; // no usamos currentUser() (no existe)
  final SyncWorker sync;

  AssistantState _state = AssistantState(conversationId: const Uuid().v4());
  AssistantState get state => _state;

  AssistantProvider({
    required this.api,
    required this.queue,
    required this.cache,
    required this.nlu,
    required this.profile,
    required this.sync,
    this.ai,
  });

  void resetConversation() {
    _state = AssistantState(conversationId: const Uuid().v4());
    notifyListeners();
  }

  Future<void> handleUserText(String rawText, {required bool online}) async {
    _state = _state.copyWith(busy: true, error: null, lastMessage: rawText);
    notifyListeners();

    final meta = <String, dynamic>{}; // no usamos profile.currentUser()

    final parse = await nlu.parse(rawText, meta: meta);

    if ((parse['missing'] as List).isNotEmpty) {
      _state = _state.copyWith(
        busy: false,
        prompt: parse['prompt'] as String?,
        slots: {
          ..._state.slots,
          ...Map<String, dynamic>.from(parse['slots'] as Map),
        },
      );
      notifyListeners();
      return;
    }

    final tipo = parse['tipo'] as String; // 'cmd' | 'query' | 'kb'
    final slots = Map<String, dynamic>.from(parse['slots'] as Map);
    final endpoint = Map<String, dynamic>.from(parse['endpoint'] ?? {});
    final offlineAllowed = (parse['offline_allowed'] ?? false) as bool;
    final needsOnline = (parse['needs_online'] ?? false) as bool;

    if (tipo == 'cmd') {
      if (online && !needsOnline) {
        try {
          final idem = const Uuid().v4();
          final method = (endpoint['method'] ?? 'POST')
              .toString()
              .toUpperCase();
          final path = (endpoint['path'] ?? '/api/v1/unknown').toString();

          Response res;
          switch (method) {
            case 'PUT':
              res = await api.dio.put(
                path,
                data: slots,
                options: Options(headers: {'Idempotency-Key': idem}),
              );
              break;
            case 'DELETE':
              res = await api.dio.delete(
                path,
                data: slots,
                options: Options(headers: {'Idempotency-Key': idem}),
              );
              break;
            default:
              res = await api.dio.post(
                path,
                data: slots,
                options: Options(headers: {'Idempotency-Key': idem}),
              );
          }

          final resMap = Map<String, dynamic>.from(res.data as Map);
          _state = _state.copyWith(
            busy: false,
            lastResponse: resMap,
            prompt: 'Listo ✅',
          );
          notifyListeners();
          return;
        } catch (_) {
          // si falla red o HTTP, caemos a offline si está permitido
        }
      }

      if (offlineAllowed) {
        final idem = const Uuid().v4();
        await queue.add(
          PendingJob.create(
            method: (endpoint['method'] ?? 'POST').toString(),
            endpoint: (endpoint['path'] ?? '/api/v1/unknown')
                .toString(), // 👈 usa 'endpoint'
            payload: slots,
            headers: {'Idempotency-Key': idem},
          ),
        );

        _state = _state.copyWith(
          busy: false,
          requiresNetwork: !online || needsOnline,
          prompt: 'Guardado offline; sincronizaré cuando haya señal.',
        );
        notifyListeners();
        return;
      } else {
        _state = _state.copyWith(
          busy: false,
          requiresNetwork: true,
          prompt: 'Para esta acción necesito internet.',
        );
        notifyListeners();
        return;
      }
    }

    if (tipo == 'query') {
      final canCache = parse['cache_ok_offline'] == true;

      if (!online && !canCache) {
        _state = _state.copyWith(
          busy: false,
          requiresNetwork: true,
          prompt: 'Necesito internet para esa consulta. ¿La dejo pendiente?',
        );
        notifyListeners();
        return;
      }

      try {
        Map<String, dynamic> res;
        if (!online && canCache) {
          res = await _queryFromCache(parse['intent'].toString(), slots);
        } else {
          res = await _queryViaApi(parse['intent'].toString(), slots);
        }
        _state = _state.copyWith(busy: false, lastResponse: res, prompt: null);
        notifyListeners();
        return;
      } catch (e) {
        _state = _state.copyWith(busy: false, error: e.toString());
        notifyListeners();
        return;
      }
    }

    if (tipo == 'kb') {
      if (!online) {
        _state = _state.copyWith(
          busy: false,
          requiresNetwork: true,
          prompt: 'Para responder desde documentos necesito internet.',
        );
        notifyListeners();
        return;
      }
      final answer =
          await ai?.answerFromDocs(rawText) ?? {'text': '(RAG no configurado)'};
      _state = _state.copyWith(busy: false, lastResponse: answer);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _queryViaApi(
    String intent,
    Map<String, dynamic> slots,
  ) async {
    switch (intent) {
      case 'listar_colmenas_apiario':
        {
          final res = await api.dio.get(
            '/api/v1/apiarios/${slots['apiario_id']}/colmenas',
            queryParameters: {
              'limit': slots['limit'] ?? 25,
              'offset': slots['offset'] ?? 0,
            },
          );
          return Map<String, dynamic>.from(res.data as Map);
        }
      default:
        throw UnimplementedError('Consulta $intent no implementada');
    }
  }

  Future<Map<String, dynamic>> _queryFromCache(
    String intent,
    Map<String, dynamic> slots,
  ) async {
    if (intent == 'listar_colmenas_apiario' && slots['apiario_id'] != null) {
      final list = await cache.colmenasDeApiario(slots['apiario_id']);
      return {'ok': true, 'data': list};
    }
    if (intent == 'buscar_colmena_por_qr' && slots['qr'] != null) {
      final col = await cache.buscarColmenaPorQR(slots['qr']);
      return {'ok': col != null, 'data': col};
    }
    throw Exception('Consulta no disponible offline');
  }
}
