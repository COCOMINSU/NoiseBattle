# 🎨 NoiseBattle 디자인 시스템 문서

## 📋 개요
NoiseBattle 앱은 3가지 테마 모드를 지원하며, 각각 다른 디자인 철학과 사용자 경험을 제공합니다.

### 🌟 테마 모드
1. **라이트** - iOS 네이티브 스타일 (iOS 18 Liquid Glass 효과)
2. **다크** - Discord 스타일 
3. **소음지옥** - 검붉은 전쟁 테마 (고급스럽고 차분한 느낌)

---

## 🎨 색상 팔레트

### 테마 정의
```dart
// 테마 모드 Enum
enum ThemeMode {
  light,    // 라이트
  dark,     // 다크
  hell,     // 소음지옥
}

// 테마 이름 매핑
Map<ThemeMode, String> themeNames = {
  ThemeMode.light: '라이트',
  ThemeMode.dark: '다크',
  ThemeMode.hell: '소음지옥',
};

// 테마 아이콘 매핑
Map<ThemeMode, IconData> themeIcons = {
  ThemeMode.light: Icons.wb_sunny,
  ThemeMode.dark: Icons.nights_stay,
  ThemeMode.hell: Icons.whatshot,
};
```

### 1️⃣ 라이트 (iOS 18 Liquid Glass Style)
```dart
// Primary Colors
static const Color primary = Color(0xFF007AFF);           // iOS Blue
static const Color primaryLight = Color(0xFF5AC8FA);      // Light Blue
static const Color primaryDark = Color(0xFF0051D5);       // Dark Blue

// Background Colors
static const Color background = Color(0xFFF2F2F7);        // iOS Light Gray
static const Color surfacePrimary = Color(0xFFFFFFFF);    // Pure White
static const Color surfaceSecondary = Color(0xFFF2F2F7);  // Light Gray
static const Color surfaceTertiary = Color(0xFFE5E5EA);   // Medium Gray

// Text Colors
static const Color textPrimary = Color(0xFF000000);       // Black
static const Color textSecondary = Color(0xFF3C3C43);     // Dark Gray
static const Color textTertiary = Color(0xFF8E8E93);      // Medium Gray
static const Color textQuaternary = Color(0xFFC7C7CC);    // Light Gray

// Accent Colors
static const Color accent = Color(0xFF34C759);            // iOS Green
static const Color error = Color(0xFFFF3B30);             // iOS Red
static const Color warning = Color(0xFFFF9500);           // iOS Orange
static const Color success = Color(0xFF34C759);           // iOS Green
```

### 2️⃣ 다크 (Discord Style)
```dart
// Primary Colors
static const Color primary = Color(0xFF5865F2);           // Discord Blurple
static const Color primaryLight = Color(0xFF7289DA);      // Light Blurple
static const Color primaryDark = Color(0xFF4752C4);       // Dark Blurple

// Background Colors
static const Color background = Color(0xFF1E2124);        // Discord Dark
static const Color surfacePrimary = Color(0xFF2F3136);    // Discord Medium
static const Color surfaceSecondary = Color(0xFF36393F);  // Discord Light
static const Color surfaceTertiary = Color(0xFF40444B);   // Discord Lighter

// Text Colors
static const Color textPrimary = Color(0xFFFFFFFF);       // Pure White
static const Color textSecondary = Color(0xFFB9BBBE);     // Light Gray
static const Color textTertiary = Color(0xFF8E9297);      // Medium Gray
static const Color textQuaternary = Color(0xFF72767D);    // Dark Gray

// Accent Colors
static const Color accent = Color(0xFF00D166);            // Discord Green
static const Color error = Color(0xFFED4245);             // Discord Red
static const Color warning = Color(0xFFFAA61A);           // Discord Yellow
static const Color success = Color(0xFF57F287);           // Discord Green
```

### 3️⃣ 소음지옥 (Hell/War Theme)
```dart
// Primary Colors
static const Color primary = Color(0xFF8B0000);           // Dark Red
static const Color primaryLight = Color(0xFFCC6666);      // Muted Red
static const Color primaryDark = Color(0xFF660000);       // Darker Red

// Background Colors
static const Color background = Color(0xFF1A1A1A);        // Almost Black
static const Color surfacePrimary = Color(0xFF2D1B1B);    // Dark Brown-Red
static const Color surfaceSecondary = Color(0xFF3D2B2B);  // Medium Brown-Red
static const Color surfaceTertiary = Color(0xFF4D3B3B);   // Light Brown-Red

// Text Colors
static const Color textPrimary = Color(0xFFF5F5F5);       // Off-White
static const Color textSecondary = Color(0xFFD3D3D3);     // Light Gray
static const Color textTertiary = Color(0xFFB1B1B1);      // Medium Gray
static const Color textQuaternary = Color(0xFF8F8F8F);    // Dark Gray

// Accent Colors
static const Color accent = Color(0xFFCC6666);            // Muted Red
static const Color error = Color(0xFFFF4444);             // Bright Red
static const Color warning = Color(0xFFFFAA44);           // Orange
static const Color success = Color(0xFF66CC66);           // Muted Green
```

