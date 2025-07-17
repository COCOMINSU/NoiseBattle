# Security 개발 계획서

> **Project:** 소음과 전쟁 - 기술적 보안 구현 가이드

## 1. 보안 아키텍처 개요

### 1.1 보안 목표
- **인증 및 권한 관리**: 강력한 사용자 인증 시스템
- **데이터 보호**: 개인정보 및 민감 정보 암호화
- **네트워크 보안**: 안전한 데이터 전송
- **앱 보안**: 클라이언트 앱 보안 강화
- **서버 보안**: 백엔드 인프라 보안
- **컴플라이언스**: 개인정보보호법 준수

### 1.2 보안 계층 구조
```
┌─────────────────────────────────────────┐
│           Application Layer             │
│  - 입력 검증, 권한 확인, 세션 관리          │
├─────────────────────────────────────────┤
│            Network Layer               │
│  - HTTPS/TLS, Certificate Pinning      │
├─────────────────────────────────────────┤
│             Data Layer                 │
│  - 암호화, 데이터 마스킹, 백업 보안        │
├─────────────────────────────────────────┤
│         Infrastructure Layer           │
│  - Firebase Security Rules, IAM        │
└─────────────────────────────────────────┘
```

## 2. 인증 및 권한 관리

### 2.1 다단계 인증 시스템
```dart
// lib/core/security/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 1단계: 소셜 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // 2단계: 본인인증 확인
      await _checkPhoneVerification(userCredential.user!.uid);
      
      return userCredential;
    } catch (e) {
      throw AuthException('Google 로그인 실패: ${e.toString()}');
    }
  }
  
  // 2단계: 휴대폰 본인인증
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    final completer = Completer<void>();
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.currentUser!.linkWithCredential(credential);
        await _updatePhoneVerificationStatus(true);
        completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        // SMS 코드 입력 대기
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // 타임아웃 처리
      },
    );
    
    return completer.future;
  }
  
  // 권한 확인
  Future<bool> checkPermission(String permission) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    
    if (userData == null) return false;
    
    // 역할 기반 권한 확인
    final userRole = userData['role'] as String?;
    final permissions = await _getRolePermissions(userRole);
    
    return permissions.contains(permission);
  }
  
  Future<List<String>> _getRolePermissions(String? role) async {
    final roleDoc = await _firestore.collection('roles').doc(role ?? 'user').get();
    final roleData = roleDoc.data();
    
    return List<String>.from(roleData?['permissions'] ?? []);
  }
}
```

### 2.2 JWT 토큰 관리
```dart
// lib/core/security/token_manager.dart
class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  static Future<void> saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 토큰 암호화 저장
    final encryptedToken = await _encryptToken(token);
    final encryptedRefreshToken = await _encryptToken(refreshToken);
    
    await prefs.setString(_tokenKey, encryptedToken);
    await prefs.setString(_refreshTokenKey, encryptedRefreshToken);
  }
  
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedToken = prefs.getString(_tokenKey);
    
    if (encryptedToken == null) return null;
    
    return await _decryptToken(encryptedToken);
  }
  
  static Future<String> _encryptToken(String token) async {
    final key = await _getOrCreateEncryptionKey();
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromSecureRandom(16);
    
    final encrypted = encrypter.encrypt(token, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }
  
  static Future<String> _decryptToken(String encryptedToken) async {
    final parts = encryptedToken.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    
    final key = await _getOrCreateEncryptionKey();
    final encrypter = Encrypter(AES(key));
    
    return encrypter.decrypt(encrypted, iv: iv);
  }
  
  static Future<Key> _getOrCreateEncryptionKey() async {
    final prefs = await SharedPreferences.getInstance();
    String? keyString = prefs.getString('encryption_key');
    
    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      await prefs.setString('encryption_key', key.base64);
      return key;
    }
    
    return Key.fromBase64(keyString);
  }
}
```

## 3. 데이터 보안

### 3.1 민감 데이터 암호화
```dart
// lib/core/security/encryption_service.dart
class EncryptionService {
  static final _key = Key.fromSecureRandom(32);
  static final _encrypter = Encrypter(AES(_key));
  
  // 개인정보 암호화
  static String encryptPersonalInfo(String data) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(data, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }
  
  // 개인정보 복호화
  static String decryptPersonalInfo(String encryptedData) {
    final parts = encryptedData.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    
    return _encrypter.decrypt(encrypted, iv: iv);
  }
  
  // 파일 암호화
  static Future<Uint8List> encryptFile(Uint8List fileData) async {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(fileData, iv: iv);
    
    // IV + 암호화된 데이터 결합
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setRange(0, iv.bytes.length, iv.bytes);
    result.setRange(iv.bytes.length, result.length, encrypted.bytes);
    
    return result;
  }
  
  // 파일 복호화
  static Future<Uint8List> decryptFile(Uint8List encryptedData) async {
    final iv = IV(encryptedData.sublist(0, 16));
    final encrypted = Encrypted(encryptedData.sublist(16));
    
    return _encrypter.decryptBytes(encrypted, iv: iv);
  }
}
```

