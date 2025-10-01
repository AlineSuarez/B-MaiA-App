import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isTyping = false;
  String _currentTypingText = '';

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  ChatSession? get currentSession => _currentSession;
  bool get isTyping => _isTyping;
  String get currentTypingText => _currentTypingText;
  List<Message> get messages => _currentSession?.messages ?? [];
  bool get hasMessages => messages.isNotEmpty || _isTyping;

  ChatProvider() {
    _initializeDemoSession();
  }

  void _initializeDemoSession() {
    // Crear sesión demo vacía
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nueva conversación',
      messages: [],
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );

    _sessions.add(session);
    _currentSession = session;
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isTyping) return;

    // Crear mensaje del usuario
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    // Agregar mensaje del usuario
    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      lastMessageAt: DateTime.now(),
    );

    // Actualizar título si es el primer mensaje
    if (_currentSession!.messages.length == 1) {
      final title = _aiService.generateChatTitle(content);
      _currentSession = _currentSession!.copyWith(title: title);
    }

    notifyListeners();

    // Simular respuesta de IA con streaming
    _isTyping = true;
    _currentTypingText = '';
    notifyListeners();

    try {
      await for (final chunk in _aiService.generateResponse(content)) {
        _currentTypingText = chunk;
        notifyListeners();
      }

      // Crear mensaje final de IA
      final aiMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _currentTypingText,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, aiMessage],
        lastMessageAt: DateTime.now(),
      );

      _isTyping = false;
      _currentTypingText = '';
      notifyListeners();
    } catch (e) {
      _isTyping = false;
      _currentTypingText = '';
      notifyListeners();

      // Manejar error
      debugPrint('Error al generar respuesta: $e');
    }
  }

  void createNewChat() {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nueva conversación',
      messages: [],
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );

    _sessions.add(session);
    _currentSession = session;
    _isTyping = false;
    _currentTypingText = '';
    notifyListeners();
  }

  void switchToSession(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    _currentSession = session;
    _isTyping = false;
    _currentTypingText = '';
    notifyListeners();
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);

    if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
    }

    notifyListeners();
  }

  void clearCurrentChat() {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(messages: []);
      _isTyping = false;
      _currentTypingText = '';
      notifyListeners();
    }
  }

  List<String> getSuggestedFollowUps() {
    if (messages.isEmpty) return [];
    final lastAIMessage = messages.lastWhere(
      (m) => m.type == MessageType.ai,
      orElse: () {
        return Message(
          id: '',
          content: '',
          type: MessageType.ai,
          timestamp: DateTime.now(),
        );
      },
    );

    if (lastAIMessage.content.isEmpty) return [];
    return _aiService.getSuggestedFollowUps(lastAIMessage.content);
  }
}