---

## 🔤 타이포그래피

### 폰트 패밀리
```dart
// Primary Font
static const String primaryFont = 'SF Pro Display';  // iOS Style
static const String secondaryFont = 'SF Pro Text';   // iOS Style
static const String codeFont = 'SF Mono';           // iOS Monospace

// Fallback Fonts
static const String fallbackFont = 'Roboto';        // Android Fallback
```

### 텍스트 스타일
```dart
// Headlines
static const TextStyle headline1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.8,
);

static const TextStyle headline2 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.6,
);

static const TextStyle headline3 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.4,
);

// Body Text
static const TextStyle bodyLarge = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.2,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.1,
);

static const TextStyle bodySmall = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
);

// Labels
static const TextStyle labelLarge = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.1,
);

static const TextStyle labelMedium = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
);

static const TextStyle labelSmall = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);
```

---

## 📐 간격 및 크기 시스템

### 패딩/마진
```dart
// Spacing Scale
static const double xs = 4.0;
static const double sm = 8.0;
static const double md = 16.0;
static const double lg = 24.0;
static const double xl = 32.0;
static const double xxl = 48.0;

// Component Sizes
static const double buttonHeight = 44.0;        // iOS Standard
static const double inputHeight = 44.0;         // iOS Standard
static const double cardRadius = 12.0;          // iOS Standard
static const double buttonRadius = 8.0;         // iOS Standard
static const double iconSize = 24.0;            // Standard Icon
static const double iconSmall = 16.0;           // Small Icon
static const double iconLarge = 32.0;           // Large Icon
```

### 그림자 및 효과
```dart
// 라이트 Shadows (iOS Style)
static const List<BoxShadow> lightShadow = [
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  ),
];

static const List<BoxShadow> lightShadowLarge = [
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  ),
];

// 다크 Shadows (Discord Style)
static const List<BoxShadow> darkShadow = [
  BoxShadow(
    color: Color(0x40000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];

// 소음지옥 Shadows (War Theme)
static const List<BoxShadow> hellShadow = [
  BoxShadow(
    color: Color(0x80000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];

// Liquid Glass Effect (iOS 18)
static const List<BoxShadow> liquidGlass = [
  BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  ),
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];
```

---

## 🧩 컴포넌트 스타일링 가이드

### 버튼 스타일
```dart
// Primary Button
ButtonStyle primaryButton = ElevatedButton.styleFrom(
  backgroundColor: primary,
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, buttonHeight),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
  ),
  elevation: 0,
);

// Secondary Button
ButtonStyle secondaryButton = OutlinedButton.styleFrom(
  foregroundColor: primary,
  side: BorderSide(color: primary, width: 1.5),
  minimumSize: Size(double.infinity, buttonHeight),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
  ),
);

// Text Button
ButtonStyle textButton = TextButton.styleFrom(
  foregroundColor: primary,
  minimumSize: Size(double.infinity, buttonHeight),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
  ),
);
```

### 카드 스타일
```dart
// 라이트 Card
BoxDecoration lightCard = BoxDecoration(
  color: surfacePrimary,
  borderRadius: BorderRadius.circular(cardRadius),
  boxShadow: lightShadow,
  border: Border.all(
    color: Color(0xFFE5E5EA),
    width: 0.5,
  ),
);

// 다크 Card
BoxDecoration darkCard = BoxDecoration(
  color: surfacePrimary,
  borderRadius: BorderRadius.circular(cardRadius),
  boxShadow: darkShadow,
);

// 소음지옥 Card
BoxDecoration hellCard = BoxDecoration(
  color: surfacePrimary,
  borderRadius: BorderRadius.circular(cardRadius),
  boxShadow: hellShadow,
  border: Border.all(
    color: Color(0xFF4D3B3B),
    width: 1,
  ),
);
```

