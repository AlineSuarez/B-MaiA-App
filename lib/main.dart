import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    // 1) si no vio onboarding -> onboarding
    if (!seenOnboarding) return const OnboardingScreen();

    // 2) si no hay token -> login (y limpiamos residuos de isLoggedIn)
    final hasToken = await ApiClient().hasToken();
    if (!hasToken) {
      if ((prefs.getBool('isLoggedIn') ?? false) == true) {
        await prefs.setBool('isLoggedIn', false); // migración/limpieza
      }
      return const LoginScreen();
    }

    // 3) hay token -> validamos contra /user
    try {
      await AuthService().me(); // 200 OK => token válido
      return const HomeScreen();
    } catch (_) {
      // token inválido / expirado -> limpiamos y vamos a login
      await ApiClient().clearToken();
      await prefs.setBool('isLoggedIn', false);
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'B-MaiA',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es'), Locale('en')],
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2f43a7),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF181824),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2f43a7),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: FutureBuilder<Widget>(
              future: _getInitialScreen(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2f43a7),
                      ),
                    ),
                  );
                }
                return snapshot.data!;
              },
            ),
          );
        },
      ),
    );
  }
}