### 3.2 데이터 마스킹
```dart
// lib/core/security/data_masking.dart
class DataMasking {
  // 휴대폰 번호 마스킹
  static String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 4) return phoneNumber;
    
    final start = phoneNumber.substring(0, 3);
    final end = phoneNumber.substring(phoneNumber.length - 4);
    final middle = '*' * (phoneNumber.length - 7);
    
    return '$start$middle$end';
  }
  
  // 이메일 마스킹
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final localPart = parts[0];
    final domain = parts[1];
    
    if (localPart.length <= 2) return email;
    
    final maskedLocal = localPart.substring(0, 2) + '*' * (localPart.length - 2);
    return '$maskedLocal@$domain';
  }
  
  // 주소 마스킹
  static String maskAddress(String address) {
    final parts = address.split(' ');
    if (parts.length < 3) return address;
    
    // 시/도, 시/군/구만 표시
    return '${parts[0]} ${parts[1]} ***';
  }
}
```

## 4. 네트워크 보안

### 4.1 Certificate Pinning
```dart
// lib/core/security/network_security.dart
class NetworkSecurity {
  static Dio createSecureDio() {
    final dio = Dio();
    
    // Certificate Pinning 설정
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) {
        // Firebase 인증서 검증
        return _verifyFirebaseCertificate(cert, host);
      };
      return client;
    };
    
    // 인터셉터 추가
    dio.interceptors.add(SecurityInterceptor());
    
    return dio;
  }
  
  static bool _verifyFirebaseCertificate(X509Certificate cert, String host) {
    // Firebase 도메인 확인
    final allowedHosts = [
      'firestore.googleapis.com',
      'firebase.googleapis.com',
      'storage.googleapis.com',
    ];
    
    if (!allowedHosts.contains(host)) return false;
    
    // 인증서 핀 확인
    final sha256 = cert.sha256;
    final expectedPins = [
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Firebase 인증서 핀
      'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // 백업 인증서 핀
    ];
    
    return expectedPins.contains(sha256);
  }
}

// 보안 인터셉터
class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 요청 헤더 보안 강화
    options.headers['X-Requested-With'] = 'XMLHttpRequest';
    options.headers['X-Content-Type-Options'] = 'nosniff';
    
    // 인증 토큰 추가
    _addAuthToken(options);
    
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 에러 정보 로깅 (민감 정보 제외)
    _logSecurityError(err);
    
    super.onError(err, handler);
  }
  
  void _addAuthToken(RequestOptions options) async {
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
  }
  
  void _logSecurityError(DioException err) {
    // 보안 관련 에러만 로깅
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      SecurityLogger.logUnauthorizedAccess(err);
    }
  }
}
```

### 4.2 API 요청 보안
```dart
// lib/core/security/api_security.dart
class ApiSecurity {
  static const String _apiKey = 'your-api-key';
  static const String _apiSecret = 'your-api-secret';
  
  // API 요청 서명 생성
  static String generateSignature(String method, String path, String body, int timestamp) {
    final message = '$method$path$body$timestamp';
    final hmac = Hmac(sha256, utf8.encode(_apiSecret));
    final digest = hmac.convert(utf8.encode(message));
    
    return base64.encode(digest.bytes);
  }
  
  // 요청 검증
  static bool verifyRequest(String signature, String method, String path, String body, int timestamp) {
    final expectedSignature = generateSignature(method, path, body, timestamp);
    return signature == expectedSignature;
  }
  
  // 타임스탬프 검증 (5분 이내)
  static bool isTimestampValid(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = (now - timestamp).abs();
    return diff <= 300; // 5분
  }
}
```

## 5. 클라이언트 앱 보안

