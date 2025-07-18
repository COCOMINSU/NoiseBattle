class AppConstants {
  static const String appName = 'NoiseBattle';
  static const String appVersion = '1.0.0';

  // ⚠️ 운영 배포: 개발 모드 비활성화 (운영 환경으로 복원됨)
  static const bool skipAuthForDevelopment = false;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String noiseMeasurementsCollection = 'noise_measurements';

  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/';
  static const String profileRoute = '/profile';
  static const String measureRoute = '/measure';
  static const String boardRoute = '/board';

  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // API Constants
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Noise Measurement Constants
  static const int noiseMeasurementDuration = 10; // seconds
  static const double dangerousNoiseLevel = 85.0; // dB
  static const double loudNoiseLevel = 70.0; // dB
  static const double moderateNoiseLevel = 55.0; // dB

  // Google Maps API 키
  static const String googleMapsApiKey =
      'AIzaSyAkWOK0fMUoNsa8LnIiexI-gsLGidP0hpA';

  // Firebase 프로젝트 설정
  static const String firebaseProjectId = 'noisebattle-2bd2b';
  static const String firebaseStorageBucket =
      'noisebattle-2bd2b.firebasestorage.app';
}
