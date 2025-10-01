import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AIMessage extends StatefulWidget {
  final Message message;
  final bool isDark;
  final bool isTablet;
  final bool isStreaming;
  final String? streamingText;

  const AIMessage({
    super.key,
    required this.message,
    required this.isDark,
    required this.isTablet,
    this.isStreaming = false,
    this.streamingText,
  });

  @override
  State<AIMessage> createState() => _AIMessageState();
}

class _AIMessageState extends State<AIMessage>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context) {
    final content = widget.isStreaming
        ? widget.streamingText
        : widget.message.content;
    Clipboard.setData(ClipboardData(text: content ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Respuesta copiada al portapapeles'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF4a5bb8).withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.isStreaming
        ? widget.streamingText
        : widget.message.content;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          margin: EdgeInsets.only(
            left: widget.isTablet ? 20 : 16,
            right: widget.isTablet ? 20 : 16,
            bottom: widget.isTablet ? 24 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar y encabezado de B-MaiA
              _buildHeader(),
              SizedBox(height: widget.isTablet ? 12 : 10),

              // Contenido estilo documento
              _buildContent(content ?? ''),

              // Acciones (copiar, etc.)
              if (_isHovered || widget.isTablet) _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: widget.isTablet ? 36 : 32,
          height: widget.isTablet ? 36 : 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.isTablet ? 10 : 8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2f43a7).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.psychology_rounded,
            color: Colors.white,
            size: widget.isTablet ? 20 : 18,
          ),
        ),
        SizedBox(width: widget.isTablet ? 12 : 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'B-MaiA',
              style: TextStyle(
                color: widget.isDark ? Colors.white : const Color(0xFF2f43a7),
                fontSize: widget.isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (!widget.isStreaming)
              Text(
                _formatTime(widget.message.timestamp),
                style: TextStyle(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.grey[600],
                  fontSize: widget.isTablet ? 11 : 10,
                ),
              ),
          ],
        ),
        if (widget.isStreaming) ...[
          SizedBox(width: widget.isTablet ? 12 : 10),
          _buildTypingIndicator(),
        ],
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4a5bb8).withValues(alpha: value),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted) {
                setState(() {});
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildContent(String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 16 : 12,
        vertical: widget.isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(widget.isTablet ? 16 : 14),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.grey[800],
            fontSize: widget.isTablet ? 15 : 14,
            height: 1.7,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
          h1: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF2f43a7),
            fontSize: widget.isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h2: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF2f43a7),
            fontSize: widget.isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h3: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF2f43a7),
            fontSize: widget.isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          strong: TextStyle(
            color: widget.isDark ? Colors.white : const Color(0xFF2f43a7),
            fontWeight: FontWeight.bold,
          ),
          em: TextStyle(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.grey[700],
            fontStyle: FontStyle.italic,
          ),
          listBullet: TextStyle(
            color: const Color(0xFF4a5bb8),
            fontSize: widget.isTablet ? 15 : 14,
          ),
          code: TextStyle(
            color: widget.isDark
                ? const Color(0xFF4a5bb8)
                : const Color(0xFF2f43a7),
            backgroundColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF2f43a7).withValues(alpha: 0.1),
            fontFamily: 'monospace',
            fontSize: widget.isTablet ? 14 : 13,
          ),
          codeblockDecoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[300]!,
            ),
          ),
          blockquote: TextStyle(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey[600],
            fontSize: widget.isTablet ? 14 : 13,
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            color: const Color(0xFF4a5bb8).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: const Color(0xFF4a5bb8), width: 3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: EdgeInsets.only(top: widget.isTablet ? 12 : 8),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.content_copy_rounded,
            label: 'Copiar',
            onTap: () => _copyToClipboard(context),
          ),
          SizedBox(width: widget.isTablet ? 12 : 8),
          _buildActionButton(
            icon: Icons.thumb_up_outlined,
            label: 'Útil',
            onTap: () {
              // TODO: Implementar feedback positivo
            },
          ),
          SizedBox(width: widget.isTablet ? 12 : 8),
          _buildActionButton(
            icon: Icons.thumb_down_outlined,
            label: 'No útil',
            onTap: () {
              // TODO: Implementar feedback negativo
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isTablet ? 12 : 10,
          vertical: widget.isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: widget.isTablet ? 16 : 14,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey[600],
            ),
            SizedBox(width: widget.isTablet ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: widget.isTablet ? 12 : 11,
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
