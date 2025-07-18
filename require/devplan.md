# 소음과 전쟁 - 단계별 개발 계획서

> **주의사항**: 각 단계는 완전히 완료 후 다음 단계로 진행하세요. 중요한 부분에서는 반드시 Git commit을 실행하세요.

## 🎨 지원 테마 모드
- **라이트**: iOS 18 Liquid Glass 스타일의 밝은 테마
- **다크**: Discord 스타일의 어두운 테마  
- **소음지옥**: 검붉은 전쟁 테마 (NoiseBattle 전용)

## 📋 개발 진행 원칙

1. **AI 친화적 단위**: 각 단계는 Cursor AI가 한 번에 처리할 수 있는 크기로 제한
2. **구체적 지시사항**: 모든 단계에서 정확한 파일 경로와 코드 예시 제공
3. **실시간 연동**: 하드코딩 없이 처음부터 Firebase 연동하여 테스트
4. **안전한 개발**: 중요 기능 완료 시마다 Git commit 실행

## 🔄 개발 진행 관리 가이드

### 📝 체크리스트 사용법
- 각 단계 완료 시 `[ ]`를 `[x]`로 변경
- 진행 상황을 실시간으로 추적
- 문제 발생 시 해당 단계에서 중단하고 해결 후 진행

### 📋 문서 동기화 규칙
**⚠️ 중요: 개발 중 실제 구현과 다르게 개발된 부분이 있다면 반드시 이 devplan.md 파일을 수정하여 실제 구현과 동일하게 맞춰야 합니다.**

**이유:**
- Cursor AI 과부하로 새로운 채팅으로 넘어갈 경우 이어서 개발 가능
- 실제 구현과 문서 간의 불일치로 인한 혼란 방지
- 다른 개발자가 참여할 때 정확한 현재 상태 파악 가능

**수정 방법:**
1. 파일 경로가 다르게 생성된 경우: 해당 Step의 파일 경로 수정
2. 코드 구현이 다른 경우: 해당 Step의 코드 예시 수정
3. 새로운 dependency가 추가된 경우: pubspec.yaml 섹션 업데이트
4. 추가 설정이 필요한 경우: 해당 Step에 설정 내용 추가

### 🔍 진행 상황 체크포인트
- 각 PHASE 완료 시 전체 앱 실행 테스트
- Git commit 후 다음 단계 진행
- 에러 발생 시 즉시 해결 후 문서 업데이트

---

## 📊 전체 진행 상황

### Phase 별 진행 상황
- [x] **PHASE 1**: 프로젝트 초기 설정 (3/3 완료)
- [x] **PHASE 2**: 인증 시스템 구현 (3/3 완료)
- [x] **PHASE 3**: 데이터베이스 설정 (3/3 완료)
- [x] **PHASE 4**: 메인 앱 구조 및 테마 시스템 구현 (3/3 완료)
- [x] **PHASE 5**: 소음 측정 기능 구현 (3/3 완료) ✅ **기본 측정 완료됨!**
- [x] **PHASE 5-A**: 소음 녹음 및 파일 관리 기능 구현 (4/4 완료) ✅ **확장 기능 완료**
- [x] **PHASE 6**: 소음지도 및 랭킹 기능 구현 (3/3 완료) ✅ **지도 및 랭킹 완료**
- [x] **PHASE 7**: 커뮤니티 기능 구현 (3/3 완료) ✅ **커뮤니티 완료**
- [X] **PHASE 8**: 최종 통합 및 배포 (0/3 완료) ⚠️ **개발 모드 → 운영 모드 복원 포함**
- [ ] **PHASE 9**: 운영 배포 및 모니터링 (0/2 완료)

**전체 진행률: 25/30 단계 완료 (83%)**

> ⚠️ **중요 업데이트**: 소음 측정 기능이 단순 측정에서 **녹음+파일저장+위치수집+DB화** 기능으로 확장되었습니다.

> ⚠️ **중요**: Phase 8 Step 8-2에서 개발 중 임시로 설정한 로그인 건너뛰기 기능을 운영 환경으로 되돌려야 합니다.

---

## 🚀 PHASE 1: 프로젝트 초기 설정

### Step 1-1: Flutter 프로젝트 생성 및 기본 설정

**체크리스트:**
- [x] Flutter 프로젝트 생성 완료
- [x] pubspec.yaml에 의존성 추가 완료
- [x] .gitignore 설정 완료
- [x] 프로젝트 실행 테스트 완료
- [x] Git commit 완료

```bash
# 프로젝트 생성
flutter create noisebattle --platforms=android,ios
cd noisebattle

# Git 초기화
git init
git add .
git commit -m "Initial project setup"
```

**작업 내용:**
- Flutter 프로젝트 생성
- `pubspec.yaml`에 필요한 dependency 추가
- `.gitignore` 설정

**pubspec.yaml 의존성 추가:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_firestore: ^4.13.6
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10
  
  # 상태관리
  provider: ^6.1.1
  
  # 네트워킹
  dio: ^5.4.0
  
  # 로컬 저장소
  shared_preferences: ^2.2.2
  
  # 소음 측정
  noise_meter: ^5.0.1
  
  # 권한
  permission_handler: ^11.1.0
  
  # 이미지
  image_picker: ^1.0.4
  
  # 지도
  google_maps_flutter: ^2.5.0
  
  # 소셜 로그인
  google_sign_in: ^6.1.6
  
  # UI
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # 테마 시스템
  flex_color_scheme: ^7.3.1
```

**🔴 Git Commit Point:** `git commit -m "Add dependencies to pubspec.yaml"`

### Step 1-2: Firebase 프로젝트 설정

**체크리스트:**
- [x] Firebase CLI 설치 완료
- [x] Firebase 로그인 완료
- [x] Firebase 프로젝트 생성 완료
- [x] Firebase 초기화 완료 (Firestore, Functions, Storage, Authentication)
- [x] firebase.json 설정 완료
- [x] Git commit 완료

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init
```

