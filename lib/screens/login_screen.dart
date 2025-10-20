import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final _auth = AuthService();
  final GoogleSignIn _gsi = GoogleSignIn(
    serverClientId:
        '32045614003-h4vnlp4qqa1bb7atade1ifgn08v10oip.apps.googleusercontent.com',
    scopes: <String>['email', 'profile'],
  );

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
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _showErrorMessage(l10n.requiredFields);
      return;
    }

    setState(() => _isLoadingEmail = true);

    try {
      // 1) Login (AuthService guarda el token en ApiClient)
      final data = await _auth.login(email: email, password: pass);

      // 2) (Opcional) traer perfil y cachearlo para otras pantallas
      try {
        final me = await _auth.me(); // GET /user con el token recién guardado
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('me', me.toString()); // o jsonEncode(me)
        await prefs.setString('userEmail', data['user']?['email'] ?? email);
      } catch (_) {
        // Si falla /user no es crítico: ya tenemos token válido
      }

      if (!mounted) return;

      // 3) Mensaje de bienvenida
      final nombre = (data['user']?['name'] ?? '').toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nombre.isNotEmpty
                ? '${l10n.welcomeBack} $nombre!'
                : l10n.loginSuccess,
          ),
        ),
      );

      // 4) Ir al Home
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showErrorMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoadingGoogle = true);

    try {
      // 1) Selector de cuenta
      final GoogleSignInAccount? account = await _gsi.signIn();
      if (account == null) {
        // usuario canceló
        setState(() => _isLoadingGoogle = false);
        return;
      }

      // 2) Tokens de Google
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      if (idToken == null) throw Exception('Google token error');

      // 3) Login en tu API con el id_token
      final data = await _auth.loginWithGoogle(idToken: idToken);

      // 4) (opcional) cachear /user
      try {
        final me = await _auth.me();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('me', me.toString());
        await prefs.setString('userEmail', data['user']?['email'] ?? '');
      } catch (_) {}

      // 5) (opcional) marcar bandera local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loginMethod', 'google');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.welcome)));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showErrorMessage(e.toString().replaceFirst('Exception: ', ''));
      // limpia sesión parcial de Google si algo falló
      try {
        await _gsi.signOut();
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
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
    final l10n = AppLocalizations.of(context)!;
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
                                    l10n.welcome,
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
                                    l10n.signInToContinue,
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
                                  _buildLoginForm(l10n, isTablet),
                                  SizedBox(height: isTablet ? 24 : 20),
                                  _buildGoogleLoginButton(l10n, isTablet),
                                  SizedBox(height: isTablet ? 20 : 16),
                                  _buildFooter(l10n, isTablet),
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
                                    l10n.welcome,
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
                                    l10n.signInToContinue,
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
                                  _buildLoginForm(l10n, isTablet),
                                  SizedBox(height: isTablet ? 24 : 20),
                                  _buildGoogleLoginButton(l10n, isTablet),
                                  SizedBox(height: isTablet ? 20 : 16),
                                  _buildFooter(l10n, isTablet),
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

  Widget _buildLoginForm(AppLocalizations l10n, bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            hintText: l10n.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            isTablet: isTablet,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          CustomTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            hintText: l10n.password,
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
                      l10n.login,
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

  Widget _buildGoogleLoginButton(AppLocalizations l10n, bool isTablet) {
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
                  l10n.orWord,
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
                          l10n.continueWithGoogle,
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

  Widget _buildFooter(AppLocalizations l10n, bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: Text(
              l10n.forgotPassword,
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
                l10n.noAccount,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isTablet ? 12 : 11,
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.register,
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
