class EnvironmentConfig {
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  // Firebase 설정
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'noisebattle-2bd2b',
  );

  // API 엔드포인트
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://asia-northeast3-noisebattle-2bd2b.cloudfunctions.net',
  );
}