**Firebase 설정 선택사항:**
- Firestore: YES
- Functions: YES
- Storage: YES
- Authentication: YES
- 지역: asia-northeast3 (서울)

**firebase.json 설정:**
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "predeploy": "npm --prefix \"$RESOURCE_DIR\" run build",
    "source": "functions",
    "runtime": "nodejs18"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Firebase project setup complete"`

### Step 1-3: 프로젝트 폴더 구조 생성

**체크리스트:**
- [x] lib/ 하위 폴더 구조 생성 완료
- [x] 필수 파일 생성 완료
- [x] 폴더 구조 확인 완료
- [x] Git commit 완료

```
lib/
├── main.dart
```

---

## 🔐 PHASE 2: 인증 시스템 구현

### Step 2-1: Firebase 인증 서비스 구현

**체크리스트:**
- [ ] AuthService 클래스 구현 완료
- [ ] Google 로그인 기능 구현 완료
- [ ] Firestore 사용자 문서 생성 기능 구현 완료
- [ ] Firebase Console에서 Google 로그인 활성화 완료
- [ ] 로그인 기능 테스트 완료
- [ ] Git commit 완료

**파일 생성:** `lib/core/services/auth_service.dart`
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;
  
  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Google 로그인
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Firestore에 사용자 정보 저장
      await _createUserDocument(userCredential.user!);
      
      return userCredential.user;
    } catch (e) {
      throw Exception('Google 로그인 실패: $e');
    }
  }
  
  // 사용자 문서 생성
  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isApartmentVerified': false,
        'role': 'user',
      });
    }
  }
  
  // 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

**테스트 방법:**
1. Firebase Console에서 Authentication > Sign-in method > Google 활성화
2. 앱에서 Google 로그인 테스트
3. Firestore에서 사용자 문서 생성 확인

**🔴 Git Commit Point:** `git commit -m "Firebase authentication service implemented"`

### Step 2-2: 인증 ViewModel 구현

**체크리스트:**
- [x] AuthViewModel 클래스 구현 완료
- [x] 상태 관리 로직 구현 완료
- [x] 로그인/로그아웃 메서드 구현 완료
- [x] 자동 로그인 후 홈 이동 로직 구현 완료
- [x] 에러 처리 로직 구현 완료
- [x] ViewModel 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/presentation/viewmodels/auth_viewmodel.dart`
```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  AuthViewModel() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await _authService.signInWithGoogle();
      _user = user;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Auth ViewModel implemented with auto-login"`

### Step 2-3: 로그인 화면 구현

**체크리스트:**
- [x] LoginPage 위젯 구현 완료
- [x] 라이트 테마 스타일 적용 완료
- [x] 제목과 로고 소음지옥 테마 포인트 적용 완료
- [x] 로그인 성공 후 1-2초 후 자동 홈 이동 구현 완료
- [x] 로딩 상태 표시 구현 완료
- [x] 에러 메시지 표시 구현 완료
- [x] 로그인 화면 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/presentation/pages/auth/login_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음과 전쟁'),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '소음과 전쟁',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '아파트 소음 신고 및 관리 플랫폼',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                
                if (authViewModel.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: () => authViewModel.signInWithGoogle(),
                    icon: const Icon(Icons.login),
                    label: const Text('Google로 로그인'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                
                if (authViewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authViewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Login page implemented with light theme and hell theme accents"`

---

## 🗄️ PHASE 3: 데이터베이스 설정

### Step 3-1: Firestore 보안 규칙 설정

**체크리스트:**
- [x] firestore.rules 파일 수정 완료
- [x] 사용자 데이터 보안 규칙 설정 완료
- [x] 게시글 데이터 보안 규칙 설정 완료
- [x] 댓글 데이터 보안 규칙 설정 완료
- [x] Firebase 배포 완료
- [x] 보안 규칙 테스트 완료

**파일 수정:** `firestore.rules`
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 데이터
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 게시글 데이터
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == request.resource.data.userId);
    }
    
    // 댓글 데이터
    match /comments/{commentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == request.resource.data.userId);
    }
  }
}
```

**배포 명령:**
```bash
firebase deploy --only firestore:rules
```

### Step 3-2: 데이터 모델 구현

**체크리스트:**
- [x] UserModel 클래스 구현 완료
- [x] fromFirestore 메서드 구현 완료
- [x] toFirestore 메서드 구현 완료
- [x] 모델 유효성 검증 완료
- [x] Git commit 완료

**파일 생성:** `lib/data/models/user_model.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isVerified;
  final bool isApartmentVerified;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.isVerified,
    required this.isApartmentVerified,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      isVerified: data['isVerified'] ?? false,
      isApartmentVerified: data['isApartmentVerified'] ?? false,
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isVerified': isVerified,
      'isApartmentVerified': isApartmentVerified,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Database models implemented"`

### Step 3-3: 데이터베이스 서비스 구현

**체크리스트:**
- [x] DatabaseService 클래스 구현 완료
- [x] 사용자 정보 가져오기 메서드 구현 완료
- [x] 사용자 정보 업데이트 메서드 구현 완료
- [x] 사용자 스트림 메서드 구현 완료
- [x] 서비스 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/core/services/database_service.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 사용자 정보 가져오기
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('사용자 정보 가져오기 실패: $e');
    }
  }
  
  // 사용자 정보 업데이트
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('사용자 정보 업데이트 실패: $e');
    }
  }
  
  // 사용자 스트림
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Database service implemented"`

---

## 📱 PHASE 4: 메인 앱 구조 및 테마 시스템 구현

### Step 4-1: 메인 앱 설정

**체크리스트:**
- [x] NoiseBattleApp 위젯 구현 완료
- [x] AuthWrapper 위젯 구현 완료
- [x] Provider 설정 (Auth, Theme) 완료
- [x] 기본 앱 구조 설정 완료
- [x] main.dart 파일 수정 완료
- [x] 앱 실행 테스트 완료
- [x] Git commit 완료

