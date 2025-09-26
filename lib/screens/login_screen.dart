import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorMessage('Por favor, completa todos los campos');
      return;
    }
    setState(() {
      _isLoadingEmail = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingEmail = false;
    });
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoadingGoogle = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingGoogle = false;
    });
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleBackButton() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final orientation = media.orientation;
    final isTablet = screenWidth > 600;
    final isLandscape = orientation == Orientation.landscape;
    final keyboardHeight = media.viewInsets.bottom;

    // Espaciados y tamaños adaptativos
    final horizontalPadding = isTablet ? 64.0 : 24.0;
    final verticalPadding = isTablet ? 32.0 : 16.0;
    final logoSize = isTablet ? 64.0 : 48.0;
    final contentMaxWidth = isTablet ? 500.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0B), Color(0xFF1A1A23), Color(0xFF2f43a7)],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (!isLandscape) {
                // VERTICAL: SIEMPRE muestra el texto de bienvenida
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: verticalPadding,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: contentMaxWidth,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLogoSection(logoSize, isTablet),
                                  SizedBox(height: isTablet ? 32 : 24),
                                  // TEXTO DE BIENVENIDA
                                  Text(
                                    'Bienvenido',
                                    style: TextStyle(
                                      fontSize: isTablet ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isTablet ? 8 : 6),
                                  Text(
                                    'Inicia sesión para continuar con B-MaiA',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isTablet ? 32 : 24),
                                  _buildLoginForm(isTablet),
                                  SizedBox(height: isTablet ? 24 : 20),
                                  _buildGoogleLoginButton(isTablet),
                                  SizedBox(height: isTablet ? 20 : 16),
                                  _buildFooter(isTablet),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // HORIZONTAL: TEXTO ADAPTATIVO Y FLEXIBLE
                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: contentMaxWidth,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLogoSection(logoSize, isTablet),
                                SizedBox(height: isTablet ? 24 : 18),
                                // TEXTO DE BIENVENIDA ADAPTATIVO
                                Flexible(
                                  child: Text(
                                    'Bienvenido',
                                    style: TextStyle(
                                      fontSize: isTablet
                                          ? (screenWidth > 900 ? 32 : 24)
                                          : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: isTablet ? 8 : 6),
                                Flexible(
                                  child: Text(
                                    'Inicia sesión para continuar con B-MaiA',
                                    style: TextStyle(
                                      fontSize: isTablet
                                          ? (screenWidth > 900 ? 16 : 13)
                                          : 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: contentMaxWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalPadding,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLoginForm(isTablet),
                                  SizedBox(height: isTablet ? 24 : 20),
                                  _buildGoogleLoginButton(isTablet),
                                  SizedBox(height: isTablet ? 20 : 16),
                                  _buildFooter(isTablet),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: _handleBackButton,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(double logoSize, bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2f43a7).withValues(alpha: 0.9),
                const Color(0xFF4a5bb8).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2f43a7).withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: logoSize,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            hintText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            isTablet: isTablet,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          CustomTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            hintText: 'Contraseña',
            obscureText: !_isPasswordVisible,
            prefixIcon: Icons.lock_outline_rounded,
            isTablet: isTablet,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: isTablet ? 20 : 18,
              ),
            ),
            onSubmitted: (_) => _handleEmailLogin(),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingEmail ? null : _handleEmailLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4a5bb8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: const Color(0xFF4a5bb8).withValues(alpha: 0.4),
              ),
              child: _isLoadingEmail
                  ? SizedBox(
                      height: isTablet ? 20 : 18,
                      width: isTablet ? 20 : 18,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleLoginButton(bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'o continúa con',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingGoogle ? null : _handleGoogleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                elevation: 6,
                shadowColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: _isLoadingGoogle
                  ? SizedBox(
                      height: isTablet ? 20 : 18,
                      width: isTablet ? 20 : 18,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black87,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          height: isTablet ? 22 : 18,
                          width: isTablet ? 22 : 18,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Continuar con Google',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              // TODO: Implementar recuperación de contraseña
            },
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                color: const Color(0xFF4a5bb8),
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta? ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isTablet ? 12 : 11,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navegar a pantalla de registro
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Regístrate',
                  style: TextStyle(
                    color: const Color(0xFF4a5bb8),
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