### 5.1 코드 난독화
```yaml
# android/app/build.gradle
android {
    buildTypes {
        release {
            shrinkResources true
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

```
# android/app/proguard-rules.pro
-keep class com.google.firebase.** { *; }
-keep class com.example.noisebattle.** { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
```

### 5.2 루트 탐지
```dart
// lib/core/security/root_detection.dart
class RootDetection {
  static Future<bool> isDeviceRooted() async {
    try {
      // 루트 탐지 라이브러리 사용
      final result = await RootJailbreakDetector.isRooted();
      return result;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> isDebuggingEnabled() async {
    try {
      // 디버깅 모드 탐지
      final result = await RootJailbreakDetector.isDebuggingEnabled();
      return result;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> performSecurityCheck() async {
    final isRooted = await isDeviceRooted();
    final isDebugging = await isDebuggingEnabled();
    
    if (isRooted || isDebugging) {
      throw SecurityException('보안 위험이 감지되었습니다.');
    }
  }
}
```

### 5.3 앱 서명 검증
```dart
// lib/core/security/app_signature.dart
class AppSignature {
  static Future<bool> verifyAppSignature() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final signature = await _getAppSignature();
      
      // 예상되는 서명과 비교
      const expectedSignature = 'your-app-signature-hash';
      
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }
  
  static Future<String> _getAppSignature() async {
    // 플랫폼별 앱 서명 추출
    if (Platform.isAndroid) {
      return await _getAndroidSignature();
    } else if (Platform.isIOS) {
      return await _getIOSSignature();
    }
    
    return '';
  }
  
  static Future<String> _getAndroidSignature() async {
    // Android 앱 서명 추출 로직
    return '';
  }
  
  static Future<String> _getIOSSignature() async {
    // iOS 앱 서명 추출 로직
    return '';
  }
}
```

## 6. 데이터 유효성 검증

### 6.1 입력 검증
```dart
// lib/core/security/input_validator.dart
class InputValidator {
  // SQL 인젝션 방지
  static bool isSqlSafe(String input) {
    final sqlPatterns = [
      r"('|(\')|(\-\-)|(\;)|(\|)|(\*)|(\%)|(\+)|(\?)|(\[)|(\])|(\\x)",
      r"(union|select|insert|update|delete|drop|create|alter|exec|execute)"
    ];
    
    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return false;
      }
    }
    
    return true;
  }
  
  // XSS 방지
  static String sanitizeHtml(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;');
  }
  
  // 파일 업로드 검증
  static bool isFileTypeAllowed(String fileName) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.pdf'];
    final extension = fileName.toLowerCase().split('.').last;
    
    return allowedExtensions.contains('.$extension');
  }
  
  static bool isFileSizeValid(int fileSize) {
    const maxSize = 10 * 1024 * 1024; // 10MB
    return fileSize <= maxSize;
  }
  
  // 게시글 내용 검증
  static ValidationResult validatePostContent(String content) {
    if (content.isEmpty) {
      return ValidationResult(false, '내용을 입력해주세요.');
    }
    
    if (content.length > 10000) {
      return ValidationResult(false, '내용이 너무 깁니다.');
    }
    
    if (!isSqlSafe(content)) {
      return ValidationResult(false, '허용되지 않는 문자가 포함되어 있습니다.');
    }
    
    return ValidationResult(true, '');
  }
}

class ValidationResult {
  final bool isValid;
  final String message;
  
  ValidationResult(this.isValid, this.message);
}
```

### 6.2 파일 업로드 보안
```dart
// lib/core/security/file_security.dart
class FileSecurity {
  static Future<bool> scanFile(File file) async {
    // 파일 시그니처 검증
    final signature = await _getFileSignature(file);
    if (!_isValidSignature(signature)) {
      return false;
    }
    
    // 파일 크기 검증
    final fileSize = await file.length();
    if (!InputValidator.isFileSizeValid(fileSize)) {
      return false;
    }
    
    // 악성 코드 스캔 (서드파티 라이브러리 사용)
    return await _scanForMalware(file);
  }
  
  static Future<String> _getFileSignature(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static bool _isValidSignature(String signature) {
    // 알려진 안전한 파일 시그니처 목록과 비교
    final safeSignatures = [
      // JPEG 시그니처
      'FFD8FF',
      // PNG 시그니처
      '89504E47',
      // PDF 시그니처
      '25504446',
    ];
    
    return safeSignatures.any((sig) => signature.toUpperCase().startsWith(sig));
  }
  
  static Future<bool> _scanForMalware(File file) async {
    // 악성 코드 스캔 로직
    // 실제 구현 시 VirusTotal API 등 사용
    return true;
  }
}
```

## 7. 로깅 및 모니터링

### 7.1 보안 로깅
```dart
// lib/core/security/security_logger.dart
class SecurityLogger {
  static void logAuthFailure(String userId, String reason) {
    final logData = {
      'event': 'auth_failure',
      'userId': userId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
      'userAgent': _getUserAgent(),
      'ipAddress': _getClientIP(),
    };
    
    _sendToSecurityCenter(logData);
  }
  
  static void logUnauthorizedAccess(DioException error) {
    final logData = {
      'event': 'unauthorized_access',
      'endpoint': error.requestOptions.path,
      'method': error.requestOptions.method,
      'statusCode': error.response?.statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _sendToSecurityCenter(logData);
  }
  
  static void logSuspiciousActivity(String activity, Map<String, dynamic> details) {
    final logData = {
      'event': 'suspicious_activity',
      'activity': activity,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _sendToSecurityCenter(logData);
  }
  
  static void _sendToSecurityCenter(Map<String, dynamic> logData) {
    // 보안 센터로 로그 전송
    // Firebase Analytics, Crashlytics, 또는 외부 SIEM 시스템
    FirebaseAnalytics.instance.logEvent(
      name: 'security_event',
      parameters: logData,
    );
  }
  
  static String _getUserAgent() {
    // 사용자 에이전트 정보 추출
    return 'NoiseBattle/1.0.0';
  }
  
  static String _getClientIP() {
    // 클라이언트 IP 주소 추출
    return '0.0.0.0';
  }
}
```

### 7.2 실시간 모니터링
```dart
// lib/core/security/security_monitor.dart
class SecurityMonitor {
  static Timer? _monitoringTimer;
  
  static void startMonitoring() {
    _monitoringTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _performSecurityCheck();
    });
  }
  
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
  }
  
  static Future<void> _performSecurityCheck() async {
    // 루트 탐지
    if (await RootDetection.isDeviceRooted()) {
      SecurityLogger.logSuspiciousActivity('rooted_device', {
        'device_id': await _getDeviceId(),
      });
    }
    
    // 앱 서명 검증
    if (!await AppSignature.verifyAppSignature()) {
      SecurityLogger.logSuspiciousActivity('invalid_signature', {
        'device_id': await _getDeviceId(),
      });
    }
    
    // 메모리 사용량 모니터링
    final memoryUsage = await _getMemoryUsage();
    if (memoryUsage > 500) { // 500MB 이상
      SecurityLogger.logSuspiciousActivity('high_memory_usage', {
        'memory_usage': memoryUsage,
      });
    }
  }
  
  static Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }
  
  static Future<int> _getMemoryUsage() async {
    // 메모리 사용량 측정
    return 0;
  }
}
```

## 8. 데이터 보호 및 개인정보 처리

### 8.1 개인정보 생명주기 관리
```dart
// lib/core/security/privacy_manager.dart
class PrivacyManager {
  static Future<void> anonymizeUserData(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // 사용자 정보 익명화
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    batch.update(userRef, {
      'email': 'anonymous@example.com',
      'phoneNumber': '***-****-****',
      'nickname': '익명사용자',
      'profileImageUrl': null,
      'apartmentInfo': null,
      'isAnonymized': true,
    });
    
    // 게시글 작성자 익명화
    final postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId);
    