**파일 수정:** `lib/app/app.dart` (기본 구조 - Step 4-3에서 테마 시스템으로 업데이트됨)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/home/home_page.dart';

class NoiseBattleApp extends StatelessWidget {
  const NoiseBattleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: '소음과 전쟁',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
```

**파일 수정:** `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NoiseBattleApp());
}
```

### Step 4-2: 홈 페이지 구현

**체크리스트:**
- [x] HomePage 위젯 구현 완료
- [x] BottomNavigationBar 구현 완료 (5개 탭: 홈, 소음측정, 소음지도, 커뮤니티, 프로필)
- [x] 각 탭 화면 기본 구조 구현 완료
- [x] 프로필 화면 및 테마 설정 링크 구현 완료
- [x] 앱바에 테마 토글 버튼 추가 완료
- [x] 로그아웃 기능 구현 완료
- [x] 네비게이션 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/presentation/pages/home/home_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../settings/theme_settings_page.dart';
import '../../../shared/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음과 전쟁'),
        actions: [
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return IconButton(
                icon: Icon(themeIcons[themeViewModel.currentTheme] ?? Icons.palette),
                onPressed: themeViewModel.toggleTheme,
                tooltip: '테마 전환: ${themeViewModel.currentThemeName}',
              );
            },
          ),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: authViewModel.signOut,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volume_up),
            label: '소음측정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '소음지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const Center(child: Text('홈 화면'));
      case 1:
        return const Center(child: Text('소음측정 화면'));
      case 2:
        return const Center(child: Text('소음지도 화면'));
      case 3:
        return const Center(child: Text('커뮤니티 화면'));
      case 4:
        return _buildProfileScreen();
      default:
        return const Center(child: Text('홈 화면'));
    }
  }
  
  Widget _buildProfileScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('테마 설정'),
          subtitle: Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return Text('현재: ${themeViewModel.currentThemeName}');
            },
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ThemeSettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Main app structure implemented with 5 tabs (홈, 소음측정, 소음지도, 커뮤니티, 프로필)"`

### Step 4-3: 테마 시스템 구현

**체크리스트:**
- [ ] 테마 색상 팔레트 클래스 구현 완료
- [ ] ThemeProvider 구현 완료
- [ ] 3가지 테마 모드 (라이트/다크/소음지옥) 구현 완료
- [ ] 테마 전환 기능 구현 완료
- [ ] 사용자 설정 저장 기능 구현 완료
- [ ] 앱에 테마 시스템 적용 완료
- [ ] 테마 설정 화면 구현 완료
- [ ] 모든 테마 테스트 완료
- [ ] Git commit 완료

**파일 생성:** `lib/shared/theme/app_colors.dart`
```dart
import 'package:flutter/material.dart';

enum AppThemeMode {
  light,    // 라이트
  dark,     // 다크
  hell,     // 소음지옥
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
  // 라이트 테마 색상
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

  // 다크 테마 색상
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

  // 소음지옥 테마 색상
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
```

**파일 생성:** `lib/shared/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(AppThemeMode themeMode) {
    final colors = _getColorScheme(themeMode);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: themeMode == AppThemeMode.light ? Brightness.light : Brightness.dark,
        primary: colors.primary,
        onPrimary: themeMode == AppThemeMode.light ? Colors.white : colors.textPrimary,
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
          statusBarIconBrightness: themeMode == AppThemeMode.light ? Brightness.dark : Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: themeMode == AppThemeMode.light ? Colors.white : colors.textPrimary,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
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
```

**파일 생성:** `lib/presentation/viewmodels/theme_viewmodel.dart`
```dart
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
```

**파일 생성:** `lib/presentation/pages/settings/theme_settings_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../../shared/theme/app_colors.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테마 설정'),
      ),
      body: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '앱 테마를 선택하세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.primary,
                ),
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
```

**파일 수정:** `lib/app/app.dart` (테마 시스템 적용)
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/theme_viewmodel.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../shared/theme/app_theme.dart';

class NoiseBattleApp extends StatelessWidget {
  const NoiseBattleApp({Key? key}) : super(key: key);

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
            title: '소음과 전쟁',
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
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
```

**🔴 Git Commit Point:** `git commit -m "Theme system implemented with 3 modes (라이트/다크/소음지옥)"`

---

## 🔊 PHASE 5: 소음 측정 기능 구현

### Step 5-1: 소음 측정 서비스 구현

**체크리스트:**
- [x] NoiseService 클래스 구현 완료
- [x] 마이크 권한 요청 기능 구현 완료
- [x] 소음 측정 시작/중지 기능 구현 완료
- [x] 소음 데이터 스트림 구현 완료
- [x] 에러 처리 로직 구현 완료
- [x] 서비스 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/core/services/noise_service.dart`
```dart
import 'dart:async';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class NoiseService {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  
  final StreamController<NoiseReading> _noiseController = StreamController<NoiseReading>.broadcast();
  Stream<NoiseReading> get noiseStream => _noiseController.stream;
  
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  Future<void> startRecording() async {
    if (_isRecording) return;
    
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('마이크 권한이 필요합니다.');
    }
    
    try {
      _noiseMeter = NoiseMeter();
      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading noiseReading) {
          _noiseController.add(noiseReading);
        },
        onError: (error) {
          _noiseController.addError(error);
        },
      );
      
      _isRecording = true;
    } catch (e) {
      throw Exception('소음 측정 시작 실패: $e');
    }
  }
  
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    await _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
    _isRecording = false;
  }
  
  void dispose() {
    stopRecording();
    _noiseController.close();
  }
}
```

### Step 5-2: 소음 측정 ViewModel 구현

**체크리스트:**
- [x] NoiseViewModel 클래스 구현 완료
- [x] 소음 데이터 상태 관리 구현 완료
- [x] 측정 시작/중지 메서드 구현 완료
- [x] 최대/최소 데시벨 추적 구현 완료
- [x] 에러 처리 로직 구현 완료
- [x] ViewModel 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/presentation/viewmodels/noise_viewmodel.dart`
```dart
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import '../../core/services/noise_service.dart';

class NoiseViewModel extends ChangeNotifier {
  final NoiseService _noiseService = NoiseService();
  
