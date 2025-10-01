import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/background_gradient.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  // Datos del usuario simulados
  final String _userName = 'María García';
  final String _userEmail = 'maria.garcia@ejemplo.com';
  final String _userPhone = '+56 9 1234 5678';
  final String _memberSince = 'Enero 2025';

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
            ? const Color(0xFF0F1220)
            : const Color(0xFFF7FBFF),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        _showSuccessMessage('Foto actualizada correctamente');
      }
    } catch (e) {
      _showErrorMessage('Error al seleccionar la imagen');
    }
  }

  void _showImageSourceDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23234A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Seleccionar foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                ),
                title: Text(
                  'Tomar foto',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                ),
                title: Text(
                  'Elegir de galería',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.withValues(alpha: 0.8),
                  ),
                  title: Text(
                    'Eliminar foto',
                    style: TextStyle(color: Colors.red.withValues(alpha: 0.8)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImagePath = null;
                    });
                    _showSuccessMessage('Foto eliminada');
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog({
    required String title,
    required String currentValue,
    required String fieldName,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF23234A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
          ),
          decoration: InputDecoration(
            hintText: 'Ingresa $fieldName',
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2f43a7), width: 2),
            ),
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
              // TODO: Guardar cambios
              Navigator.pop(context);
              _showSuccessMessage('$fieldName actualizado');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2f43a7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF23234A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
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
            onPressed: () async {
              // Guardar el contexto y navigator antes de la operación async
              final navigator = Navigator.of(context);

              // Cerrar el diálogo primero
              navigator.pop();

              // Limpiar estado de sesión
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              await prefs.remove('userEmail');
              await prefs.remove('loginMethod');

              // Verificar mounted antes de usar el context del State
              if (!mounted) return;

              // Navegar a LoginScreen
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF23234A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Eliminar cuenta',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Esta acción es irreversible. Se eliminarán todos tus datos y conversaciones.',
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
              // TODO: Eliminar cuenta
              Navigator.of(context).pop();
              _showErrorMessage('Funcionalidad en desarrollo');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4a5bb8).withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = provider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? const Color(0xFF0F1220)
          : const Color(0xFFF7FBFF),
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: overlayStyle,
          title: Text(
            'Mi Perfil',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF2f43a7),
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
          ),
        ),
        body: BackgroundGradient(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 20,
                vertical: isTablet ? 32 : 16,
              ),
              children: [
                // Foto de perfil
                _buildProfileHeader(isDark, isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Información personal
                _buildSectionTitle('Información Personal', isDark),
                _buildInfoTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Nombre',
                  value: _userName,
                  onTap: () => _showEditDialog(
                    title: 'Editar nombre',
                    currentValue: _userName,
                    fieldName: 'nombre',
                    isDark: isDark,
                  ),
                  isTablet: isTablet,
                  isDark: isDark,
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Correo electrónico',
                  value: _userEmail,
                  onTap: () => _showEditDialog(
                    title: 'Editar correo',
                    currentValue: _userEmail,
                    fieldName: 'correo',
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  isTablet: isTablet,
                  isDark: isDark,
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  title: 'Teléfono',
                  value: _userPhone,
                  onTap: () => _showEditDialog(
                    title: 'Editar teléfono',
                    currentValue: _userPhone,
                    fieldName: 'teléfono',
                    isDark: isDark,
                    keyboardType: TextInputType.phone,
                  ),
                  isTablet: isTablet,
                  isDark: isDark,
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // Seguridad
                _buildSectionTitle('Seguridad', isDark),
                _buildActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Cambiar contraseña',
                  subtitle: 'Actualiza tu contraseña',
                  onTap: () {
                    // TODO: Implementar cambio de contraseña
                    _showErrorMessage('Funcionalidad en desarrollo');
                  },
                  isTablet: isTablet,
                  isDark: isDark,
                ),
                _buildActionTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Autenticación en dos pasos',
                  subtitle: 'Añade una capa extra de seguridad',
                  onTap: () {
                    // TODO: Implementar 2FA
                    _showErrorMessage('Funcionalidad en desarrollo');
                  },
                  isTablet: isTablet,
                  isDark: isDark,
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // Preferencias
                _buildSectionTitle('Preferencias', isDark),
                _buildActionTile(
                  icon: Icons.language_rounded,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () {
                    // TODO: Selector de idioma
                    _showErrorMessage('Funcionalidad en desarrollo');
                  },
                  isTablet: isTablet,
                  isDark: isDark,
                ),
                _buildActionTile(
                  icon: Icons.storage_rounded,
                  title: 'Gestión de datos',
                  subtitle: 'Historial y almacenamiento',
                  onTap: () {
                    // TODO: Gestión de datos
                    _showErrorMessage('Funcionalidad en desarrollo');
                  },
                  isTablet: isTablet,
                  isDark: isDark,
                ),

                SizedBox(height: isTablet ? 32 : 24),

                // Suscripción (si aplica)
                _buildSectionTitle('Suscripción', isDark),
                _buildSubscriptionCard(isDark, isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Información de la cuenta
                _buildSectionTitle('Cuenta', isDark),
                _buildInfoCard(isDark, isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Acciones de cuenta
                _buildActionButton(
                  text: 'Cerrar sesión',
                  icon: Icons.logout_rounded,
                  color: Colors.orange,
                  onTap: () => _showLogoutDialog(isDark),
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 16 : 12),

                _buildActionButton(
                  text: 'Eliminar cuenta',
                  icon: Icons.delete_forever_rounded,
                  color: Colors.red,
                  onTap: () => _showDeleteAccountDialog(isDark),
                  isTablet: isTablet,
                ),

                SizedBox(height: isTablet ? 32 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, bool isTablet) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: isTablet ? 140 : 120,
                height: isTablet ? 140 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2f43a7), const Color(0xFF4a5bb8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2f43a7).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _profileImagePath != null
                    ? ClipOval(
                        child: Image.file(
                          File(_profileImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: isTablet ? 70 : 60,
                        color: Colors.white,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(isDark),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4a5bb8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF0F1220) : Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: isTablet ? 20 : 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            _userName,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2f43a7),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            _userEmail,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : const Color(0xFF2f43a7).withValues(alpha: 0.9),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isDark,
  }) {
    return Card(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.95),
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? null : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF2f43a7).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2f43a7).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
            size: isTablet ? 24 : 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 13 : 11,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 15 : 13,
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
          ),
        ),
        trailing: Icon(
          Icons.edit_outlined,
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.grey[400],
          size: isTablet ? 20 : 18,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 8 : 4,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isDark,
  }) {
    return Card(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.95),
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? null : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF2f43a7).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF2f43a7),
          size: isTablet ? 28 : 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 16 : 14,
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 13 : 11,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey[700],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.grey[600],
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 12,
          vertical: isTablet ? 8 : 4,
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(bool isDark, bool isTablet) {
    return Card(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.95),
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? null : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF2f43a7).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Gratuito',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2f43a7),
                        ),
                      ),
                      Text(
                        'Actualiza para más funciones',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Mostrar planes
                  _showErrorMessage('Funcionalidad en desarrollo');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2f43a7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Ver planes Premium',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, bool isTablet) {
    return Card(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.95),
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? null : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF2f43a7).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            _buildInfoRow(
              'Miembro desde',
              _memberSince,
              Icons.calendar_today_rounded,
              isDark,
              isTablet,
            ),
            Divider(
              height: isTablet ? 24 : 20,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[300],
            ),
            _buildInfoRow(
              'Conversaciones',
              '8',
              Icons.chat_bubble_outline_rounded,
              isDark,
              isTablet,
            ),
            Divider(
              height: isTablet ? 24 : 20,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[300],
            ),
            _buildInfoRow(
              'ID de usuario',
              'USR-${DateTime.now().millisecondsSinceEpoch}',
              Icons.fingerprint_rounded,
              isDark,
              isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
    bool isTablet,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : const Color(0xFF2f43a7).withValues(alpha: 0.7),
          size: isTablet ? 20 : 18,
        ),
        SizedBox(width: isTablet ? 12 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: isTablet ? 20 : 18),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 15 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