    final postsSnapshot = await postsQuery.get();
    for (final doc in postsSnapshot.docs) {
      batch.update(doc.reference, {
        'userId': 'anonymous',
        'isAnonymized': true,
      });
    }
    
    await batch.commit();
  }
  
  static Future<void> deleteUserData(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // 사용자 문서 삭제
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    batch.delete(userRef);
    
    // 관련 데이터 삭제
    await _deleteRelatedData(userId, batch);
    
    await batch.commit();
  }
  
  static Future<void> _deleteRelatedData(String userId, WriteBatch batch) async {
    // 게시글 삭제
    final postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId);
    
    final postsSnapshot = await postsQuery.get();
    for (final doc in postsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // 댓글 삭제
    final commentsQuery = FirebaseFirestore.instance
        .collection('comments')
        .where('userId', isEqualTo: userId);
    
    final commentsSnapshot = await commentsQuery.get();
    for (final doc in commentsSnapshot.docs) {
      batch.delete(doc.reference);
    }
  }
  
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    final userData = <String, dynamic>{};
    
    // 사용자 정보
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    userData['user'] = userDoc.data();
    
    // 게시글 정보
    final postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId);
    final postsSnapshot = await postsQuery.get();
    userData['posts'] = postsSnapshot.docs.map((doc) => doc.data()).toList();
    
    // 댓글 정보
    final commentsQuery = FirebaseFirestore.instance
        .collection('comments')
        .where('userId', isEqualTo: userId);
    final commentsSnapshot = await commentsQuery.get();
    userData['comments'] = commentsSnapshot.docs.map((doc) => doc.data()).toList();
    
    return userData;
  }
}
```

### 8.2 동의 관리
```dart
// lib/core/security/consent_manager.dart
class ConsentManager {
  static Future<void> recordConsent(String userId, String consentType, bool granted) async {
    await FirebaseFirestore.instance
        .collection('consents')
        .doc('${userId}_$consentType')
        .set({
      'userId': userId,
      'consentType': consentType,
      'granted': granted,
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': await _getClientIP(),
      'userAgent': _getUserAgent(),
    });
  }
  
