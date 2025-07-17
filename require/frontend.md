# Frontend 개발 계획서

> **Project:** 소음과 전쟁 - Flutter 기반 MVVM 아키텍처

## 1. 아키텍처 개요

### 1.1 MVVM 패턴 구조
- **Model**: 데이터 모델 및 비즈니스 로직
- **View**: UI 컴포넌트 (StatelessWidget/StatefulWidget)
- **ViewModel**: View와 Model 사이의 중개자 역할 (Provider/Riverpod 사용)

### 1.2 기술 스택
```yaml
dependencies:
  flutter: ^3.16.0
  # 상태 관리
  provider: ^6.1.1
  # 네트워킹
  dio: ^5.4.0
  # 로컬 저장소
  shared_preferences: ^2.2.2
  # 데이터베이스
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_firestore: ^4.13.6
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.6.0
  # 소음 측정 및 녹음
  noise_meter: ^5.0.1
  record: ^4.4.4
  # 권한 관리
  permission_handler: ^11.1.0
  # 위치 서비스
  geolocator: ^9.0.2
  geocoding: ^2.1.1
  # 파일 관리
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  # 이미지 처리
  image_picker: ^1.0.4
  # 지도
  google_maps_flutter: ^2.5.0
  # 푸시 알림
  firebase_messaging: ^14.7.10
  # 본인인증
  flutter_naver_login: ^1.8.0
  kakao_flutter_sdk: ^1.9.1
  # UI 컴포넌트
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
```

## 2. 프로젝트 구조

### 2.1 폴더 구조
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── utils/
│   ├── services/
│   └── extensions/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── viewmodels/
└── shared/
    ├── components/
    └── theme/
```

### 2.2 MVVM 레이어 구조

#### Model Layer (data/)
```dart
// data/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final bool isVerified;
  final String? verifiedAddress;
  final ApartmentInfo? apartmentInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.isVerified,
    this.verifiedAddress,
    this.apartmentInfo,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      isVerified: data['isVerified'] ?? false,
      verifiedAddress: data['verifiedAddress'],
      apartmentInfo: data['apartmentInfo'] != null 
          ? ApartmentInfo.fromMap(data['apartmentInfo'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

// data/models/noise_record_model.dart
class NoiseRecordModel {
  final String id;
  final String userId;
  final double maxDecibel;
  final double avgDecibel;
  final String? audioFilePath;
  final DateTime recordedAt;
  final LocationInfo? location;
  
  NoiseRecordModel({
    required this.id,
    required this.userId,
    required this.maxDecibel,
    required this.avgDecibel,
    this.audioFilePath,
    required this.recordedAt,
    this.location,
  });
}

// data/models/post_model.dart
class PostModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final String boardType;
  final List<String> imageUrls;
  final NoiseRecordModel? noiseRecord;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  
  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.boardType,
    required this.imageUrls,
    this.noiseRecord,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });
}
```

#### Repository Layer (data/repositories/)
```dart
// data/repositories/user_repository.dart
abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile(UserModel user);
  Future<void> requestApartmentVerification(String address, String imagePath);
  Future<List<UserModel>> getVerifiedUsers();
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  UserRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore, _auth = auth;
  
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return UserModel.fromFirestore(doc);
  }
  
  @override
  Future<void> updateProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'nickname': user.nickname,
      'profileImageUrl': user.profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

#### ViewModel Layer (presentation/viewmodels/)
```dart
// presentation/viewmodels/user_viewmodel.dart
class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthService _authService;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isVerified => _currentUser?.isVerified ?? false;
  
  UserViewModel({
    required UserRepository userRepository,
    required AuthService authService,
  }) : _userRepository = userRepository, _authService = authService;
  
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _userRepository.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateProfile({
    required String nickname,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;
    
    _setLoading(true);
    try {
      final updatedUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        nickname: nickname,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        isVerified: _currentUser!.isVerified,
        verifiedAddress: _currentUser!.verifiedAddress,
        apartmentInfo: _currentUser!.apartmentInfo,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _userRepository.updateProfile(updatedUser);
      _currentUser = updatedUser;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> requestApartmentVerification(String address, String imagePath) async {
    _setLoading(true);
    try {
      await _userRepository.requestApartmentVerification(address, imagePath);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// presentation/viewmodels/noise_viewmodel.dart
class NoiseViewModel extends ChangeNotifier {
  final NoiseRepository _noiseRepository;
  final NoiseMeter _noiseMeter;
  
  NoiseReading? _currentReading;
  bool _isRecording = false;
  List<double> _readings = [];
  StreamSubscription<NoiseReading>? _noiseSubscription;
  
  NoiseReading? get currentReading => _currentReading;
  bool get isRecording => _isRecording;
  double get maxDecibel => _readings.isNotEmpty ? _readings.reduce(math.max) : 0.0;
  double get avgDecibel => _readings.isNotEmpty ? _readings.reduce((a, b) => a + b) / _readings.length : 0.0;
  
  NoiseViewModel({
    required NoiseRepository noiseRepository,
    required NoiseMeter noiseMeter,
  }) : _noiseRepository = noiseRepository, _noiseMeter = noiseMeter;
  
  Future<void> startRecording() async {
    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) return;
    
    _isRecording = true;
    _readings.clear();
    _noiseSubscription = _noiseMeter.noise.listen(_onNoiseData);
    notifyListeners();
  }
  
  void stopRecording() {
    _noiseSubscription?.cancel();
    _isRecording = false;
    notifyListeners();
  }
  
  Future<void> saveNoiseRecord() async {
    if (_readings.isEmpty) return;
    
    final record = NoiseRecordModel(
      id: '',
      userId: '', // 현재 사용자 ID
      maxDecibel: maxDecibel,
      avgDecibel: avgDecibel,
      recordedAt: DateTime.now(),
      audioFilePath: null, // 녹음 파일 저장 로직 추가 필요
      location: null, // 위치 정보 추가 필요
    );
    
    await _noiseRepository.saveRecord(record);
  }
  
  void _onNoiseData(NoiseReading reading) {
    _currentReading = reading;
    _readings.add(reading.meanDecibel);
    notifyListeners();
  }
  
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
```

