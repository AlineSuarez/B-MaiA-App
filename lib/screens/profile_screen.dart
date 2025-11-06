import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/background_gradient.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';
import '../providers/locale_provider.dart';
import 'login_screen.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ------------------------------
  // Estado general
  // ------------------------------
  bool _loading = true;

  // Datos de perfil (se muestran como “—” si faltan)
  String? _avatarUrl;
  String? _profileImagePath; // preview local al elegir imagen

  String? _nombres;
  String? _apellidos;
  String? _correo;
  String? _telefono;
  String? _memberSince;

  String? _rut;
  String? _razonSocial;
  String? _direccion;
  String? _sagRegistro;

  // Región/Comuna: pueden venir como IDs => resolvemos nombres vía lookups
  int? _idRegion;
  int? _idComuna;
  String? _regionName; // nombre ya resuelto (o provisto por API)
  String? _comunaName;

  // lookups cacheados en memoria (1 solo fetch por sesión de pantalla)
  Map<int, String> _regionesMap = {};
  Map<int, String> _comunasMap = {};

  final ImagePicker _picker = ImagePicker();
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSystemUI();
  }

  // Ajusta íconos de status/nav bar según tema actual
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

  // ------------------------------
  // Carga /user y aplica datos
  // ------------------------------
  Future<void> _fetchMe() async {
    try {
      final map = Map<String, dynamic>.from(await _profileService.me());
      final data = map['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['data'])
          : map;

      _applyMe(data);

      // Si hay IDs de región/comuna pero no nombres, los resolvemos una vez
      await _resolveRegionComunaNames();

      if (mounted) setState(() => _loading = false);
    } on DioException catch (e) {
      // Manejo específico de errores HTTP (p. ej. 502)
      final status = e.response?.statusCode;
      final serverMessage = status != null
          ? 'Error del servidor ($status). Inténtalo más tarde.'
          : 'Error de red. Revisa tu conexión.';
      if (mounted) {
        setState(() => _loading = false);
        _showErrorMessage(serverMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showErrorMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Toma el map del backend y llena el estado de la UI
  void _applyMe(Map<String, dynamic> m) {
    setState(() {
      // Básicos
      _nombres = m['name']?.toString();
      _apellidos = m['last_name']?.toString();
      _correo = m['email']?.toString();
      _telefono = (m['telefono'] ?? m['phone'])?.toString();

      // Fecha de creación / membresía
      _memberSince = (m['created_at'] ?? m['member_since'])?.toString();

      // Legales
      _rut = m['rut']?.toString();
      _razonSocial = m['razon_social']?.toString();
      _sagRegistro = (m['numero_registro'] ?? m['sag_registro'])?.toString();

      // Ubicación: ids y posibles nombres embebidos
      _idRegion = (m['id_region'] as num?)?.toInt();
      _idComuna = (m['id_comuna'] as num?)?.toInt();

      final region = m['region'];
      if (region is Map) _regionName = region['name']?.toString();
      if (region is String) _regionName = region;

      final comuna = m['comuna'];
      if (comuna is Map) _comunaName = comuna['name']?.toString();
      if (comuna is String) _comunaName = comuna;

      _direccion = (m['direccion'] ?? m['address'])?.toString();

      // Avatar: puede venir relativo => construimos URL absoluta
      final pp = (m['profile_picture'] ?? m['avatar_url'])?.toString();
      _avatarUrl = _resolveUrl(pp);
    });
  }

  // Si solo tenemos IDs, pegamos a /regiones y /comunas y mapeamos nombres
  Future<void> _resolveRegionComunaNames() async {
    try {
      final dio = ApiClient().dio;

      if (_regionName == null && _idRegion != null) {
        await _loadLookupsIfNeeded(dio);
        _regionName = _regionesMap[_idRegion!];
      }
      if (_comunaName == null && _idComuna != null) {
        await _loadLookupsIfNeeded(dio);
        _comunaName = _comunasMap[_idComuna!];
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _loadLookupsIfNeeded(Dio dio) async {
    if (_regionesMap.isEmpty) {
      try {
        final r = await dio.get('/regiones');
        final list = (r.data is Map && r.data['data'] is List)
            ? List<Map<String, dynamic>>.from(r.data['data'])
            : List<Map<String, dynamic>>.from(r.data as List);
        _regionesMap = {
          for (final e in list)
            (e['id'] as num).toInt(): (e['name'] ?? e['nombre'] ?? '')
                .toString(),
        };
      } on DioException catch (_) {
      } catch (_) {
        /* ignorar */
      }
    }

    if (_comunasMap.isEmpty) {
      try {
        final r = await dio.get('/comunas');
        final list = (r.data is Map && r.data['data'] is List)
            ? List<Map<String, dynamic>>.from(r.data['data'])
            : List<Map<String, dynamic>>.from(r.data as List);
        _comunasMap = {
          for (final e in list)
            (e['id'] as num).toInt(): (e['name'] ?? e['nombre'] ?? '')
                .toString(),
        };
      } on DioException catch (_) {
      } catch (_) {}
    }
  }

  Future<void> _pullToRefresh() => _fetchMe();

  // ------------------------------
  // Helpers de UI
  // ------------------------------
  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _profileImagePath = image.path);
        _showSuccessMessage(l10n.photoSelected);
      }
    } catch (_) {
      _showErrorMessage(l10n.errorImageSelection);
    }
  }

  void _showImageSourceDialog(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.selectPhoto,
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
                  l10n.takePhoto,
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
                  l10n.chooseFromGallery,
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
                    l10n.removePhoto,
                    style: TextStyle(color: Colors.red.withValues(alpha: 0.8)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _profileImagePath = null);
                    _showSuccessMessage(l10n.photoRemoved);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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

  // ------------------------------
  // BUILD
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.myProfile,
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
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _pullToRefresh,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 20,
                        vertical: isTablet ? 32 : 16,
                      ),
                      children: [
                        // Header (avatar + nombre/correo)
                        _buildProfileHeader(l10n, isDark, isTablet),

                        SizedBox(height: isTablet ? 32 : 24),

                        // ------- Datos legales -------
                        _buildSectionTitle(l10n.legalData, isDark),
                        _buildReadOnlyTile(
                          icon: Icons.badge_outlined,
                          title: l10n.legalDataRut,
                          value: _display(_rut),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.apartment_outlined,
                          title: l10n.legalDataBusinessName,
                          value: _display(_razonSocial),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Información personal -------
                        _buildSectionTitle(l10n.personalInfo, isDark),
                        _buildReadOnlyTile(
                          icon: Icons.person_outline_rounded,
                          title: l10n.firstName,
                          value: _display(_nombres),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.person_2_outlined,
                          title: l10n.lastName,
                          value: _display(_apellidos),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.email_outlined,
                          title: l10n.email,
                          value: _display(_correo),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.phone_outlined,
                          title: l10n.phone,
                          value: _display(_telefono),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Ubicación -------
                        _buildSectionTitle(l10n.location, isDark),
                        _buildReadOnlyTile(
                          icon: Icons.map_outlined,
                          title: l10n.region,
                          value: _display(_regionName),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.location_city_outlined,
                          title: l10n.commune,
                          value: _display(_comunaName),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildReadOnlyTile(
                          icon: Icons.place_outlined,
                          title: l10n.address,
                          value: _display(_direccion),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Registro SAG -------
                        _buildSectionTitle('Registro SAG', isDark),
                        _buildReadOnlyTile(
                          icon: Icons.numbers_outlined,
                          title: l10n.sagRegistryNumber,
                          value: _display(_sagRegistro),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Seguridad -------
                        _buildSectionTitle(l10n.security, isDark),
                        _buildActionTile(
                          icon: Icons.lock_outline_rounded,
                          title: l10n.changePassword,
                          subtitle: l10n.changePasswordSubtitle,
                          onTap: () =>
                              _showErrorMessage(l10n.featureInDevelopment),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildActionTile(
                          icon: Icons.verified_user_outlined,
                          title: l10n.twoFactorAuth,
                          subtitle: l10n.twoFactorAuthSubtitle,
                          onTap: () =>
                              _showErrorMessage(l10n.featureInDevelopment),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Preferencias -------
                        _buildSectionTitle(l10n.preferences, isDark),
                        _buildActionTile(
                          icon: Icons.language_rounded,
                          title: l10n.language,
                          subtitle: Provider.of<LocaleProvider>(
                            context,
                          ).getLanguageName(),
                          onTap: () =>
                              _showErrorMessage(l10n.featureInDevelopment),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),
                        _buildActionTile(
                          icon: Icons.storage_rounded,
                          title: l10n.dataManagement,
                          subtitle: l10n.dataManagementSubtitle,
                          onTap: () =>
                              _showErrorMessage(l10n.featureInDevelopment),
                          isTablet: isTablet,
                          isDark: isDark,
                        ),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Suscripción -------
                        _buildSectionTitle(l10n.subscription, isDark),
                        _buildSubscriptionCard(l10n, isDark, isTablet),

                        SizedBox(height: isTablet ? 24 : 16),

                        // ------- Cuenta -------
                        _buildSectionTitle(l10n.account, isDark),
                        _buildInfoCard(l10n, isDark, isTablet),

                        SizedBox(height: isTablet ? 32 : 24),

                        // ------- Acciones -------
                        _buildActionButton(
                          text: l10n.logout,
                          icon: Icons.logout_rounded,
                          color: Colors.orange,
                          onTap: () => _showLogoutDialog(l10n, isDark),
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        _buildActionButton(
                          text: l10n.deleteAccount,
                          icon: Icons.delete_forever_rounded,
                          color: Colors.red,
                          onTap: () => _showDeleteAccountDialog(l10n, isDark),
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // Widgets de UI
  // ------------------------------
  Widget _buildProfileHeader(
    AppLocalizations l10n,
    bool isDark,
    bool isTablet,
  ) {
    final nameForHeader = _display(_nombres);
    final emailForHeader = _display(_correo);

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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2f43a7), Color(0xFF4a5bb8)],
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
                    : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(_avatarUrl!, fit: BoxFit.cover),
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
            nameForHeader,
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2f43a7),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            emailForHeader,
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

  Widget _buildReadOnlyTile({
    required IconData icon,
    required String title,
    required String value,
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

  Widget _buildSubscriptionCard(
    AppLocalizations l10n,
    bool isDark,
    bool isTablet,
  ) {
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
                        l10n.freePlan,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2f43a7),
                        ),
                      ),
                      Text(
                        l10n.upgradeForMore,
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
                onPressed: () => _showErrorMessage(l10n.featureInDevelopment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2f43a7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.viewPremiumPlans,
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

  Widget _buildInfoCard(AppLocalizations l10n, bool isDark, bool isTablet) {
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
              l10n.memberSince,
              _formatDateDMY(_memberSince),
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
              l10n.userId,
              l10n.notAvailable,
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

  // “—” si vacío
  String _display(String? v) =>
      (v == null || v.trim().isEmpty) ? '—' : v.trim();

  // Formatea ISO / "YYYY-MM-DD HH:mm:ss" a DD-MM-YYYY
  String _formatDateDMY(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    DateTime? dt = DateTime.tryParse(raw);
    dt ??= DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd-$mm-$yyyy';
  }

  // Convierte rutas relativas de imagen en URL absoluta según ApiClient.origin
  String? _resolveUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = ApiClient.origin;
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    // Evita dobles barras, mantiene el esquema
    return '$origin/$cleaned'.replaceAll('//', '/').replaceFirst(':/', '://');
  }

  // ------------------------------
  // Diálogos (logout / eliminar)
  // ------------------------------
  void _showLogoutDialog(AppLocalizations l10n, bool isDark) {
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
              l10n.logout,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.logoutConfirm,
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
            onPressed: () async {
              // Captura el navigator antes del gap async
              final navigator = Navigator.of(context);
              navigator.pop(); // cierra el diálogo

              // Limpia sesión local y token
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('me');
              await prefs.setBool('isLoggedIn', false);
              await prefs.remove('userEmail');
              await prefs.remove('loginMethod');
              await ApiClient().clearToken();

              // Navega a Login sin usar context tras async gap
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AppLocalizations l10n, bool isDark) {
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
                l10n.deleteAccount,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteAccountConfirm,
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
              Navigator.of(context).pop();
              _showErrorMessage(l10n.featureInDevelopment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.8),
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