### 입력 필드 스타일
```dart
// Input Decoration
InputDecoration inputDecoration = InputDecoration(
  filled: true,
  fillColor: surfaceSecondary,
  contentPadding: EdgeInsets.symmetric(horizontal: md, vertical: sm),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(buttonRadius),
    borderSide: BorderSide(color: primary, width: 2),
  ),
  hintStyle: TextStyle(color: textTertiary),
);
```

---

## 🎭 애니메이션 및 전환 효과

### 애니메이션 시간
```dart
// Duration Constants
static const Duration fast = Duration(milliseconds: 150);
static const Duration medium = Duration(milliseconds: 300);
static const Duration slow = Duration(milliseconds: 500);
static const Duration extraSlow = Duration(milliseconds: 800);

// Curve Constants
static const Curve easeInOut = Curves.easeInOut;
static const Curve easeOut = Curves.easeOut;
static const Curve easeIn = Curves.easeIn;
static const Curve bounce = Curves.bounceOut;
```

### 페이지 전환
```dart
// iOS Style Page Transition
PageRouteBuilder iOSPageTransition(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
```

---

## 🔢 아이콘 및 이미지 가이드

### 아이콘 스타일
- **라이트**: SF Symbols 스타일 (얇고 깔끔한 라인)
- **다크**: Discord 스타일 (약간 둥근 모서리)
- **소음지옥**: 각진 형태, 약간 거친 느낌

### 이미지 처리
```dart
// 라이트: Bright and Clean
ColorFilter lightImageFilter = ColorFilter.mode(
  Colors.transparent,
  BlendMode.multiply,
);

// 다크: Slightly Desaturated
ColorFilter darkImageFilter = ColorFilter.mode(
  Colors.grey.withOpacity(0.1),
  BlendMode.multiply,
);

// 소음지옥: Red Tinted
ColorFilter hellImageFilter = ColorFilter.mode(
  Color(0x1A8B0000),
  BlendMode.multiply,
);
```

---

## 📱 반응형 디자인

### 브레이크포인트
```dart
// Device Breakpoints
static const double mobileBreakpoint = 480;
static const double tabletBreakpoint = 768;
static const double desktopBreakpoint = 1024;

// Responsive Padding
double getResponsivePadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < mobileBreakpoint) return md;
  if (width < tabletBreakpoint) return lg;
  return xl;
}
```

---

## 🎯 사용성 가이드라인

### 접근성
- **최소 터치 영역**: 44x44 픽셀 (iOS 가이드라인)
- **텍스트 대비율**: 최소 4.5:1 (WCAG AA 준수)
- **색상 의존성**: 색상 외 다른 시각적 단서 제공

### 일관성 규칙
- 모든 상호작용 요소는 feedback 제공
- 로딩 상태는 스켈레톤 UI 또는 스피너 사용
- 에러 메시지는 명확하고 도움이 되는 내용 포함

---

## 🛠️ 구현 우선순위

### Phase 1: 기본 테마 시스템
1. 색상 팔레트 구현
2. 기본 텍스트 스타일 적용
3. 기본 컴포넌트 스타일링

### Phase 2: 고급 효과
1. 그림자 및 효과 적용
2. 애니메이션 구현
3. 반응형 디자인 적용

### Phase 3: 사용자 경험 개선
1. 접근성 기능 추가
2. 시스템 테마 자동 감지 (라이트/다크)
3. 사용자 설정 저장 (소음지옥 모드 포함)

---

## 📝 개발 참고사항

### 테마 전환 시 주의사항
- 모든 색상은 테마에 따라 동적으로 변경되어야 함
- 하드코딩된 색상 값 사용 금지
- 테마 변경 시 애니메이션 처리

### 성능 최적화
- 불필요한 리빌드 방지
- 이미지 캐싱 적용
- 애니메이션 최적화

### 테스트 항목
- 모든 테마에서 가독성 확인
- 다양한 화면 크기에서 테스트
- 접근성 도구로 검증

### 테마 사용 예시
```dart
// 테마 전환 예시
class ThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.light;
  
  ThemeMode get currentTheme => _currentTheme;
  String get currentThemeName => themeNames[_currentTheme] ?? '라이트';
  
  void switchTheme(ThemeMode newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }
  
  void toggleTheme() {
    switch (_currentTheme) {
      case ThemeMode.light:
        _currentTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _currentTheme = ThemeMode.hell;
        break;
      case ThemeMode.hell:
        _currentTheme = ThemeMode.light;
        break;
    }
    notifyListeners();
  }
}
```

---

*이 문서는 NoiseBattle 앱의 디자인 시스템을 정의합니다. 개발 중 변경사항이 있을 경우 이 문서를 업데이트해주세요.* 