#### View Layer (presentation/pages/)
```dart
// presentation/pages/home_page.dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('소음과 전쟁'),
        actions: [
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              return IconButton(
                icon: CircleAvatar(
                  backgroundImage: userViewModel.currentUser?.profileImageUrl != null
                      ? NetworkImage(userViewModel.currentUser!.profileImageUrl!)
                      : null,
                  child: userViewModel.currentUser?.profileImageUrl == null
                      ? Icon(Icons.person)
                      : null,
                ),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 소음 측정 섹션
          Expanded(
            flex: 2,
            child: NoiseSection(),
          ),
          // 커뮤니티 섹션
          Expanded(
            flex: 3,
            child: CommunitySection(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

// presentation/pages/noise_measurement_page.dart
class NoiseMeasurementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('소음 측정')),
      body: Consumer<NoiseViewModel>(
        builder: (context, noiseViewModel, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 소음 레벨 표시
              NoiseVisualizerWidget(
                decibel: noiseViewModel.currentReading?.meanDecibel ?? 0.0,
                isRecording: noiseViewModel.isRecording,
              ),
              SizedBox(height: 32),
              // 측정 버튼
              ElevatedButton(
                onPressed: noiseViewModel.isRecording
                    ? noiseViewModel.stopRecording
                    : noiseViewModel.startRecording,
                child: Text(noiseViewModel.isRecording ? '측정 중지' : '측정 시작'),
              ),
              if (!noiseViewModel.isRecording && noiseViewModel.maxDecibel > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('최고: ${noiseViewModel.maxDecibel.toStringAsFixed(1)} dB'),
                      Text('평균: ${noiseViewModel.avgDecibel.toStringAsFixed(1)} dB'),
                      ElevatedButton(
                        onPressed: noiseViewModel.saveNoiseRecord,
                        child: Text('게시글에 첨부'),
                      ),
                    ],
                  ),
                ),
              // 법적 고지
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '※ 측정값은 법적 효력이 없는 참고용 데이터입니다.',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// presentation/pages/apartment_verification_page.dart
class ApartmentVerificationPage extends StatefulWidget {
  @override
  _ApartmentVerificationPageState createState() => _ApartmentVerificationPageState();
}

class _ApartmentVerificationPageState extends State<ApartmentVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  File? _selectedImage;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('아파트 인증')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '거주 중인 아파트를 인증하면 해당 지역의 소음 정보를 더 자세히 확인할 수 있습니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: '아파트 주소',
                  hintText: '예: 서울시 강남구 역삼동 123-45',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '주소를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text('관리비 고지서 또는 거주 증명 서류'),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48),
                            Text('사진 업로드'),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 24),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  return ElevatedButton(
                    onPressed: userViewModel.isLoading ? null : _submitVerification,
                    child: userViewModel.isLoading
                        ? CircularProgressIndicator()
                        : Text('인증 요청'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 정보를 입력해주세요.')),
      );
      return;
    }
    
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    
    // 이미지 업로드 및 인증 요청
    await userViewModel.requestApartmentVerification(
      _addressController.text,
      _selectedImage!.path,
    );
    
    if (userViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userViewModel.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 요청이 완료되었습니다. 검토 후 결과를 알려드리겠습니다.')),
      );
      Navigator.pop(context);
    }
  }
}
```

## 3. 핵심 컴포넌트

### 3.1 소음 측정 컴포넌트
```dart
// presentation/widgets/noise_visualizer_widget.dart
class NoiseVisualizerWidget extends StatelessWidget {
  final double decibel;
  final bool isRecording;
  
  const NoiseVisualizerWidget({
    Key? key,
    required this.decibel,
    required this.isRecording,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${decibel.toStringAsFixed(1)} dB',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _getDecibelColor(decibel),
          ),
        ),
        SizedBox(height: 16),
        Text(
          _getDecibelDescription(decibel),
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 32),
        // 실시간 파형 또는 원형 인디케이터
        if (isRecording)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getDecibelColor(decibel).withOpacity(0.3),
            ),
            child: Center(
              child: Icon(
                Icons.mic,
                size: 48,
                color: _getDecibelColor(decibel),
              ),
            ),
          ),
      ],
    );
  }
  
  Color _getDecibelColor(double decibel) {
    if (decibel < 40) return Colors.green;
    if (decibel < 60) return Colors.yellow;
    if (decibel < 80) return Colors.orange;
    return Colors.red;
  }
  
  String _getDecibelDescription(double decibel) {
    if (decibel < 40) return '조용함';
    if (decibel < 60) return '보통';
    if (decibel < 80) return '시끄러움';
    return '매우 시끄러움';
  }
}
```

