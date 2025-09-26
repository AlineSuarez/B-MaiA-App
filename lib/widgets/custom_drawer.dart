import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:bmaia/screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el estado del tema
    final provider = Provider.of<ThemeProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = provider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isTablet = screenWidth > 600;

    // Ajustar ancho del drawer según orientación
    final drawerWidth = isLandscape
        ? (isTablet ? 320.0 : screenWidth * 0.75)
        : (isTablet ? 380.0 : screenWidth * 0.88);

    return Container(
      width: drawerWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        // Degradado adaptativo según el tema
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0A0A0B), Color(0xFF141419), Color(0xFF1A1A23)]
              : const [Color(0xFFF8F9FF), Color(0xFFEEF2FF), Color(0xFFE8EFFF)],
          stops: const [0.0, 0.4, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF2f43a7).withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header minimalista - FIJO
          _buildHeader(isTablet, isLandscape, isDark),

          // Divider sutil - FIJO
          _buildDivider(isDark),

          // Área de scroll que incluye Nueva conversación + Historial
          Expanded(
            child: _buildScrollableContent(
              isTablet,
              isLandscape,
              context,
              isDark,
            ),
          ),

          // Footer minimalista - FIJO (siempre abajo)
          _buildFooter(isTablet, isLandscape, context, isDark),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
    bool isTablet,
    bool isLandscape,
    BuildContext context,
    bool isDark,
  ) {
    final chats = [
      {'title': 'Flutter Development', 'time': '2m', 'isActive': true},
      {'title': 'Python & Data Science', 'time': '1h', 'isActive': false},
      {'title': 'AI & Neural Networks', 'time': '3h', 'isActive': false},
      {'title': 'Advanced Mathematics', 'time': '1d', 'isActive': false},
      {'title': 'UI/UX Design 2025', 'time': '2d', 'isActive': false},
      {'title': 'Cloud Architecture', 'time': '3d', 'isActive': false},
      {'title': 'React Native', 'time': '4d', 'isActive': false},
      {'title': 'Machine Learning', 'time': '5d', 'isActive': false},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // Nuevo Chat minimalista - ahora hace scroll
        _buildNewChatButton(isTablet, isLandscape, context, isDark),

        // Espaciado elegante - reducido en horizontal
        SizedBox(height: isLandscape ? 12 : (isTablet ? 24 : 16)),

        // Header del historial
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 24,
            vertical: isLandscape
                ? (isTablet ? 6 : 4)
                : (isTablet ? 8 : 6), // Menos padding en horizontal
          ),
          child: Row(
            children: [
              Text(
                'Historial',
                style: TextStyle(
                  fontSize: isLandscape
                      ? (isTablet ? 12 : 11)
                      : (isTablet ? 14 : 12),
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF2f43a7).withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFF2f43a7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${chats.length}',
                  style: TextStyle(
                    fontSize: isLandscape
                        ? (isTablet ? 10 : 9)
                        : (isTablet ? 11 : 10),
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF2f43a7).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: isLandscape ? (isTablet ? 8 : 6) : (isTablet ? 12 : 8),
        ),

        // Lista de chats del historial
        ...chats.map(
          (chat) => Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: _buildChatItem(chat, isTablet, isLandscape, context, isDark),
          ),
        ),

        // Espaciado extra al final para evitar que el último item quede muy pegado al footer
        SizedBox(height: isLandscape ? 16 : 24),
      ],
    );
  }

  Widget _buildHeader(bool isTablet, bool isLandscape, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 24,
        isLandscape
            ? (isTablet ? 32 : 24)
            : (isTablet ? 48 : 32), // Menos padding top en horizontal
        isTablet ? 32 : 24,
        isLandscape
            ? (isTablet ? 16 : 12)
            : (isTablet ? 24 : 20), // Menos padding bottom en horizontal
      ),
      child: Row(
        children: [
          // Logo moderno con glassmorphism - más pequeño en horizontal
          Container(
            padding: EdgeInsets.all(
              isLandscape ? (isTablet ? 12 : 10) : (isTablet ? 16 : 14),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2f43a7).withValues(alpha: 0.9),
                  const Color(0xFF4a5bb8).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                isLandscape ? (isTablet ? 16 : 14) : (isTablet ? 20 : 16),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2f43a7).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: isLandscape ? (isTablet ? 22 : 20) : (isTablet ? 28 : 24),
            ),
          ),

          SizedBox(width: isTablet ? 20 : 16),

          // Texto con tipografía moderna - más compacto en horizontal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'B-MaiA',
                  style: TextStyle(
                    fontSize: isLandscape
                        ? (isTablet ? 20 : 18)
                        : (isTablet ? 24 : 20),
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF2f43a7),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF2f43a7).withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatButton(
    bool isTablet,
    bool isLandscape,
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 24,
        vertical: isLandscape
            ? (isTablet ? 8 : 6)
            : (isTablet ? 12 : 8), // Menos margin en horizontal
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            // TODO: Implementar nuevo chat
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isLandscape
                  ? (isTablet ? 10 : 8)
                  : (isTablet ? 12 : 10), // Menos padding en horizontal
            ),
            child: Row(
              children: [
                Text(
                  'Nueva conversación',
                  style: TextStyle(
                    fontSize: isLandscape
                        ? (isTablet ? 14 : 12)
                        : (isTablet ? 16 : 14),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF2f43a7).withValues(alpha: 0.9),
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.add_rounded,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF2f43a7).withValues(alpha: 0.7),
                  size: isLandscape
                      ? (isTablet ? 18 : 16)
                      : (isTablet ? 20 : 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(
    Map<String, dynamic> chat,
    bool isTablet,
    bool isLandscape,
    BuildContext context,
    bool isDark,
  ) {
    final isActive = chat['isActive'] as bool;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLandscape ? (isTablet ? 6 : 4) : (isTablet ? 8 : 6),
      ), // Menos margin en horizontal
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            // TODO: Cargar chat específico
          },
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 14,
              vertical: isLandscape
                  ? (isTablet ? 10 : 8)
                  : (isTablet ? 14 : 12), // Menos padding en horizontal
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(
                      0xFF2f43a7,
                    ).withValues(alpha: isDark ? 0.15 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
              border: Border.all(
                color: isActive
                    ? const Color(
                        0xFF2f43a7,
                      ).withValues(alpha: isDark ? 0.3 : 0.25)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Indicador de estado - más pequeño en horizontal
                Container(
                  width: isLandscape ? (isTablet ? 5 : 4) : (isTablet ? 6 : 5),
                  height: isLandscape ? (isTablet ? 5 : 4) : (isTablet ? 6 : 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4a5bb8)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : const Color(0xFF2f43a7).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(width: isTablet ? 12 : 10),

                // Título del chat
                Expanded(
                  child: Text(
                    chat['title']!,
                    style: TextStyle(
                      fontSize: isLandscape
                          ? (isTablet ? 12 : 11)
                          : (isTablet ? 14 : 13),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? isDark
                                ? Colors.white
                                : const Color(0xFF2f43a7)
                          : isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF2f43a7).withValues(alpha: 0.8),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Tiempo - más discreto
                Text(
                  chat['time']!,
                  style: TextStyle(
                    fontSize: isLandscape
                        ? (isTablet ? 9 : 8)
                        : (isTablet ? 11 : 10),
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : const Color(0xFF2f43a7).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    bool isTablet,
    bool isLandscape,
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 24,
        isLandscape ? (isTablet ? 12 : 10) : (isTablet ? 20 : 16),
        isTablet ? 32 : 24,
        isLandscape ? (isTablet ? 16 : 12) : (isTablet ? 32 : 24),
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFF2f43a7).withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildFooterItem(
            icon: Icons.settings_rounded,
            title: 'Configuración',
            isTablet: isTablet,
            isLandscape: isLandscape,
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          SizedBox(
            height: isLandscape ? (isTablet ? 8 : 6) : (isTablet ? 12 : 8),
          ),
          _buildFooterItem(
            icon: Icons.person_rounded,
            title: 'Mi Cuenta',
            isTablet: isTablet,
            isLandscape: isLandscape,
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              // TODO: Abrir perfil
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String title,
    required bool isTablet,
    required bool isLandscape,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isLandscape
                ? (isTablet ? 8 : 6)
                : (isTablet ? 12 : 10), // Menos padding en horizontal
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF2f43a7).withValues(alpha: 0.8),
                size: isLandscape
                    ? (isTablet ? 18 : 16)
                    : (isTablet ? 20 : 18), // Más pequeño en horizontal
              ),

              SizedBox(width: isTablet ? 12 : 10),

              Text(
                title,
                style: TextStyle(
                  fontSize: isLandscape
                      ? (isTablet ? 12 : 11)
                      : (isTablet ? 14 : 13), // Más pequeño en horizontal
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : const Color(0xFF2f43a7).withValues(alpha: 0.8),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
