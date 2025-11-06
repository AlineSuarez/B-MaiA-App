import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

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
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showSuggestions = true;

  final List<Map<String, dynamic>> _suggestions = [
    {'icon': Icons.hive_rounded, 'text': '¿Cómo crear un nuevo apiario?'},
    {
      'icon': Icons.calendar_today_rounded,
      'text': '¿Cómo planificar tareas para mis colmenas?',
    },
    {'icon': Icons.map_rounded, 'text': '¿Qué es la zonificación en B-MaiA?'},
    {
      'icon': Icons.analytics_rounded,
      'text': '¿Cómo monitorear el estado de mis colmenas?',
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();

    _messageController.addListener(() {
      _updateSuggestionsVisibility();
    });

    _focusNode.addListener(() {
      _updateSuggestionsVisibility();
    });
  }

  // Método centralizado para actualizar visibilidad de sugerencias
  void _updateSuggestionsVisibility() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final hasMessages = chatProvider.hasMessages;
    final hasText = _messageController.text.trim().isNotEmpty;
    final shouldShow =
        !hasMessages &&
        !hasText &&
        (!_focusNode.hasFocus || _messageController.text.isEmpty);

    if (_showSuggestions != shouldShow) {
      setState(() => _showSuggestions = shouldShow);
    }
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

    Future.delayed(const Duration(milliseconds: 100), () {
      _updateSuggestionsVisibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              onTap: () {
                _unfocusInput();
                Future.delayed(const Duration(milliseconds: 100), () {
                  _updateSuggestionsVisibility();
                });
              },
              child: Column(
                children: [
                  // Header
                  _buildHeader(
                    l10n,
                    isTablet,
                    screenWidth,
                    isDark,
                    hasMessages,
                  ),

                  // Contenido principal
                  Expanded(
                    child: hasMessages
                        ? const ChatList()
                        : _buildEmptyState(
                            l10n,
                            isTablet,
                            screenWidth,
                            isDark,
                            isKeyboardVisible,
                          ),
                  ),

                  // Sugerencias de preguntas - solo si NO hay conversación
                  if (!hasMessages)
                    _buildSuggestionsBar(isTablet, screenWidth, isDark),

                  // Input de mensaje
                  _buildMessageInput(
                    l10n,
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
    AppLocalizations l10n,
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
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: Icon(
                Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                size: isTablet ? 24 : 20,
              ),
            ),
          ),

          // Título centrado
          Expanded(
            child: Center(
              child: Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  letterSpacing: 0.5,
                ),
              ),
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
              tooltip: l10n.clearChat,
              onPressed: () {
                _showClearChatDialog(l10n, isDark);
              },
            ),

          // Botón "info" que abre onboarding
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: isDark ? Colors.white : const Color(0xFF2f43a7),
              size: isTablet ? 24 : 22,
            ),
            tooltip: l10n.getStarted,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    bool isTablet,
    double screenWidth,
    bool isDark,
    bool isKeyboardVisible,
  ) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isKeyboardVisible
          ? _buildCompactState(l10n, isTablet, screenWidth, isDark)
          : isLandscape
          ? _buildLandscapeState(l10n, isTablet, screenWidth, isDark)
          : _buildFullState(l10n, isTablet, screenWidth, isDark),
    );
  }

  Widget _buildCompactState(
    AppLocalizations l10n,
    bool isTablet,
    double screenWidth,
    bool isDark,
  ) {
    return Center(
      key: const ValueKey('compact'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Hola, Soy B-MaiA!',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              '¿En qué te puedo ayudar hoy?',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Nuevo: Estado para modo horizontal
  Widget _buildLandscapeState(
    AppLocalizations l10n,
    bool isTablet,
    double screenWidth,
    bool isDark,
  ) {
    return FadeTransition(
      key: const ValueKey('landscape'),
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation<double>(1.0),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo a la izquierda
              ScaleTransition(
                scale:
                    _scaleAnimation ??
                    const AlwaysStoppedAnimation<double>(1.0),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2f43a7).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: isTablet ? 40 : 32,
                  ),
                ),
              ),

              SizedBox(width: isTablet ? 32 : 24),

              // Texto a la derecha
              Flexible(
                child: SlideTransition(
                  position:
                      _slideAnimation ??
                      const AlwaysStoppedAnimation<Offset>(Offset.zero),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, Soy B-MaiA!',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2f43a7),
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        '¿En qué te puedo ayudar hoy?',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFF2f43a7).withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullState(
    AppLocalizations l10n,
    bool isTablet,
    double screenWidth,
    bool isDark,
  ) {
    return FadeTransition(
      key: const ValueKey('full'),
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation<double>(1.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado con fondo circular azul
            ScaleTransition(
              scale:
                  _scaleAnimation ?? const AlwaysStoppedAnimation<double>(1.0),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 28 : 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2f43a7).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: isTablet ? 56 : 48,
                ),
              ),
            ),

            SizedBox(height: isTablet ? 48 : 40),

            // Texto principal con animación de deslizamiento
            SlideTransition(
              position:
                  _slideAnimation ??
                  const AlwaysStoppedAnimation<Offset>(Offset.zero),
              child: Column(
                children: [
                  // "¡Hola, Soy B-MaiA!" sin emoji y sin fondo
                  Text(
                    '¡Hola, Soy B-MaiA!',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2f43a7),
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isTablet ? 24 : 20),

                  // Pregunta sin icono
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600 : screenWidth * 0.85,
                    ),
                    child: Text(
                      '¿En qué te puedo ayudar hoy?',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(0xFF2f43a7).withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    AppLocalizations l10n,
    bool isTablet,
    double keyboardHeight,
    bool isDark,
    bool isTyping,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final hasText = _messageController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(
        screenWidth * (isLandscape ? 0.03 : 0.04),
        isLandscape ? (isTablet ? 8 : 6) : (isTablet ? 16 : 12),
        screenWidth * (isLandscape ? 0.03 : 0.04),
        isLandscape
            ? (isTablet ? 10 : 8) + (keyboardHeight > 0 ? 6 : 0)
            : (isTablet ? 20 : 16) + (keyboardHeight > 0 ? 8 : 0),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.transparent,
                  const Color(0xFF1b1f37).withValues(alpha: 0.3),
                ]
              : [Colors.transparent, Colors.white.withValues(alpha: 0.3)],
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: isLandscape
              ? (screenHeight * 0.35)
              : (isTablet ? 150 : 120),
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF23234A).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(isLandscape ? 20 : 26),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF2f43a7).withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF2f43a7).withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 8,
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón de clip para adjuntar
            Padding(
              padding: EdgeInsets.only(
                left: isLandscape ? (isTablet ? 8 : 6) : (isTablet ? 10 : 8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isTyping
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.all(
                      isLandscape ? (isTablet ? 7 : 6) : (isTablet ? 9 : 7),
                    ),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: isDark
                          ? Colors.white.withValues(alpha: isTyping ? 0.3 : 0.6)
                          : const Color(
                              0xFF2f43a7,
                            ).withValues(alpha: isTyping ? 0.3 : 0.7),
                      size: isLandscape
                          ? (isTablet ? 18 : 16)
                          : (isTablet ? 22 : 20),
                    ),
                  ),
                ),
              ),
            ),

            // Input de texto
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: isLandscape
                      ? (isTablet ? 36 : 32)
                      : (isTablet ? 44 : 40),
                  maxHeight: isLandscape
                      ? (screenHeight * 0.3)
                      : (isTablet ? 110 : 90),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape
                      ? (isTablet ? 3 : 2)
                      : (isTablet ? 4 : 2),
                  vertical: isLandscape
                      ? (isTablet ? 2 : 1)
                      : (isTablet ? 4 : 2),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  enabled: !isTyping,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1a2a5e),
                    fontSize: isLandscape
                        ? (isTablet ? 13 : 12)
                        : (isTablet ? 15 : 14),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: isTyping
                        ? 'B-MaiA está escribiendo...'
                        : l10n.messageInputPlaceholder,
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color.fromARGB(
                              255,
                              23,
                              34,
                              90,
                            ).withValues(alpha: 0.6),
                      fontSize: isLandscape
                          ? (isTablet ? 13 : 12)
                          : (isTablet ? 15 : 14),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isLandscape
                          ? (isTablet ? 8 : 6)
                          : (isTablet ? 10 : 8),
                      vertical: isLandscape
                          ? (isTablet ? 8 : 6)
                          : (isTablet ? 12 : 10),
                    ),
                    isDense: true,
                  ),
                  maxLines: null,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (!isTyping && hasText)
                      ? (_) => _sendMessage()
                      : null,
                ),
              ),
            ),

            // Botón de enviar
            Padding(
              padding: EdgeInsets.only(
                right: isLandscape ? (isTablet ? 4 : 3) : (isTablet ? 5 : 4),
                left: isLandscape ? (isTablet ? 4 : 3) : (isTablet ? 5 : 4),
              ),
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: (!isTyping && hasText)
                      ? () {
                          HapticFeedback.mediumImpact();
                          _sendMessage();
                        }
                      : null,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: (!isTyping && hasText)
                            ? [const Color(0xFF2f43a7), const Color(0xFF4a5bb8)]
                            : isDark
                            ? [
                                const Color(0xFF2f43a7).withValues(alpha: 0.3),
                                const Color(0xFF4a5bb8).withValues(alpha: 0.3),
                              ]
                            : [
                                const Color(0xFF2f43a7).withValues(alpha: 0.25),
                                const Color(0xFF4a5bb8).withValues(alpha: 0.25),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.all(
                      isLandscape ? (isTablet ? 8 : 7) : (isTablet ? 10 : 8),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isTyping
                            ? Icons.hourglass_empty_rounded
                            : Icons.arrow_upward_rounded,
                        key: ValueKey(isTyping),
                        color: (!isTyping && hasText)
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        size: isLandscape
                            ? (isTablet ? 16 : 14)
                            : (isTablet ? 20 : 18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsBar(bool isTablet, double screenWidth, bool isDark) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Altura reducida en landscape
    final barHeight = isLandscape ? (isTablet ? 50 : 45) : (isTablet ? 70 : 60);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showSuggestions ? barHeight.toDouble() : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showSuggestions ? 1.0 : 0.0,
        child: Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: isLandscape ? (isTablet ? 6 : 4) : (isTablet ? 12 : 8),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => SizedBox(
              width: isLandscape ? (isTablet ? 8 : 6) : (isTablet ? 12 : 10),
            ),
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return _buildSuggestionChip(
                suggestion['icon'] as IconData,
                suggestion['text'] as String,
                isTablet,
                isDark,
                isLandscape,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    IconData icon,
    String text,
    bool isTablet,
    bool isDark,
    bool isLandscape,
  ) {
    // Tamaños más pequeños en landscape
    final horizontalPadding = isLandscape
        ? (isTablet ? 12 : 10)
        : (isTablet ? 16 : 14);
    final verticalPadding = isLandscape
        ? (isTablet ? 8 : 6)
        : (isTablet ? 12 : 10);
    final iconSize = isLandscape ? (isTablet ? 16 : 14) : (isTablet ? 20 : 18);
    final fontSize = isLandscape ? (isTablet ? 12 : 11) : (isTablet ? 14 : 13);
    final borderRadius = isLandscape
        ? (isTablet ? 16 : 14)
        : (isTablet ? 20 : 18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _messageController.text = text;
          _focusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(borderRadius.toDouble()),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.toDouble(),
            vertical: verticalPadding.toDouble(),
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF23234A).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(borderRadius.toDouble()),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFF2f43a7).withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.08),
                blurRadius: isLandscape ? 6 : 8,
                offset: Offset(0, isLandscape ? 1 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF2f43a7),
                size: iconSize.toDouble(),
              ),
              SizedBox(width: isLandscape ? 6 : (isTablet ? 10 : 8)),
              Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  fontSize: fontSize.toDouble(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearChatDialog(AppLocalizations l10n, bool isDark) {
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
                l10n.clearChat,
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
              l10n.cancel,
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
              Future.delayed(const Duration(milliseconds: 100), () {
                _updateSuggestionsVisibility();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