### 3.2 커뮤니티 컴포넌트
```dart
// presentation/widgets/post_card_widget.dart
class PostCardWidget extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  
  const PostCardWidget({
    Key? key,
    required this.post,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 배지
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.category,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // 제목
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              // 내용 미리보기
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              // 소음 데이터가 있는 경우
              if (post.noiseRecord != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.volume_up, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        '최고 ${post.noiseRecord!.maxDecibel.toStringAsFixed(1)}dB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 8),
              // 하단 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MM/dd HH:mm').format(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text('${post.likeCount}'),
                      SizedBox(width: 16),
                      Icon(Icons.comment, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${post.commentCount}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 4. 상태 관리 및 의존성 주입

### 4.1 Provider 설정
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseStorage>(create: (_) => FirebaseStorage.instance),
        
        // Repositories
        ProxyProvider2<FirebaseFirestore, FirebaseAuth, UserRepository>(
          update: (_, firestore, auth, __) => UserRepositoryImpl(
            firestore: firestore,
            auth: auth,
          ),
        ),
        
        // ViewModels
        ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
          create: (context) => UserViewModel(
            userRepository: context.read<UserRepository>(),
            authService: context.read<AuthService>(),
          ),
          update: (_, userRepository, previous) => previous ?? UserViewModel(
            userRepository: userRepository,
            authService: context.read<AuthService>(),
          ),
        ),
        
        ChangeNotifierProvider<NoiseViewModel>(
          create: (context) => NoiseViewModel(
            noiseRepository: context.read<NoiseRepository>(),
            noiseMeter: NoiseMeter(onError),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

## 5. 네비게이션 및 라우팅

### 5.1 라우트 설정
```dart
// app/routes.dart
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String noiseMeasurement = '/noise-measurement';
  static const String postDetail = '/post-detail';
  static const String createPost = '/create-post';
  static const String apartmentVerification = '/apartment-verification';
  static const String noiseMap = '/noise-map';
  static const String ranking = '/ranking';
  
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => HomePage(),
    login: (context) => LoginPage(),
    profile: (context) => ProfilePage(),
    noiseMeasurement: (context) => NoiseMeasurementPage(),
    postDetail: (context) => PostDetailPage(),
    createPost: (context) => CreatePostPage(),
    apartmentVerification: (context) => ApartmentVerificationPage(),
    noiseMap: (context) => NoiseMapPage(),
    ranking: (context) => RankingPage(),
  };
}
```

## 6. 테스트 전략

### 6.1 단위 테스트
```dart
// test/viewmodels/user_viewmodel_test.dart
void main() {
  group('UserViewModel', () {
    late UserViewModel userViewModel;
    late MockUserRepository mockUserRepository;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockUserRepository = MockUserRepository();
      mockAuthService = MockAuthService();
      userViewModel = UserViewModel(
        userRepository: mockUserRepository,
        authService: mockAuthService,
      );
    });
    
    test('사용자 프로필 업데이트 테스트', () async {
      // Given
      const nickname = 'testuser';
      const profileImageUrl = 'https://example.com/image.jpg';
      
      // When
      await userViewModel.updateProfile(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
      );
      
      // Then
      expect(userViewModel.error, isNull);
      verify(mockUserRepository.updateProfile(any)).called(1);
    });
  });
}
```

### 6.2 위젯 테스트
```dart
// test/widgets/noise_visualizer_widget_test.dart
void main() {
  group('NoiseVisualizerWidget', () {
    testWidgets('소음 레벨에 따른 색상 표시 테스트', (tester) async {
      // Given
      const decibel = 70.0;
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: NoiseVisualizerWidget(
            decibel: decibel,
            isRecording: false,
          ),
        ),
      );
      
      // Then
      expect(find.text('70.0 dB'), findsOneWidget);
      expect(find.text('시끄러움'), findsOneWidget);
    });
  });
}
```

## 7. 성능 최적화

### 7.1 메모리 관리
- `dispose()` 메서드에서 리소스 해제
- `StreamSubscription` 정리
- 이미지 캐싱 및 압축

### 7.2 네트워크 최적화
- 페이지네이션 구현
- 이미지 지연 로딩
- 오프라인 캐싱

### 7.3 UI 최적화
- `const` 위젯 사용
- `ListView.builder` 사용
- 불필요한 `setState()` 호출 최소화

이 frontend 개발 계획서는 database.md, security.md, backend.md와 연계하여 전체 시스템을 구성합니다. 