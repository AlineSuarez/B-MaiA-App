import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class BackgroundGradient extends StatelessWidget {
  final Widget child;
  const BackgroundGradient({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final platform = MediaQuery.of(context).platformBrightness;
    final themeMode = provider.themeMode;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platform == Brightness.dark);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF000000), Color(0xFF1b1f37)]
              : const [
                  Color(0xFFF0F4FF),
                  Color(0xFFE8EFFF),
                ],
          stops: const [0.25, 0.75],
        ),
      ),
      child: child,
    );
  }
}
