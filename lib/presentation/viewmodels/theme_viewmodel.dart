import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/theme/app_colors.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  AppThemeMode _currentTheme = AppThemeMode.light;

  AppThemeMode get currentTheme => _currentTheme;
  String get currentThemeName => themeNames[_currentTheme] ?? '라이트';

  ThemeViewModel() {
    _loadTheme();
  }

  void switchTheme(AppThemeMode newTheme) {
    _currentTheme = newTheme;
    _saveTheme();
    notifyListeners();
  }

  void toggleTheme() {
    switch (_currentTheme) {
      case AppThemeMode.light:
        _currentTheme = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        _currentTheme = AppThemeMode.hell;
        break;
      case AppThemeMode.hell:
        _currentTheme = AppThemeMode.light;
        break;
    }
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _currentTheme = AppThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('테마 로드 실패: $e');
    }
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      debugPrint('테마 저장 실패: $e');
    }
  }
}
