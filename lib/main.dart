import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _getSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'B-MaiA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2f43a7)),
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
      home: FutureBuilder<bool>(
        future: _getSeenOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data!
              ? const LoginScreen()
              : const OnboardingScreen();
        },
      ),
    );
  }
}
