import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../presentation/pages/auth/login_page.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Home Page - 구현 예정'))),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다.'))),
        );
    }
  }
}