  double _currentDecibel = 0.0;
  double _maxDecibel = 0.0;
  double _minDecibel = 100.0;
  bool _isRecording = false;
  String? _error;
  
  double get currentDecibel => _currentDecibel;
  double get maxDecibel => _maxDecibel;
  double get minDecibel => _minDecibel;
  bool get isRecording => _isRecording;
  String? get error => _error;
  
  NoiseViewModel() {
    _noiseService.noiseStream.listen(
      _onNoiseReading,
      onError: _onError,
    );
  }
  
  void _onNoiseReading(NoiseReading reading) {
    _currentDecibel = reading.meanDecibel;
    
    if (_currentDecibel > _maxDecibel) {
      _maxDecibel = _currentDecibel;
    }
    
    if (_currentDecibel < _minDecibel) {
      _minDecibel = _currentDecibel;
    }
    
    notifyListeners();
  }
  
  void _onError(error) {
    _error = error.toString();
    _isRecording = false;
    notifyListeners();
  }
  
  Future<void> startRecording() async {
    try {
      _error = null;
      await _noiseService.startRecording();
      _isRecording = true;
      _resetValues();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isRecording = false;
      notifyListeners();
    }
  }
  
  Future<void> stopRecording() async {
    await _noiseService.stopRecording();
    _isRecording = false;
    notifyListeners();
  }
  
  void _resetValues() {
    _currentDecibel = 0.0;
    _maxDecibel = 0.0;
    _minDecibel = 100.0;
  }
  
