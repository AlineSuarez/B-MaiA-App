import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _auth = AuthService();

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
    Future.delayed(const Duration(milliseconds: 200), _slideController.forward);
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
    final l10n = AppLocalizations.of(context)!;

    // Validaciones de UI
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      return _showErrorMessage(l10n.requiredFields);
    }
    if (_nameController.text.trim().length < 3) {
      return _showErrorMessage('Name must be at least 3 characters long');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      return _showErrorMessage(l10n.invalidEmail);
    }
    if (_passwordController.text.length < 6) {
      return _showErrorMessage(l10n.passwordTooShort(6));
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      return _showErrorMessage(l10n.passwordMismatch);
    }
    if (!_acceptTerms) {
      return _showErrorMessage(l10n.acceptTerms);
    }

    setState(() => _isLoadingEmail = true);

    try {
      // Llamada real al backend: /api/v1/register
      final data = await _auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Persistimos sesión mínima y el perfil
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString(
        'userEmail',
        data['user']?['email'] ?? _emailController.text.trim(),
      );

      if (data['user'] != null) {
        await prefs.setString('me', jsonEncode(data['user']));
      } else {
        // Si por alguna razón el endpoint no devuelve user, 'me' lo trae:
        final me = await _auth.me();
        await prefs.setString('me', jsonEncode(me));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.registerSuccess)));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showErrorMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoadingGoogle = true);
    // Aquí iría tu flujo de Google Sign-In si lo integras luego
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoadingGoogle = false);
      _showErrorMessage(l10n.featureInDevelopment);
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

  void _handleBackButton() => Navigator.of(context).pop();

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
              final form = Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogoSection(logoSize, isTablet),
                        SizedBox(height: isTablet ? 32 : 24),
                        _buildTitle(l10n, isTablet),
                        SizedBox(height: isTablet ? 32 : 24),
                        _buildRegisterForm(l10n, isTablet),
                        SizedBox(height: isTablet ? 24 : 20),
                        _buildGoogleRegisterButton(l10n, isTablet),
                        SizedBox(height: isTablet ? 20 : 16),
                        _buildFooter(l10n, isTablet),
                      ],
                    ),
                  ),
                ),
              );

              if (!isLandscape) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(children: [_buildHeader(), form]),
                  ),
                );
              } else {
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
                                Flexible(child: _buildTitle(l10n, isTablet)),
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
                            child: form,
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

  Widget _buildTitle(AppLocalizations l10n, bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Text(
            l10n.createAccount,
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
            l10n.joinBMaia,
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

  Widget _buildRegisterForm(AppLocalizations l10n, bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            hintText: l10n.fullName,
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            isTablet: isTablet,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          SizedBox(height: isTablet ? 16 : 12),
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
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
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
            hintText: l10n.confirmPassword,
            obscureText: !_isConfirmPasswordVisible,
            prefixIcon: Icons.lock_outline_rounded,
            isTablet: isTablet,
            suffixIcon: IconButton(
              onPressed: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
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
          _buildTermsCheckbox(l10n, isTablet),
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
                      l10n.register,
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

  Widget _buildTermsCheckbox(AppLocalizations l10n, bool isTablet) {
    return Row(
      children: [
        SizedBox(
          height: isTablet ? 24 : 20,
          width: isTablet ? 24 : 20,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
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
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            children: [
              Text(
                l10n
                    .acceptTermsMessage(l10n.termsAndConditions)
                    .split(l10n.termsAndConditions)[0],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isTablet ? 12 : 11,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  l10n.termsAndConditions,
                  style: TextStyle(
                    color: const Color(0xFF4a5bb8),
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleRegisterButton(AppLocalizations l10n, bool isTablet) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 1, decoration: _gradLine())),
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
              Expanded(child: Container(height: 1, decoration: _gradLine())),
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
                        const SizedBox(width: 12),
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

  BoxDecoration _gradLine() => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.transparent,
        Colors.white.withValues(alpha: 0.3),
        Colors.transparent,
      ],
    ),
  );

  Widget _buildFooter(AppLocalizations l10n, bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.alreadyHaveAccount,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isTablet ? 12 : 11,
            ),
          ),
          const SizedBox(width: 2),
          TextButton(
            onPressed: _handleBackButton,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.login,
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
