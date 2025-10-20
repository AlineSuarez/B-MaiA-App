import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/background_gradient.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        // CORREGIDO: Los iconos oscuros se ven bien en fondo claro
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        // CORREGIDO: Brightness.light significa fondo oscuro, Brightness.dark significa fondo claro
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

  String _themeLabel(ThemeMode mode, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  void _openThemeModal(
    BuildContext context,
    ThemeMode current,
    ThemeProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final platform = MediaQuery.of(context).platformBrightness;
            final orientation = MediaQuery.of(context).orientation;
            final screenHeight = MediaQuery.of(context).size.height;
            final isLandscape = orientation == Orientation.landscape;

            final isDarkModal =
                current == ThemeMode.dark ||
                (current == ThemeMode.system && platform == Brightness.dark);

            return Container(
              constraints: BoxConstraints(
                maxHeight: isLandscape
                    ? screenHeight * 0.9
                    : screenHeight * 0.6,
              ),
              decoration: BoxDecoration(
                color: isDarkModal ? const Color(0xFF23234A) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle del modal
                      Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(
                          top: isLandscape ? 8 : 12,
                          bottom: isLandscape ? 4 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkModal
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Título del modal
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isLandscape ? 8 : 16,
                          horizontal: 20,
                        ),
                        child: Text(
                          l10n.selectTheme,
                          style: TextStyle(
                            fontSize: isLandscape ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkModal
                                ? Colors.white
                                : const Color(0xFF2f43a7),
                          ),
                        ),
                      ),

                      // Opciones de tema adaptativas
                      if (isLandscape)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildModalOption(
                                  context: ctx,
                                  title: l10n.systemTheme,
                                  subtitle: l10n.systemThemeSubtitle,
                                  icon: Icons.settings_suggest_rounded,
                                  value: ThemeMode.system,
                                  current: current,
                                  onTap: () {
                                    provider.setThemeMode(ThemeMode.system);
                                    Navigator.of(ctx).pop();
                                  },
                                  isDark: isDarkModal,
                                  isLandscape: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildModalOption(
                                  context: ctx,
                                  title: l10n.lightMode,
                                  subtitle: l10n.lightModeSubtitle,
                                  icon: Icons.light_mode_rounded,
                                  value: ThemeMode.light,
                                  current: current,
                                  onTap: () {
                                    provider.setThemeMode(ThemeMode.light);
                                    Navigator.of(ctx).pop();
                                  },
                                  isDark: isDarkModal,
                                  isLandscape: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildModalOption(
                                  context: ctx,
                                  title: l10n.darkMode,
                                  subtitle: l10n.darkModeSubtitle,
                                  icon: Icons.dark_mode_rounded,
                                  value: ThemeMode.dark,
                                  current: current,
                                  onTap: () {
                                    provider.setThemeMode(ThemeMode.dark);
                                    Navigator.of(ctx).pop();
                                  },
                                  isDark: isDarkModal,
                                  isLandscape: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        // Opciones verticales en portrait
                        Column(
                          children: [
                            _buildModalOption(
                              context: ctx,
                              title: l10n.themeSystem,
                              subtitle: l10n.useSystemTheme,
                              icon: Icons.settings_suggest_rounded,
                              value: ThemeMode.system,
                              current: current,
                              onTap: () {
                                provider.setThemeMode(ThemeMode.system);
                                Navigator.of(ctx).pop();
                              },
                              isDark: isDarkModal,
                              isLandscape: false,
                            ),
                            _buildModalOption(
                              context: ctx,
                              title: l10n.themeLight,
                              subtitle: l10n.lightModeSubtitle,
                              icon: Icons.light_mode_rounded,
                              value: ThemeMode.light,
                              current: current,
                              onTap: () {
                                provider.setThemeMode(ThemeMode.light);
                                Navigator.of(ctx).pop();
                              },
                              isDark: isDarkModal,
                              isLandscape: false,
                            ),
                            _buildModalOption(
                              context: ctx,
                              title: l10n.themeDark,
                              subtitle: l10n.darkModeSubtitle,
                              icon: Icons.dark_mode_rounded,
                              value: ThemeMode.dark,
                              current: current,
                              onTap: () {
                                provider.setThemeMode(ThemeMode.dark);
                                Navigator.of(ctx).pop();
                              },
                              isDark: isDarkModal,
                              isLandscape: false,
                            ),
                          ],
                        ),

                      SizedBox(height: isLandscape ? 12 : 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode current,
    required VoidCallback onTap,
    required bool isDark,
    required bool isLandscape,
  }) {
    final isSelected = value == current;

    if (isLandscape) {
      // Diseño compacto para landscape
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: isSelected ? 0.1 : 0.03)
                : isSelected
                ? const Color(0xFF2f43a7).withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: isSelected ? 0.2 : 0.05)
                  : const Color(
                      0xFF2f43a7,
                    ).withValues(alpha: isSelected ? 0.3 : 0.08),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white : const Color(0xFF2f43a7),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2f43a7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey[600],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: const Color(0xFF2f43a7),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Diseño normal para portrait - CORREGIDO: Sin Radio deprecado
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: isSelected ? 0.1 : 0.03)
            : isSelected
            ? const Color(0xFF2f43a7).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: isSelected ? 0.2 : 0.05)
              : const Color(
                  0xFF2f43a7,
                ).withValues(alpha: isSelected ? 0.3 : 0.08),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF2f43a7),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2f43a7),
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        // CORREGIDO: Reemplazar Radio deprecado por Icon visual
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2f43a7)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.grey[400]!),
              width: 2,
            ),
            color: isSelected ? const Color(0xFF2f43a7) : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        onTap: onTap,
      ),
    );
  }

  void _openLanguageModal(BuildContext context, LocaleProvider localeProvider) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
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
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Text(
                    l10n.selectLanguage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2f43a7),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Text('🇪🇸', style: TextStyle(fontSize: 28)),
                  title: Text(
                    l10n.spanish,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2f43a7),
                      fontWeight: localeProvider.locale.languageCode == 'es'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: localeProvider.locale.languageCode == 'es'
                      ? Icon(
                          Icons.check_circle,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2f43a7),
                        )
                      : null,
                  onTap: () {
                    localeProvider.setLocale(const Locale('es'));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇬🇧', style: TextStyle(fontSize: 28)),
                  title: Text(
                    l10n.english,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2f43a7),
                      fontWeight: localeProvider.locale.languageCode == 'en'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: localeProvider.locale.languageCode == 'en'
                      ? Icon(
                          Icons.check_circle,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2f43a7),
                        )
                      : null,
                  onTap: () {
                    localeProvider.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = themeProvider.themeMode;
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
            l10n.settings,
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
                // Sección Apariencia
                _buildSectionTitle(l10n.appearance, isDark),
                _buildSimpleTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: l10n.theme,
                  subtitle: _themeLabel(themeMode, context),
                  onTap: () =>
                      _openThemeModal(context, themeMode, themeProvider),
                  isTablet: isTablet,
                  darkMode: isDark,
                ),

                SizedBox(height: isTablet ? 32 : 20),

                // Sección Aplicación
                _buildSectionTitle(l10n.application, isDark),
                _buildSimpleTile(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsSubtitle,
                  onTap: () {},
                  isTablet: isTablet,
                  darkMode: isDark,
                ),
                _buildSimpleTile(
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: localeProvider.getLanguageName(),
                  onTap: () => _openLanguageModal(context, localeProvider),
                  isTablet: isTablet,
                  darkMode: isDark,
                ),
                _buildSimpleTile(
                  icon: Icons.help_outline_rounded,
                  title: l10n.helpSupport,
                  subtitle: l10n.helpSupportSubtitle,
                  onTap: () {},
                  isTablet: isTablet,
                  darkMode: isDark,
                ),
                _buildSimpleTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.about,
                  subtitle: l10n.aboutSubtitle,
                  onTap: () {},
                  isTablet: isTablet,
                  darkMode: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.7)
              : const Color(0xFF2f43a7).withValues(alpha: 0.9),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
    required bool darkMode,
  }) {
    return Card(
      color: darkMode
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.95),
      elevation: darkMode ? 0 : 2,
      shadowColor: darkMode ? null : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: darkMode
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF2f43a7).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: darkMode ? Colors.white : const Color(0xFF2f43a7),
          size: isTablet ? 28 : 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 16 : 14,
            color: darkMode ? Colors.white : const Color(0xFF2f43a7),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 13 : 11,
            color: darkMode
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey[700],
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 12,
          vertical: isTablet ? 8 : 4,
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: darkMode
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.grey[600],
        ),
      ),
    );
  }
}