  @override
  void dispose() {
    _noiseService.dispose();
    super.dispose();
  }
}
```

### Step 5-3: 소음 측정 화면 구현

**체크리스트:**
- [x] NoiseMeasurementPage 위젯 구현 완료
- [x] 현재 데시벨 표시 UI 구현 완료
- [x] 측정 통계 UI 구현 완료
- [x] 측정 시작/중지 버튼 구현 완료
- [x] 에러 메시지 표시 구현 완료
- [x] 주의사항 표시 구현 완료
- [x] 소음 측정 기능 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/presentation/pages/noise/noise_measurement_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noise_viewmodel.dart';

class NoiseMeasurementPage extends StatelessWidget {
  const NoiseMeasurementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoiseViewModel(),
      child: const _NoiseMeasurementView(),
    );
  }
}

class _NoiseMeasurementView extends StatelessWidget {
  const _NoiseMeasurementView();

  @override
  Widget build(BuildContext context) {
    return Consumer<NoiseViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 현재 데시벨 표시
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '${viewModel.currentDecibel.toStringAsFixed(1)} dB',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text('현재 소음 레벨'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 측정 통계
              if (viewModel.isRecording) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      title: '최대',
                      value: viewModel.maxDecibel.toStringAsFixed(1),
                      color: Colors.red,
                    ),
                    _StatCard(
                      title: '최소',
                      value: viewModel.minDecibel.toStringAsFixed(1),
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              // 측정 버튼
              ElevatedButton(
                onPressed: viewModel.isRecording
                    ? viewModel.stopRecording
                    : viewModel.startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.isRecording ? Colors.red : Colors.blue,
                  minimumSize: const Size(200, 50),
                ),
                child: Text(
                  viewModel.isRecording ? '측정 중지' : '측정 시작',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              
              // 에러 메시지
              if (viewModel.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              
              // 주의사항
              const SizedBox(height: 32),
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '주의: 이 측정값은 참고용이며 법적 증거로 사용할 수 없습니다.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '$value dB',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Noise measurement feature implemented"`

---

## 🎤 PHASE 5-A: 소음 녹음 및 파일 관리 기능 구현

> **중요**: 기존 소음 측정 기능을 **실시간 측정 + 녹음 + 파일 저장 + 위치 수집 + 데이터베이스화**로 확장

### Step 5A-1: 소음 녹음 서비스 확장

**체크리스트:**
- [x] 기존 NoiseService를 NoiseRecordingService로 확장 완료
- [x] 동시 녹음 + 실시간 측정 기능 구현 완료
- [x] 오디오 파일 저장 기능 구현 완료
- [x] GPS 위치 수집 기능 구현 완료
- [x] 역지오코딩 (주소 변환) 기능 구현 완료
- [x] Firebase Storage 업로드 기능 구현 완료
- [x] 에러 처리 및 권한 관리 완료
- [x] Git commit 완료

**주요 기능:**
1. **동시 처리**: 실시간 데시벨 측정 + 오디오 파일 녹음
2. **위치 수집**: GPS 좌표 + 주소 정보 자동 수집
3. **파일 관리**: 사용자 지정 파일명으로 저장
4. **클라우드 업로드**: Firebase Storage에 자동 업로드

**필요한 의존성 추가:**
```yaml
dependencies:
  # 기존 의존성들...
  record: ^4.4.4              # 오디오 녹음
  geolocator: ^9.0.2          # GPS 위치
  geocoding: ^2.1.1           # 역지오코딩
  path_provider: ^2.1.1       # 로컬 파일 경로
  firebase_storage: ^11.6.0   # 파일 업로드
```

**파일 수정:** `lib/core/services/noise_recording_service.dart`
```dart
import 'dart:async';
import 'dart:io';
import 'package:noise_meter/noise_meter.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class NoiseRecordingService {
  // 실시간 소음 측정
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final StreamController<NoiseReading> _noiseController = StreamController<NoiseReading>.broadcast();
  Stream<NoiseReading> get noiseStream => _noiseController.stream;
  
  // 오디오 녹음
  final Record _audioRecorder = Record();
  String? _currentRecordingPath;
  
  // 상태 관리
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Position? _currentPosition;
  String? _currentAddress;
  
  // Getters
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  
  // 권한 요청
  Future<bool> requestPermissions() async {
    final micPermission = await Permission.microphone.request();
    final locationPermission = await Permission.location.request();
    final storagePermission = await Permission.storage.request();
    
    return micPermission.isGranted && locationPermission.isGranted && storagePermission.isGranted;
  }
  
  // 녹음 시작 (측정 + 녹음 + 위치 수집)
  Future<void> startRecording(String fileName) async {
    if (_isRecording) return;
    
    final hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      throw Exception('필요한 권한이 없습니다.');
    }
    
    try {
      // 1. 위치 수집
      await _getCurrentLocation();
      
      // 2. 오디오 녹음 시작
      final directory = await getApplicationDocumentsDirectory();
      _currentRecordingPath = '${directory.path}/$fileName.m4a';
      
      await _audioRecorder.start(
        path: _currentRecordingPath!,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
      
      // 3. 실시간 소음 측정 시작
      _noiseMeter = NoiseMeter();
      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading noiseReading) {
          _noiseController.add(noiseReading);
        },
        onError: (error) {
          _noiseController.addError(error);
        },
      );
      
      _isRecording = true;
      _recordingStartTime = DateTime.now();
    } catch (e) {
      throw Exception('녹음 시작 실패: $e');
    }
  }
  
  // 녹음 중지 및 파일 업로드
  Future<Map<String, dynamic>> stopRecording() async {
    if (!_isRecording) return {};
    
    try {
      // 1. 녹음 중지
      await _audioRecorder.stop();
      await _noiseSubscription?.cancel();
      
      final duration = DateTime.now().difference(_recordingStartTime!);
      
      // 2. Firebase Storage 업로드
      final downloadUrl = await _uploadToFirebase(_currentRecordingPath!);
      
      // 3. 결과 데이터 구성
      final recordData = {
        'audioFileUrl': downloadUrl,
        'filePath': _currentRecordingPath,
        'duration': duration.inSeconds,
        'recordedAt': _recordingStartTime!.toIso8601String(),
        'location': {
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'address': _currentAddress,
          'accuracy': _currentPosition?.accuracy,
        },
      };
      
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      
      return recordData;
    } catch (e) {
      throw Exception('녹음 중지 실패: $e');
    }
  }
  
  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // 역지오코딩으로 주소 변환
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentAddress = '${place.administrativeArea} ${place.locality} ${place.subLocality}';
      }
    } catch (e) {
      print('위치 수집 실패: $e');
    }
  }
  
  // Firebase Storage 업로드
  Future<String> _uploadToFirebase(String filePath) async {
    final file = File(filePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final ref = FirebaseStorage.instance
        .ref()
        .child('noise_records')
        .child(fileName);
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
  
  void dispose() {
    _audioRecorder.dispose();
    _noiseSubscription?.cancel();
    _noiseController.close();
  }
}
```

### Step 5A-2: 데이터베이스 모델 및 서비스 구현

**체크리스트:**
- [x] NoiseRecordModel 클래스 구현 완료
- [x] NoiseRecordService 클래스 구현 완료
- [x] Firestore 저장 기능 구현 완료
- [x] 사용자별 녹음 목록 조회 기능 구현 완료
- [x] 메타데이터 관리 기능 구현 완료
- [x] Git commit 완료

**파일 생성:** `lib/data/models/noise_record_model.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NoiseRecordModel {
  final String id;
  final String userId;
  final String fileName;
  final String? customTitle;
  final String? description;
  final Map<String, dynamic> measurements;
  final Map<String, dynamic> location;
  final Map<String, dynamic> deviceInfo;
  final String? audioFileUrl;
  final DateTime recordedAt;
  final DateTime createdAt;
  final bool isPublic;
  final List<String> tags;
  
  NoiseRecordModel({
    required this.id,
    required this.userId,
    required this.fileName,
    this.customTitle,
    this.description,
    required this.measurements,
    required this.location,
    required this.deviceInfo,
    this.audioFileUrl,
    required this.recordedAt,
    required this.createdAt,
    this.isPublic = false,
    this.tags = const [],
  });
  
  factory NoiseRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoiseRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? '',
      customTitle: data['customTitle'],
      description: data['description'],
      measurements: data['measurements'] ?? {},
      location: data['location'] ?? {},
      deviceInfo: data['deviceInfo'] ?? {},
      audioFileUrl: data['audioFileUrl'],
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fileName': fileName,
      'customTitle': customTitle,
      'description': description,
      'measurements': measurements,
      'location': location,
      'deviceInfo': deviceInfo,
      'audioFileUrl': audioFileUrl,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'tags': tags,
    };
  }
}
```

### Step 5A-3: 확장된 ViewModel 구현

**체크리스트:**
- [x] NoiseRecordingViewModel 클래스 구현 완료
- [x] 파일명 입력 관리 기능 구현 완료
- [x] 위치 정보 표시 기능 구현 완료
- [x] 업로드 진행률 표시 기능 구현 완료
- [x] 녹음 목록 관리 기능 구현 완료
- [x] 에러 처리 로직 구현 완료
- [x] Git commit 완료

### Step 5A-4: 새로운 UI 화면 구현

**체크리스트:**
- [x] 소음 녹음 화면 (NoiseRecordingPage) 구현 완료
- [x] 파일명 입력 다이얼로그 구현 완료
- [x] 위치 정보 표시 위젯 구현 완료
- [x] 녹음 파일 목록 화면 구현 완료
- [x] 녹음 파일 상세 화면 구현 완료
- [x] 홈 화면 연동 기능 구현 완료
- [x] Git commit 완료

**주요 UI 컴포넌트:**
1. **파일명 입력**: 사용자가 원하는 이름으로 저장
2. **위치 표시**: 현재 GPS 좌표 및 주소 표시
3. **실시간 그래프**: 측정 중 데시벨 변화 시각화
4. **녹음 상태**: 진행 시간, 파일 크기 표시
5. **저장 관리**: 개인 Storage 사용량 표시

**🔴 Git Commit Point:** `git commit -m "Advanced noise recording with file management and location data implemented"`

---

## 📋 PHASE 6: 소음지도 및 랭킹 기능 구현

### Step 6-1: 소음지도 구현

**체크리스트:**
- [ ] NoiseMapPage 위젯 구현 완료
- [ ] Google Maps 연동 완료
- [ ] 소음 데이터 마커 표시 완료
- [ ] 마커 클릭 시 상세 정보 표시 완료
- [ ] 소음 데이터 필터링 기능 구현 완료
- [ ] 데이터 로딩 및 에러 처리 완료
- [ ] Git commit 완료

**파일 생성:** `lib/presentation/pages/noise/noise_map_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:noise_meter/noise_meter.dart';
import '../../core/services/noise_service.dart';

class NoiseMapPage extends StatefulWidget {
  const NoiseMapPage({Key? key}) : super(key: key);

  @override
  State<NoiseMapPage> createState() => _NoiseMapPageState();
}

class _NoiseMapPageState extends State<NoiseMapPage> {
  final GoogleMapController _mapController = GoogleMapController();
  final NoiseService _noiseService = NoiseService();
  
  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadNoiseData();
  }
  
  Future<void> _loadNoiseData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final noiseReadings = await _noiseService.noiseStream.take(100).toList(); // 최근 100개 데이터
      final markers = <Marker>[];
      
      for (final reading in noiseReadings) {
        final lat = 37.5665 + (0.0001 * (reading.meanDecibel - 50)); // 예시 위도
        final lng = 126.9780 + (0.0001 * (reading.meanDecibel - 50)); // 예시 경도
        
        markers.add(
          Marker(
            markerId: MarkerId(reading.timestamp.toString()),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: '소음 레벨: ${reading.meanDecibel.toStringAsFixed(1)} dB',
              snippet: '시간: ${reading.timestamp.toString()}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
      
      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음 지도'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('소음 데이터를 불러오는데 실패했습니다: $_error'))
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.5665, 126.9780), // 예시 중심점
                    zoom: 10.0,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: Set<Marker>.from(_markers),
                  onTap: (LatLng latLng) {
                    // 마커 클릭 시 상세 정보 표시
                    final marker = _markers.firstWhere(
                      (m) => m.position.latitude == latLng.latitude &&
                             m.position.longitude == latLng.longitude,
                      orElse: () => Marker(markerId: MarkerId('unknown'), position: latLng),
                    );
                    if (marker.markerId.value != 'unknown') {
                      final reading = _noiseService.noiseStream
                          .where((r) => r.timestamp.millisecondsSinceEpoch == int.tryParse(marker.markerId.value)!)
                          .first;
                      
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('소음 데이터 상세'),
                            content: Text(
                              '시간: ${reading.timestamp.toString()}\n'
                              '평균 데시벨: ${reading.meanDecibel.toStringAsFixed(1)} dB\n'
                              '최대 데시벨: ${reading.maxDecibel.toStringAsFixed(1)} dB\n'
                              '최소 데시벨: ${reading.minDecibel.toStringAsFixed(1)} dB',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('닫기'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
    );
  }
}
```

### Step 6-2: 소음 랭킹 구현

**체크리스트:**
- [ ] NoiseRankingPage 위젯 구현 완료
- [ ] 소음 데이터 랭킹 표시 완료
- [ ] 데이터 필터링 및 정렬 기능 구현 완료
- [ ] 사용자 개인 랭킹 표시 완료
- [ ] 데이터 로딩 및 에러 처리 완료
- [ ] Git commit 완료

**파일 생성:** `lib/presentation/pages/noise/noise_ranking_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/noise_service.dart';
import '../../data/models/user_model.dart';
import '../../core/services/database_service.dart';

class NoiseRankingPage extends StatefulWidget {
  const NoiseRankingPage({Key? key}) : super(key: key);

  @override
  State<NoiseRankingPage> createState() => _NoiseRankingPageState();
}

class _NoiseRankingPageState extends State<NoiseRankingPage> {
  final NoiseService _noiseService = NoiseService();
  final DatabaseService _dbService = DatabaseService();
  
  List<Map<String, dynamic>> _rankingData = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadRankingData();
  }
  
  Future<void> _loadRankingData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final noiseReadings = await _noiseService.noiseStream.take(100).toList(); // 최근 100개 데이터
      final userMap = <String, UserModel>{};
      
      // 사용자 정보 가져오기
      final user = _dbService.currentUser;
      if (user != null) {
        userMap[user.uid] = user;
      }
      
      final List<Map<String, dynamic>> rankingList = [];
      
      for (final reading in noiseReadings) {
        final userId = reading.userId;
        if (userMap.containsKey(userId)) {
          final user = userMap[userId]!;
          rankingList.add({
            'userId': userId,
            'displayName': user.displayName,
            'decibel': reading.meanDecibel,
            'timestamp': reading.timestamp.millisecondsSinceEpoch,
          });
        }
      }
      
      // 데시벨 순으로 정렬
      rankingList.sort((a, b) => b['decibel'].compareTo(a['decibel']));
      
      setState(() {
        _rankingData = rankingList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음 랭킹'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('소음 데이터를 불러오는데 실패했습니다: $_error'))
              : ListView.builder(
                  itemCount: _rankingData.length,
                  itemBuilder: (context, index) {
                    final item = _rankingData[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item['displayName'] ?? '알 수 없음'),
                      subtitle: Text(
                        '데시벨: ${item['decibel'].toStringAsFixed(1)} dB\n'
                        '시간: ${DateTime.fromMillisecondsSinceEpoch(item['timestamp']).toString()}',
                      ),
                    );
                  },
                ),
    );
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Noise map and ranking feature implemented"`

---

## 📋 PHASE 7: 커뮤니티 기능 구현

### Step 7-1: 게시글 모델 구현

**체크리스트:**
- [x] PostModel 클래스 구현 완료
- [x] CommentModel 클래스 구현 완료
- [x] fromFirestore 메서드 구현 완료
- [x] toFirestore 메서드 구현 완료
- [x] DTO 클래스들 구현 완료
- [x] 상수 클래스들 구현 완료
- [x] 모델 유효성 검증 완료
- [x] Git commit 완료

**파일 생성:** `lib/data/models/post_model.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int commentCount;
  final String category;
  
  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.commentCount,
    required this.category,
  });
  
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      category: data['category'] ?? '',
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'category': category,
    };
  }
}
```

### Step 7-2: 게시판 서비스 구현

**체크리스트:**
- [x] PostService 클래스 구현 완료
- [x] 게시글 생성 메서드 구현 완료
- [x] 게시글 목록 조회 메서드 구현 완료
- [x] 게시글 상세 조회 메서드 구현 완료
- [x] 게시글 수정 메서드 구현 완료
- [x] 게시글 삭제 메서드 구현 완료
- [x] 댓글 관련 메서드 구현 완료
- [x] 좋아요/신고 기능 구현 완료
- [x] 베스트 게시글 조회 구현 완료
- [x] 검색 기능 구현 완료
- [x] 서비스 테스트 완료
- [x] Git commit 완료

**파일 생성:** `lib/core/services/post_service.dart`
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 게시글 생성
  Future<String> createPost(PostModel post) async {
    try {
      final docRef = await _firestore.collection('posts').add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('게시글 생성 실패: $e');
    }
  }
  
