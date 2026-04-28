import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _teal = Color(0xFF00695C);
  static const _amber = Color(0xFFFFA000);
  static const _red = Color(0xFFD32F2F);
  static const _green = Color(0xFF388E3C);

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: _teal,
      primary: _teal,
      secondary: _amber,
      error: _red,
      brightness: Brightness.light,
    );
    return _buildTheme(base);
  }

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: _teal,
      primary: const Color(0xFF4DB6AC),
      secondary: _amber,
      error: const Color(0xFFEF9A9A),
      brightness: Brightness.dark,
    );
    return _buildTheme(base);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final headlineFont = GoogleFonts.poppinsTextTheme();
    final bodyFont = GoogleFonts.interTextTheme();

    final textTheme = bodyFont.copyWith(
      displayLarge: headlineFont.displayLarge,
      displayMedium: headlineFont.displayMedium,
      displaySmall: headlineFont.displaySmall,
      headlineLarge: headlineFont.headlineLarge,
      headlineMedium: headlineFont.headlineMedium,
      headlineSmall: headlineFont.headlineSmall,
      titleLarge: headlineFont.titleLarge,
      titleMedium: headlineFont.titleMedium,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      extensions: [
        AppColors(success: _green, critical: _red),
      ],
    );
  }
}

class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color critical;

  const AppColors({required this.success, required this.critical});

  @override
  AppColors copyWith({Color? success, Color? critical}) =>
      AppColors(success: success ?? this.success, critical: critical ?? this.critical);

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
    );
  }
}
