import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/message.dart';
import 'message_bubble.dart';
import 'ai_message.dart';
import 'typing_indicator.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = themeProvider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Auto-scroll cuando hay nuevos mensajes o está escribiendo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.messages.isNotEmpty || chatProvider.isTyping) {
        _scrollToBottom();
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: isTablet ? 20 : 16,
        bottom: isTablet ? 20 : 16,
      ),
      itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Mostrar indicador de escritura al final
        if (index == chatProvider.messages.length) {
          if (chatProvider.isTyping && chatProvider.currentTypingText.isEmpty) {
            return TypingIndicator(isDark: isDark, isTablet: isTablet);
          } else if (chatProvider.isTyping) {
            // Mostrar mensaje de IA en streaming
            return AIMessage(
              message: Message(
                id: 'streaming',
                content: chatProvider.currentTypingText,
                type: MessageType.ai,
                timestamp: DateTime.now(),
              ),
              isDark: isDark,
              isTablet: isTablet,
              isStreaming: true,
              streamingText: chatProvider.currentTypingText,
            );
          }
        }

        final message = chatProvider.messages[index];

        // Renderizar según el tipo de mensaje
        if (message.type == MessageType.user) {
          return MessageBubble(
            message: message,
            isDark: isDark,
            isTablet: isTablet,
          );
        } else if (message.type == MessageType.ai) {
          return AIMessage(
            message: message,
            isDark: isDark,
            isTablet: isTablet,
          );
        } else {
          // Mensajes del sistema (si los hay)
          return _buildSystemMessage(message, isDark, isTablet);
        }
      },
    );
  }

  Widget _buildSystemMessage(Message message, bool isDark, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 12 : 10,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFF2f43a7).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF2f43a7).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: isTablet ? 16 : 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF2f43a7),
          ),
          SizedBox(width: isTablet ? 8 : 6),
          Flexible(
            child: Text(
              message.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 13 : 12,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF2f43a7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