  // 게시글 목록 가져오기
  Stream<List<PostModel>> getPosts({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }
  
  // 게시글 상세 정보 가져오기
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return PostModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('게시글 정보 가져오기 실패: $e');
    }
  }
  
  // 게시글 수정
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('게시글 수정 실패: $e');
    }
  }
  
  // 게시글 삭제
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('게시글 삭제 실패: $e');
    }
  }
}
```

**🔴 Git Commit Point:** `git commit -m "Post service and model implemented"`

### Step 7-3: 커뮤니티 UI 구현

**체크리스트:**
- [x] CommunityMainPage 구현 완료 (메인 화면, 게시판 메뉴)
- [x] BoardPage 구현 완료 (게시글 목록, 카테고리 필터)
- [x] 게시판별 카테고리 시스템 구현 완료
- [x] 게시글 카드 UI 구현 완료
- [x] 소음 녹음 데이터 표시 기능 구현 완료
- [x] 베스트 게시글 메뉴 구현 완료
- [x] 홈페이지 커뮤니티 탭 연동 완료
- [x] 테마 시스템 적용 완료
- [x] Git commit 완료

**주요 구현 내용:**
1. **커뮤니티 메인 화면**: 5개 게시판 메뉴, 최근 인기글, 베스트 글 미리보기
2. **게시판 페이지**: 게시글 목록, 카테고리별 필터링, 글쓰기 버튼
3. **게시글 카드**: 카테고리, 아파트 정보, 소음 데이터, 통계 표시
4. **베스트 게시글**: 주간/월간 베스트 선택 메뉴

**🔴 Git Commit Point:** `git commit -m "Community UI implementation - main page and board pages with full functionality"`

---

## 🧪 PHASE 7: 테스트 및 배포 준비

### Step 7-1: 기본 테스트 작성

**체크리스트:**
- [ ] AuthService 단위 테스트 작성 완료
- [ ] 테스트 의존성 추가 완료
- [ ] Mock 객체 설정 완료
- [ ] 테스트 케이스 실행 완료
- [ ] Git commit 완료

**파일 생성:** `test/services/auth_service_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noisebattle/core/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService();
    });
    
    test('should return current user when authenticated', () {
      // Given
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      // When
      final result = authService.currentUser;
      
      // Then
      expect(result, equals(mockUser));
    });
  });
}
```

### Step 7-2: 통합 테스트 작성

**체크리스트:**
- [ ] 통합 테스트 파일 생성 완료
- [ ] 로그인 화면 표시 테스트 작성 완료
- [ ] 로그인 후 홈 화면 이동 테스트 작성 완료
- [ ] 통합 테스트 실행 완료
- [ ] Git commit 완료

**파일 생성:** `integration_test/app_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:noisebattle/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Integration Tests', () {
    testWidgets('should show login page when not authenticated', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 로그인 화면 요소 확인
      expect(find.text('소음과 전쟁'), findsOneWidget);
      expect(find.text('Google로 로그인'), findsOneWidget);
    });
    
    testWidgets('should navigate to home after login', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Google 로그인 버튼 탭
      await tester.tap(find.text('Google로 로그인'));
      await tester.pumpAndSettle();
      
      // 홈 화면 확인 (실제 로그인 성공 시)
      // expect(find.text('홈'), findsOneWidget);
    });
  });
}
```

**🔴 Git Commit Point:** `git commit -m "Tests implemented"`

### Step 7-3: 앱 아이콘 및 스플래시 설정

**체크리스트:**
- [ ] 앱 아이콘 설정 완료
- [ ] Android 권한 설정 완료
- [ ] iOS 권한 설정 완료
- [ ] 권한 요청 테스트 완료
- [ ] Git commit 완료

**파일 생성:** `pubspec.yaml`에 추가
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
```

