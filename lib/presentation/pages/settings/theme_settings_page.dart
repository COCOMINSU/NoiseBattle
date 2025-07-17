import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('테마 설정')),
      body: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '앱 테마를 선택하세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              for (final themeMode in AppThemeMode.values)
                _ThemeOptionCard(
                  themeMode: themeMode,
                  isSelected: themeViewModel.currentTheme == themeMode,
                  onTap: () => themeViewModel.switchTheme(themeMode),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final AppThemeMode themeMode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeName = themeNames[themeMode] ?? '';
    final themeIcon = themeIcons[themeMode] ?? Icons.palette;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                themeIcon,
                size: 32,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colors.primary : colors.textPrimary,
                      ),
                    ),
                    Text(
                      _getThemeDescription(themeMode),
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'iOS 18 Liquid Glass 스타일의 밝은 테마';
      case AppThemeMode.dark:
        return 'Discord 스타일의 어두운 테마';
      case AppThemeMode.hell:
        return '소음 전쟁을 위한 검붉은 테마';
    }
  }
}
