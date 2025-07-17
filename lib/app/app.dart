import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/theme_viewmodel.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../shared/theme/app_theme.dart';

class NoiseBattleApp extends StatelessWidget {
  const NoiseBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.getTheme(themeViewModel.currentTheme),
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ 개발 모드: 인증 건너뛰기 (운영 배포 시 제거 필요)
    if (AppConstants.skipAuthForDevelopment) {
      return const HomePage();
    }

    // 일반 인증 플로우
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isAuthenticated) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