**Android 설정:** `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**iOS 설정:** `ios/Runner/Info.plist`
```xml
<key>NSMicrophoneUsageDescription</key>
<string>소음 측정을 위해 마이크 권한이 필요합니다.</string>
```

**🔴 Git Commit Point:** `git commit -m "App configuration and permissions setup"`

---

## 📱 PHASE 8: 최종 통합 및 배포

### Step 8-1: 빌드 및 테스트

**체크리스트:**
- [X] 의존성 설치 완료
- [X] 코드 분석 통과 완료
- [X] 단위 테스트 통과 완료
- [X] 통합 테스트 통과 완료
- [X] Android 빌드 성공 완료
- [X] iOS 빌드 성공 완료 (Mac인 경우)
- [X] Git commit 완료

```bash
# 의존성 설치
flutter pub get

# 코드 분석
flutter analyze

# 테스트 실행
flutter test

# 통합 테스트
flutter test integration_test/

# Android 빌드
flutter build apk --release

# iOS 빌드 (Mac에서만)
flutter build ios --release
```

**🔴 Git Commit Point:** `git commit -m "Build and test phase completed"`

### Step 8-2: 개발 모드 설정 운영 환경으로 복원

**체크리스트:**
- [ ] 개발 모드 플래그 비활성화 완료
- [ ] AuthWrapper 인증 로직 복원 완료
- [ ] 로그인 화면 정상 작동 확인 완료
- [ ] Firebase 인증 연동 테스트 완료
- [ ] 운영 환경 빌드 테스트 완료
- [ ] Git commit 완료

**⚠️ 중요: 운영 배포 전 반드시 수행해야 하는 단계입니다.**

**1. 개발 모드 플래그 비활성화**

`lib/core/constants/app_constants.dart` 수정:
```dart
class AppConstants {
  static const String appName = 'NoiseBattle';
  static const String appVersion = '1.0.0';

