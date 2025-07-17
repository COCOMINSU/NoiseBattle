import 'package:flutter/material.dart';

enum AppThemeMode {
  light, // 라이트
  dark, // 다크
  hell, // 소음지옥
}

// 테마 이름 매핑
Map<AppThemeMode, String> themeNames = {
  AppThemeMode.light: '라이트',
  AppThemeMode.dark: '다크',
  AppThemeMode.hell: '소음지옥',
};

// 테마 아이콘 매핑
Map<AppThemeMode, IconData> themeIcons = {
  AppThemeMode.light: Icons.wb_sunny,
  AppThemeMode.dark: Icons.nights_stay,
  AppThemeMode.hell: Icons.whatshot,
};

class AppColors {
  // 라이트 테마 색상 - iOS 18 Liquid Glass 스타일
  static const lightTheme = AppColorScheme(
    primary: Color(0xFF007AFF),
    primaryLight: Color(0xFF5AC8FA),
    primaryDark: Color(0xFF0051D5),
    background: Color(0xFFF2F2F7),
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF2F2F7),
    surfaceTertiary: Color(0xFFE5E5EA),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF3C3C43),
    textTertiary: Color(0xFF8E8E93),
    textQuaternary: Color(0xFFC7C7CC),
    accent: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    success: Color(0xFF34C759),
  );

  // 다크 테마 색상 - Discord 스타일
  static const darkTheme = AppColorScheme(
    primary: Color(0xFF5865F2),
    primaryLight: Color(0xFF7289DA),
    primaryDark: Color(0xFF4752C4),
    background: Color(0xFF1E2124),
    surfacePrimary: Color(0xFF2F3136),
    surfaceSecondary: Color(0xFF36393F),
    surfaceTertiary: Color(0xFF40444B),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB9BBBE),
    textTertiary: Color(0xFF8E9297),
    textQuaternary: Color(0xFF72767D),
    accent: Color(0xFF00D166),
    error: Color(0xFFED4245),
    warning: Color(0xFFFAA61A),
    success: Color(0xFF57F287),
  );

  // 소음지옥 테마 색상 - 검붉은 전쟁 테마
  static const hellTheme = AppColorScheme(
    primary: Color(0xFF8B0000),
    primaryLight: Color(0xFFCC6666),
    primaryDark: Color(0xFF660000),
    background: Color(0xFF1A1A1A),
    surfacePrimary: Color(0xFF2D1B1B),
    surfaceSecondary: Color(0xFF3D2B2B),
    surfaceTertiary: Color(0xFF4D3B3B),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFD3D3D3),
    textTertiary: Color(0xFFB1B1B1),
    textQuaternary: Color(0xFF8F8F8F),
    accent: Color(0xFFCC6666),
    error: Color(0xFFFF4444),
    warning: Color(0xFFFFAA44),
    success: Color(0xFF66CC66),
  );
}

class AppColorScheme {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color background;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textQuaternary;
  final Color accent;
  final Color error;
  final Color warning;
  final Color success;

  const AppColorScheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.background,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
    required this.accent,
    required this.error,
    required this.warning,
    required this.success,
  });
}
