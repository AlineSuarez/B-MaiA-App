import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/background_gradient.dart';
import '../widgets/custom_drawer.dart';
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
  final ScrollController _scrollController = ScrollController();
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

    // Listener para detectar cambios en el foco del input
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Cuando el input recibe foco, hacer scroll hacia abajo tras un pequeño delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = provider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Header compacto cuando hay teclado en landscape
                            if (isLandscape && isKeyboardVisible)
                              _buildCompactHeader(isTablet, screenWidth, isDark)
                            else
                              // Header normal
                              isKeyboardVisible
                                  ? _buildHeader(isTablet, screenWidth, isDark)
                                  : FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: _buildHeader(
                                        isTablet,
                                        screenWidth,
                                        isDark,
                                      ),
                                    ),

                            // Contenido principal flexible
                            Expanded(
                              child: isLandscape
                                  ? _buildLandscapeLayout(
                                      isTablet,
                                      screenWidth,
                                      screenHeight,
                                      isKeyboardVisible,
                                      isDark,
                                    )
                                  : _buildPortraitLayout(
                                      isTablet,
                                      screenWidth,
                                      screenHeight,
                                      isKeyboardVisible,
                                      isDark,
                                    ),
                            ),

                            // Input de mensaje con diseño adaptativo
                            _buildMessageInput(
                              isTablet,
                              keyboardHeight,
                              isDark,
                              isLandscape,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header compacto para landscape + teclado
  Widget _buildCompactHeader(bool isTablet, double screenWidth, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: isTablet ? 8 : 6,
      ),
      child: Row(
        children: [
          // Botón de menú más pequeño
          GestureDetector(
            onTap: _openDrawerSafely,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Icon(
                Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                size: isTablet ? 18 : 16,
              ),
            ),
          ),

          SizedBox(width: isTablet ? 12 : 8),

          // Título compacto
          Expanded(
            child: Text(
              'B-MaiA',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isTablet, double screenWidth, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: isTablet ? 20 : 16,
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
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2f43a7),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Asistente inteligente',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : const Color(0xFF2f43a7).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Botón para abrir Onboarding
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: isDark ? Colors.white : const Color(0xFF2f43a7),
              size: isTablet ? 26 : 22,
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

  Widget _buildPortraitLayout(
    bool isTablet,
    double screenWidth,
    double screenHeight,
    bool isKeyboardVisible,
    bool isDark,
  ) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: isTablet ? 12 : 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mensaje de bienvenida principal
          _buildWelcomeMessage(isTablet, screenWidth, isDark),

          // Sugerencias de preguntas (solo si no hay teclado)
          if (!isKeyboardVisible) ...[
            SizedBox(height: isTablet ? 24 : 16),
            _buildSuggestions(isTablet, screenWidth, isDark),
          ],
        ],
      ),
    );
    return isKeyboardVisible
        ? child
        : FadeTransition(opacity: _fadeAnimation, child: child);
  }

  Widget _buildLandscapeLayout(
    bool isTablet,
    double screenWidth,
    double screenHeight,
    bool isKeyboardVisible,
    bool isDark,
  ) {
    // En landscape con teclado, simplificar la UI
    if (isKeyboardVisible) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: isTablet ? 4 : 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Solo mensaje compacto cuando hay teclado
            Text(
              '¡Hola! Soy B-MaiA',
              style: TextStyle(
                fontSize: isTablet ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              'Tu asistente de inteligencia artificial',
              style: TextStyle(
                fontSize: isTablet ? 10 : 8,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Layout normal sin teclado
    final child = Container(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
      child: Row(
        children: [
          // Lado izquierdo - Mensaje de bienvenida
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeMessage(
                    isTablet,
                    screenWidth,
                    isDark,
                    isLandscape: true,
                  ),
                ],
              ),
            ),
          ),

          // Lado derecho - Sugerencias
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuggestions(
                    isTablet,
                    screenWidth,
                    isDark,
                    isLandscape: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return FadeTransition(opacity: _fadeAnimation, child: child);
  }

  Widget _buildWelcomeMessage(
    bool isTablet,
    double screenWidth,
    bool isDark, {
    bool isLandscape = false,
  }) {
    return Column(
      crossAxisAlignment: isLandscape
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        // Icono central
        if (!isLandscape) ...[
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
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
              size: isTablet ? 40 : 32,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
        ],

        // Título principal
        Text(
          '¡Hola! Soy B-MaiA',
          style: TextStyle(
            fontSize: isTablet ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
            letterSpacing: 0.5,
          ),
          textAlign: isLandscape ? TextAlign.left : TextAlign.center,
        ),

        SizedBox(height: isTablet ? 12 : 10),

        // Subtítulo
        Container(
          constraints: BoxConstraints(
            maxWidth: isLandscape
                ? double.infinity
                : (isTablet ? 500 : screenWidth * 0.85),
          ),
          child: Text(
            'Tu asistente de inteligencia artificial. Pregúntame lo que necesites, estoy aquí para ayudarte.',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFF2f43a7).withValues(alpha: 0.8),
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            textAlign: isLandscape ? TextAlign.left : TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(
    bool isTablet,
    double screenWidth,
    bool isDark, {
    bool isLandscape = false,
  }) {
    final suggestions = [
      {'icon': Icons.lightbulb_outline, 'text': '¿Cómo puedes ayudarme?'},
      {'icon': Icons.code, 'text': 'Ayúdame con programación'},
    ];

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: isLandscape
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
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
            alignment: isLandscape ? WrapAlignment.start : WrapAlignment.center,
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
      ),
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
        // Combinar texto existente con sugerencia
        final currentText = _messageController.text;
        String finalText;

        if (currentText.isNotEmpty) {
          final needsSpace =
              !currentText.endsWith(' ') && !currentText.endsWith('\n');
          finalText = currentText + (needsSpace ? ' ' : '') + text;
        } else {
          finalText = text;
        }

        _messageController.text = finalText;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: finalText.length),
        );

        // Enfocar el input después de agregar la sugerencia
        _focusNode.requestFocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 10,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF2f43a7).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0xFF2f43a7).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF4a5bb8),
              size: isTablet ? 16 : 14,
            ),
            SizedBox(width: isTablet ? 6 : 4),
            Text(
              text,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.9),
                fontSize: isTablet ? 13 : 11,
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
    bool isLandscape,
  ) {
    // Adaptar altura según orientación y teclado
    final double maxInputHeight;
    final double minInputHeight;

    if (isLandscape && keyboardHeight > 0) {
      // En landscape con teclado, hacer input más compacto
      maxInputHeight = isTablet ? 50.0 : 40.0;
      minInputHeight = isTablet ? 36.0 : 32.0;
    } else {
      // Tamaños normales
      maxInputHeight = isTablet ? 100.0 : 80.0;
      minInputHeight = isTablet ? 52.0 : 44.0;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 20 : 16,
        isTablet ? 8 : 6,
        isTablet ? 20 : 16,
        (isTablet ? 16 : 12) + (keyboardHeight > 0 ? 4 : 0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input de texto
          Expanded(
            child: GestureDetector(
              onTap: () {
                _focusNode.requestFocus();
              },
              child: Container(
                constraints: BoxConstraints(
                  minHeight: minInputHeight,
                  maxHeight: maxInputHeight,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2a2a2a)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFF2f43a7).withValues(alpha: 0.2),
                  ),
                ),
                child: Scrollbar(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    autofocus: false,
                    enableInteractiveSelection: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2f43a7),
                      fontSize: isTablet ? 15 : 13,
                      height: 1.3,
                    ),
                    decoration: InputDecoration(
                      hintText: isLandscape && keyboardHeight > 0
                          ? 'Escribe...'
                          : 'Escribe tu mensaje...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : const Color(0xFF2f43a7).withValues(alpha: 0.5),
                        fontSize: isTablet ? 15 : 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 12 : 10,
                      ),
                      isDense: true,
                    ),
                    maxLines: isLandscape && keyboardHeight > 0 ? 2 : null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    scrollPhysics: const BouncingScrollPhysics(),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: isTablet ? 12 : 8),

          // Botón de enviar
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2f43a7).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: isTablet ? 20 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mensaje enviado: $message'),
        backgroundColor: const Color(0xFF2f43a7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
        ),
      ),
    );

    _messageController.clear();
    _focusNode.unfocus();
  }
}
