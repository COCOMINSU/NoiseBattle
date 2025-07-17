import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/firebase_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 디바이스 방향 설정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase 초기화
  await FirebaseService.initialize();

  runApp(const NoiseBattleApp());
}
