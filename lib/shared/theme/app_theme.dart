import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(AppThemeMode themeMode) {
    final colors = _getColorScheme(themeMode);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: themeMode == AppThemeMode.light
            ? Brightness.light
            : Brightness.dark,
        primary: colors.primary,
        onPrimary: themeMode == AppThemeMode.light
            ? Colors.white
            : colors.textPrimary,
        secondary: colors.accent,
        onSecondary: colors.textPrimary,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surfacePrimary,
        onSurface: colors.textPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfacePrimary,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: themeMode == AppThemeMode.light
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: themeMode == AppThemeMode.light
              ? Colors.white
              : colors.textPrimary,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfacePrimary,
        elevation: _getElevation(themeMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _getBorder(themeMode, colors),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfacePrimary,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: _getElevation(themeMode),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        hintStyle: TextStyle(color: colors.textTertiary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfacePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceTertiary,
        contentTextStyle: TextStyle(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [AppColorExtension(colors)],
    );
  }

  static AppColorScheme _getColorScheme(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return AppColors.lightTheme;
      case AppThemeMode.dark:
        return AppColors.darkTheme;
      case AppThemeMode.hell:
        return AppColors.hellTheme;
    }
  }

  static double _getElevation(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 1;
      case AppThemeMode.dark:
      case AppThemeMode.hell:
        return 4;
    }
  }

  static BorderSide _getBorder(AppThemeMode themeMode, AppColorScheme colors) {
    switch (themeMode) {
      case AppThemeMode.light:
        return BorderSide(color: const Color(0xFFE5E5EA), width: 0.5);
      case AppThemeMode.dark:
        return BorderSide.none;
      case AppThemeMode.hell:
        return BorderSide(color: const Color(0xFF4D3B3B), width: 1);
    }
  }
}

// 커스텀 색상 확장
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final AppColorScheme colors;

  const AppColorExtension(this.colors);

  @override
  AppColorExtension copyWith({AppColorScheme? colors}) {
    return AppColorExtension(colors ?? this.colors);
  }

  @override
  AppColorExtension lerp(AppColorExtension? other, double t) {
    return this;
  }
}

// Theme 접근 헬퍼
extension ThemeContextExtension on BuildContext {
  AppColorScheme get colors {
    final extension = Theme.of(this).extension<AppColorExtension>();
    return extension?.colors ?? AppColors.lightTheme;
  }
}
