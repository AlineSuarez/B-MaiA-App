import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/home/apicultor.png',
      title: '¡Bienvenido a B-MaiA!',
      description:
          'Descubre una nueva forma de gestionar tus proyectos con inteligencia artificial avanzada.',
    ),
    OnboardingPage(
      image: 'assets/images/home/apicultor-2.png',
      title: 'Tecnología Avanzada',
      description:
          'Utilizamos las últimas innovaciones en IA para brindarte la mejor experiencia posible.',
    ),
    OnboardingPage(
      image: 'assets/images/home/apicultor-3.png',
      title: 'Experiencia Personalizada',
      description:
          'Cada función está diseñada pensando en tus necesidades específicas y preferencias.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final orientation = media.orientation;
    final isTablet = screenWidth > 600;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2f43a7), Color(0xFF1e2a78), Color(0xFF4a5bb8)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Botón Skip en la esquina superior derecha
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('seenOnboarding', true);
                          navigator.pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Omitir',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // PageView con las pantallas
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildResponsivePage(
                      _pages[index],
                      isTablet,
                      screenWidth,
                      screenHeight,
                      isLandscape,
                    );
                  },
                ),
              ),

              // Indicadores de página
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),

              // Botón de navegación moderno y pequeño
              Padding(
                padding: EdgeInsets.only(
                  bottom: isTablet ? 32 : 20,
                  right: isTablet ? 32 : 20,
                  left: isTablet ? 32 : 20,
                ),
                child: SizedBox(
                  width: isTablet ? 180 : 140,
                  height: isTablet ? 44 : 38,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        final navigator = Navigator.of(context);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenOnboarding', true);
                        navigator.pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2f43a7),
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 10 : 8,
                        horizontal: isTablet ? 24 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _pages.length - 1
                              ? 'Siguiente'
                              : 'Comenzar',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          _currentPage < _pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_rounded,
                          size: isTablet ? 22 : 18,
                          color: const Color(0xFF2f43a7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método responsivo para cada página (sin icono decorativo)
  Widget _buildResponsivePage(
    OnboardingPage page,
    bool isTablet,
    double screenWidth,
    double screenHeight,
    bool isLandscape,
  ) {
    final imageMaxWidth = isTablet
        ? 480.0
        : screenWidth * 0.75; // Antes: 350.0 / 0.5
    final imageMaxHeight = isTablet
        ? 340.0
        : screenHeight * 0.45; // Antes: 250.0 / 0.35
    final textMaxWidth = isTablet ? 450.0 : screenWidth * 0.7;

    if (!isLandscape) {
      // VERTICAL
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen
            Container(
              constraints: BoxConstraints(
                maxWidth: imageMaxWidth,
                maxHeight: imageMaxHeight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),
            Text(
              page.title,
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Container(
              constraints: BoxConstraints(maxWidth: textMaxWidth),
              child: Text(
                page.description,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      // HORIZONTAL: dos columnas
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Columna izquierda: imagen
            Expanded(
              flex: 5,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: imageMaxWidth,
                    maxHeight: imageMaxHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      page.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: isTablet ? 48 : 24),
            // Columna derecha: texto
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: isTablet
                          ? (screenWidth > 1200 ? 32 : 24)
                          : (screenWidth > 900 ? 22 : 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Container(
                    constraints: BoxConstraints(maxWidth: textMaxWidth),
                    child: Text(
                      page.description,
                      style: TextStyle(
                        fontSize: isTablet
                            ? (screenWidth > 1200 ? 16 : 13)
                            : (screenWidth > 900 ? 13 : 11),
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
