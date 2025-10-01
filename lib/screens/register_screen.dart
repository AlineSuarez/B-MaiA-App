import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _acceptTerms = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailRegister() async {
    // Validaciones
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorMessage('Por favor, completa todos los campos');
      return;
    }

    if (_nameController.text.length < 3) {
      _showErrorMessage('El nombre debe tener al menos 3 caracteres');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showErrorMessage('Por favor, ingresa un correo electrónico válido');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Las contraseñas no coinciden');
      return;
    }

    if (!_acceptTerms) {
      _showErrorMessage('Debes aceptar los términos y condiciones');
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

  Future<void> _handleGoogleRegister() async {
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
    Navigator.of(context).pop();
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
                // VERTICAL
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
                                  _buildTitle(isTablet),
                                  SizedBox(height: isTablet ? 32 : 24),
                                  _buildRegisterForm(isTablet),
                                  SizedBox(height: isTablet ? 24 : 20),
                                  _buildGoogleRegisterButton(isTablet),
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
                // HORIZONTAL
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
                                Flexible(child: _buildTitle(isTablet)),
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
                                  _buildRegisterForm(isTablet),
                                  SizedBox(height: isTablet ? 24 : 20),
                                  _buildGoogleRegisterButton(isTablet),
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
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: logoSize,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Text(
            'Crear Cuenta',
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
            'Únete a B-MaiA y comienza tu experiencia',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            hintText: 'Nombre completo',
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            isTablet: isTablet,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),
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
            onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          CustomTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            hintText: 'Confirmar contraseña',
            obscureText: !_isConfirmPasswordVisible,
            prefixIcon: Icons.lock_outline_rounded,
            isTablet: isTablet,
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                );
              },
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: isTablet ? 20 : 18,
              ),
            ),
            onSubmitted: (_) => _handleEmailRegister(),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildTermsCheckbox(isTablet),
          SizedBox(height: isTablet ? 24 : 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingEmail ? null : _handleEmailRegister,
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
                      'Registrarse',
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

  Widget _buildTermsCheckbox(bool isTablet) {
    return Row(
      children: [
        SizedBox(
          height: isTablet ? 24 : 20,
          width: isTablet ? 24 : 20,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF4a5bb8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'Acepto los ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isTablet ? 12 : 11,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Mostrar términos y condiciones
                },
                child: Text(
                  'términos y condiciones',
                  style: TextStyle(
                    color: const Color(0xFF4a5bb8),
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleRegisterButton(bool isTablet) {
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
                  'o regístrate con',
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
              onPressed: _isLoadingGoogle ? null : _handleGoogleRegister,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿Ya tienes cuenta? ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isTablet ? 12 : 11,
            ),
          ),
          TextButton(
            onPressed: _handleBackButton,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Inicia sesión',
              style: TextStyle(
                color: const Color(0xFF4a5bb8),
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
