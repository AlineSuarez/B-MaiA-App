import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/background_gradient.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/chat/chat_list.dart';
import '../screens/onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _unfocusInput() {
    _focusNode.unfocus();
  }

  void _openDrawerSafely() {
    _unfocusInput();
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = provider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? const Color(0xFF1b1f37)
            : const Color(0xFFF7FBFF),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(message);
    _messageController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = themeProvider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    final hasMessages = chatProvider.hasMessages;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? const Color(0xFF1b1f37)
          : const Color(0xFFF7FBFF),
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        drawer: const CustomDrawer(),
        drawerScrimColor: Colors.black.withValues(alpha: 0.6),
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            _unfocusInput();
          }
        },
        resizeToAvoidBottomInset: true,
        body: BackgroundGradient(
          child: SafeArea(
            child: GestureDetector(
              onTap: _unfocusInput,
              child: Column(
                children: [
                  // Header
                  _buildHeader(isTablet, screenWidth, isDark, hasMessages),

                  // Contenido principal
                  Expanded(
                    child: hasMessages
                        ? const ChatList()
                        : _buildEmptyState(
                            isTablet,
                            screenWidth,
                            isDark,
                            isKeyboardVisible,
                          ),
                  ),

                  // Input de mensaje
                  _buildMessageInput(
                    isTablet,
                    keyboardHeight,
                    isDark,
                    chatProvider.isTyping,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isTablet,
    double screenWidth,
    bool isDark,
    bool hasMessages,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: isTablet ? 16 : 12,
      ),
      child: Row(
        children: [
          // Botón de menú
          GestureDetector(
            onTap: _openDrawerSafely,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Icon(
                Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                size: isTablet ? 24 : 20,
              ),
            ),
          ),

          SizedBox(width: isTablet ? 16 : 12),

          // Título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'B-MaiA',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2f43a7),
                    letterSpacing: 0.5,
                  ),
                ),
                if (!hasMessages)
                  Text(
                    'Asistente inteligente',
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF2f43a7).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),

          // Botones de acción
          if (hasMessages)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF2f43a7),
                size: isTablet ? 24 : 22,
              ),
              tooltip: 'Limpiar chat',
              onPressed: () {
                _showClearChatDialog();
              },
            ),

          // Botón para abrir Onboarding
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: isDark ? Colors.white : const Color(0xFF2f43a7),
              size: isTablet ? 24 : 22,
            ),
            tooltip: 'Ver introducción',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isTablet,
    double screenWidth,
    bool isDark,
    bool isKeyboardVisible,
  ) {
    if (isKeyboardVisible) {
      // Estado compacto cuando el teclado está visible
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Hola! Soy B-MaiA',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                'Escribe tu primera pregunta',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF2f43a7).withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: isTablet ? 20 : 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono principal
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2f43a7).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: isTablet ? 48 : 40,
              ),
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // Mensaje de bienvenida
            Text(
              '¡Hola! Soy B-MaiA',
              style: TextStyle(
                fontSize: isTablet ? 32 : 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 16 : 12),

            Container(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : screenWidth * 0.85,
              ),
              child: Text(
                'Tu asistente de inteligencia artificial. Pregúntame lo que necesites, estoy aquí para ayudarte.',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : const Color(0xFF2f43a7).withValues(alpha: 0.8),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // Sugerencias
            _buildSuggestions(isTablet, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(bool isTablet, bool isDark) {
    final suggestions = [
      {'icon': Icons.lightbulb_outline, 'text': '¿Cómo puedes ayudarme?'},
      {'icon': Icons.code, 'text': 'Ayúdame con programación'},
      {'icon': Icons.school_outlined, 'text': 'Explícame un concepto'},
      {'icon': Icons.create_outlined, 'text': 'Ayúdame a escribir'},
    ];

    return Column(
      children: [
        Text(
          'Prueba preguntando:',
          style: TextStyle(
            fontSize: isTablet ? 15 : 13,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF2f43a7).withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: suggestions.map((suggestion) {
            return _buildSuggestionChip(
              suggestion['icon'] as IconData,
              suggestion['text'] as String,
              isTablet,
              isDark,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(
    IconData icon,
    String text,
    bool isTablet,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _focusNode.requestFocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF2f43a7).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFF2f43a7).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF4a5bb8),
              size: isTablet ? 18 : 16,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              text,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.9),
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    bool isTablet,
    double keyboardHeight,
    bool isDark,
    bool isTyping,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 16,
        isTablet ? 12 : 8,
        isTablet ? 20 : 16,
        (isTablet ? 16 : 12) + (keyboardHeight > 0 ? 4 : 0),
      ),
      decoration: BoxDecoration(
        color: Colors.transparent, // Cambiado a transparente
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color.fromARGB(0, 255, 255, 255).withValues(alpha: 0)
                : const Color.fromARGB(0, 158, 158, 158).withValues(alpha: 0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input de texto
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: isTablet ? 48 : 44,
                maxHeight: isTablet ? 120 : 100,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.0)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                //enabled: !isTyping, cuando se integre el chat real se descomenta
                enabled: true,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  fontSize: isTablet ? 15 : 14,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: isTyping
                      ? 'Esperando respuesta...'
                      : 'Escribe tu mensaje...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.grey[600],
                    fontSize: isTablet ? 15 : 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 16,
                    vertical: isTablet ? 14 : 12,
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: isTyping ? null : (_) => _sendMessage(),
              ),
            ),
          ),

          SizedBox(width: isTablet ? 12 : 10),

          // Botón de enviar
          GestureDetector(
            onTap: isTyping ? null : _sendMessage,
            child: AnimatedOpacity(
              opacity: isTyping ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2f43a7).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isTyping ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: isTablet ? 22 : 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark ||
        (Provider.of<ThemeProvider>(context, listen: false).themeMode ==
                ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF23234A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.orange.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Limpiar chat',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar todos los mensajes de esta conversación?',
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ChatProvider>(
                context,
                listen: false,
              ).clearCurrentChat();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