  static Future<bool> hasConsent(String userId, String consentType) async {
    final doc = await FirebaseFirestore.instance
        .collection('consents')
        .doc('${userId}_$consentType')
        .get();
    
    if (!doc.exists) return false;
    
    return doc.data()?['granted'] ?? false;
  }
  
  static Future<void> revokeConsent(String userId, String consentType) async {
    await recordConsent(userId, consentType, false);
    
    // 관련 데이터 처리
    await _processConsentRevocation(userId, consentType);
  }
  
  static Future<void> _processConsentRevocation(String userId, String consentType) async {
    switch (consentType) {
      case 'location':
        await _removeLocationData(userId);
        break;
      case 'marketing':
        await _removeMarketingData(userId);
        break;
      case 'analytics':
        await _removeAnalyticsData(userId);
        break;
    }
  }
  
  static Future<void> _removeLocationData(String userId) async {
    // 위치 데이터 삭제
    final batch = FirebaseFirestore.instance.batch();
    
    final postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId);
    
    final postsSnapshot = await postsQuery.get();
    for (final doc in postsSnapshot.docs) {
      batch.update(doc.reference, {
        'location': null,
        'noiseRecord.location': null,
      });
    }
    
    await batch.commit();
  }
  
  static Future<String> _getClientIP() async {
    // 클라이언트 IP 주소 추출
    return '0.0.0.0';
  }
  
  static String _getUserAgent() {
    return 'NoiseBattle/1.0.0';
  }
}
```

## 9. 보안 테스트

### 9.1 자동화된 보안 테스트
```dart
// test/security/security_test.dart
void main() {
  group('Security Tests', () {
    test('Input Validation Test', () {
      // SQL 인젝션 테스트
      expect(InputValidator.isSqlSafe("'; DROP TABLE users; --"), false);
      expect(InputValidator.isSqlSafe("SELECT * FROM users"), false);
      expect(InputValidator.isSqlSafe("정상적인 게시글 내용"), true);
    });
    
    test('XSS Protection Test', () {
      final maliciousInput = '<script>alert("XSS")</script>';
      final sanitized = InputValidator.sanitizeHtml(maliciousInput);
      expect(sanitized.contains('<script>'), false);
    });
    
    test('File Upload Security Test', () {
      expect(InputValidator.isFileTypeAllowed('test.jpg'), true);
      expect(InputValidator.isFileTypeAllowed('test.exe'), false);
      expect(InputValidator.isFileSizeValid(1024), true);
      expect(InputValidator.isFileSizeValid(20 * 1024 * 1024), false);
    });
    
    test('Token Encryption Test', () async {
      const token = 'sample-jwt-token';
      final encrypted = await TokenManager._encryptToken(token);
      final decrypted = await TokenManager._decryptToken(encrypted);
      expect(decrypted, token);
    });
  });
}
```

### 9.2 침투 테스트 체크리스트
```markdown
# 보안 침투 테스트 체크리스트

## 인증 및 권한
- [ ] 브루트 포스 공격 방지
- [ ] 세션 하이재킹 방지
- [ ] 권한 상승 취약점 확인
- [ ] 다중 인증 우회 시도

## 입력 검증
- [ ] SQL 인젝션 테스트
- [ ] XSS 공격 테스트
- [ ] 파일 업로드 취약점
- [ ] 버퍼 오버플로우 테스트

## 네트워크 보안
- [ ] 중간자 공격 방지
- [ ] SSL/TLS 설정 검증
- [ ] 인증서 핀 우회 시도
- [ ] 네트워크 스니핑 방지

## 데이터 보호
- [ ] 민감 정보 암호화 확인
- [ ] 데이터 전송 보안
- [ ] 로컬 저장소 보안
- [ ] 메모리 덤프 분석

## 클라이언트 보안
- [ ] 코드 난독화 효과성
- [ ] 루트 탐지 우회 시도
- [ ] 앱 서명 검증
- [ ] 역공학 방지
```

이 보안 개발 계획서는 database.md, backend.md, law.md와 연계하여 전체적인 보안 체계를 구축합니다. 