  // ⚠️ 운영 배포: 개발 모드 비활성화 (true → false로 변경)
  static const bool skipAuthForDevelopment = false;

  // ... existing code ...
}
```

**2. AuthWrapper 정리 (선택사항)**

`lib/app/app.dart`에서 개발 모드 관련 코드 제거 (선택적):
```dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 개발 모드 코드 제거 가능 (하지만 플래그만 false로 하는 것도 충분)
    
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
```

**3. 인증 기능 테스트**
```bash
# 앱 재시작 후 로그인 화면 확인
flutter run

# Firebase Authentication 연동 테스트
# 1. Google 로그인 테스트
# 2. 로그아웃 후 재로그인 테스트
# 3. 사용자 정보 Firestore 저장 확인
```

**4. 운영 환경 확인사항**
- [ ] Firebase 프로젝트가 운영 환경으로 설정되어 있는지 확인
- [ ] API 키가 운영 환경용인지 확인
- [ ] 보안 규칙이 적절히 설정되어 있는지 확인
- [ ] 테스트 계정으로 전체 플로우 검증

**🔴 Git Commit Point:** `git commit -m "Production environment settings restored - auth flow enabled"`

### Step 8-3: 배포 준비 및 최종 검증

**체크리스트:**
- [ ] 앱 버전 확인 및 업데이트 완료
- [ ] Release 빌드 성공 확인 완료
- [ ] 앱 서명 설정 완료
- [ ] 스토어 등록 준비 완료
- [ ] 최종 검증 완료
- [ ] Git commit 완료

**1. 앱 버전 업데이트**

`pubspec.yaml` 수정:
```yaml
version: 1.0.0+1  # 적절한 버전으로 업데이트
```

**2. Release 빌드 테스트**
```bash
# Android Release 빌드
flutter build apk --release

# iOS Release 빌드 (Mac에서만)
flutter build ios --release
```

**3. 최종 체크리스트**
- [ ] 모든 기능이 정상 작동하는지 확인
- [ ] 권한 요청이 적절히 작동하는지 확인
- [ ] 오프라인 상태에서도 앱이 크래시되지 않는지 확인
- [ ] 메모리 누수가 없는지 확인
- [ ] 성능 테스트 완료

**🔴 Git Commit Point:** `git commit -m "Release build ready - version updated"`

---

## 🎯 다음 단계 개발 계획

### 우선순위 1: 핵심 기능 보완
- 휴대폰 본인인증 구현
- 아파트 인증 시스템 (OCR)
- 푸시 알림 시스템
- 소음 데이터 저장 및 분석

### 우선순위 2: 고급 기능
- 지역별 소음 랭킹
- 댓글 및 좋아요 시스템
- 사용자 프로필 관리
- 관리자 모더레이션

### 우선순위 3: 성능 최적화
- 이미지 최적화
- 캐싱 시스템
- 오프라인 지원
- 성능 모니터링

---

## ⚠️ 주의사항

1. **각 단계별 테스트 필수**: 다음 단계 진행 전 반드시 현재 단계 테스트 완료
2. **Firebase 설정 확인**: 각 기능 구현 전 Firebase Console에서 설정 활성화 확인
3. **권한 설정**: 각 플랫폼별 권한 설정 정확히 적용
4. **에러 처리**: 모든 비동기 함수에 try-catch 구문 적용
5. **Git 커밋**: 주요 기능 완료 시마다 커밋 실행

---

## 🛠️ 개발 환경 체크리스트

**개발 전 준비사항:**
- [X] Flutter SDK 3.16.0 이상 설치
- [X] Firebase CLI 설치 및 로그인
- [X] Android Studio / VS Code 설정
- [X] Git 설정 완료
- [X] Firebase 프로젝트 생성
- [ ] Google Maps API 키 발급
- [ ] 소셜 로그인 키 발급 (Google, Kakao, Naver)

---

## 📝 개발 진행 가이드

### 체크리스트 사용 방법
1. 각 단계 시작 전 해당 체크리스트 확인
2. 작업 완료 시 `[ ]`를 `[x]`로 변경
3. 모든 체크리스트 완료 후 다음 단계 진행
4. 문제 발생 시 즉시 해결 후 체크리스트 업데이트

### 문서 동기화 규칙
- 실제 구현과 다르게 개발된 경우 반드시 이 문서를 수정
- 새로운 의존성 추가 시 pubspec.yaml 섹션 업데이트
- 파일 경로 변경 시 해당 Step의 경로 수정
- 추가 설정 필요 시 해당 Step에 내용 추가

### 진행 상황 추적
- 각 PHASE 완료 시 상단 진행 상황 섹션 업데이트
- 전체 진행률 계산하여 업데이트
- Git commit 후 다음 단계 진행

이 계획서를 단계별로 따라하면서 각 단계마다 테스트를 진행하고, 문제가 발생하면 즉시 해결 후 다음 단계로 진행하세요. 