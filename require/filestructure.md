# File Structure 개발 계획서

> **Project:** 소음과 전쟁 - 프로젝트 파일 구조 및 보안 관리

## 1. 전체 프로젝트 구조

### 1.1 루트 디렉토리 구조
```
noisebattle/
├── README.md
├── .gitignore
├── .env.example
├── .env.local                     # 로컬 환경 변수 (GIT 제외)
├── .env.development              # 개발 환경 변수 (GIT 제외)
├── .env.production               # 운영 환경 변수 (GIT 제외)
├── docker-compose.yml
├── Dockerfile
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── android/
├── ios/
├── lib/
├── test/
├── integration_test/
├── assets/
├── docs/
├── scripts/
├── firebase/
├── monitoring/
└── deployment/
```

### 1.2 주요 디렉토리 설명
- **`lib/`**: Flutter 애플리케이션 소스 코드
- **`firebase/`**: Firebase 관련 설정 및 Cloud Functions
- **`test/`**: 단위 테스트 및 위젯 테스트
- **`integration_test/`**: 통합 테스트
- **`assets/`**: 이미지, 폰트, 설정 파일 등
- **`docs/`**: 개발 문서 및 API 문서
- **`scripts/`**: 빌드, 배포 스크립트
- **`monitoring/`**: 모니터링 및 로깅 설정
- **`deployment/`**: 배포 관련 설정

## 2. Flutter 앱 구조 (lib/)

### 2.1 MVVM 패턴 기반 구조
```
lib/
├── main.dart                     # 앱 엔트리 포인트
├── app/
│   ├── app.dart                  # 앱 초기화 및 설정
│   ├── routes.dart               # 라우팅 설정
│   ├── theme.dart                # 테마 설정
│   └── constants.dart            # 앱 상수
├── core/
│   ├── constants/
│   │   ├── api_constants.dart    # API 관련 상수
│   │   ├── app_constants.dart    # 앱 상수
│   │   └── string_constants.dart # 문자열 상수
│   ├── utils/
│   │   ├── logger.dart           # 로깅 유틸리티
│   │   ├── validators.dart       # 유효성 검증
│   │   ├── formatters.dart       # 포맷터
│   │   ├── helpers.dart          # 헬퍼 함수
│   │   └── device_info.dart      # 디바이스 정보
│   ├── services/
│   │   ├── auth_service.dart     # 인증 서비스
│   │   ├── database_service.dart # 데이터베이스 서비스
│   │   ├── storage_service.dart  # 저장소 서비스
│   │   ├── notification_service.dart # 알림 서비스
│   │   ├── location_service.dart # 위치 서비스
│   │   └── noise_service.dart    # 소음 측정 서비스
│   ├── security/
│   │   ├── encryption_service.dart # 암호화 서비스
│   │   ├── token_manager.dart    # 토큰 관리
│   │   ├── root_detection.dart   # 루트 탐지
│   │   └── app_signature.dart    # 앱 서명 검증
│   ├── legal/
│   │   ├── consent_manager.dart  # 동의 관리
│   │   ├── privacy_manager.dart  # 개인정보 관리
│   │   └── content_moderation.dart # 콘텐츠 모더레이션
│   ├── network/
│   │   ├── dio_client.dart       # HTTP 클라이언트
│   │   ├── api_client.dart       # API 클라이언트
│   │   ├── network_info.dart     # 네트워크 정보
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart # 인증 인터셉터
│   │       ├── logging_interceptor.dart # 로깅 인터셉터
│   │       └── error_interceptor.dart # 에러 인터셉터
│   ├── errors/
│   │   ├── exceptions.dart       # 예외 클래스
│   │   ├── failures.dart         # 실패 클래스
│   │   └── error_handler.dart    # 에러 핸들러
│   └── extensions/
│       ├── string_extensions.dart # 문자열 확장
│       ├── datetime_extensions.dart # 날짜 확장
│       └── widget_extensions.dart # 위젯 확장
├── data/
│   ├── models/
│   │   ├── user_model.dart       # 사용자 모델
│   │   ├── post_model.dart       # 게시글 모델
│   │   ├── comment_model.dart    # 댓글 모델
│   │   ├── apartment_model.dart  # 아파트 모델
│   │   ├── noise_record_model.dart # 소음 기록 모델
│   │   ├── notification_model.dart # 알림 모델
│   │   └── ranking_model.dart    # 랭킹 모델
│   ├── repositories/
│   │   ├── user_repository.dart  # 사용자 저장소
│   │   ├── post_repository.dart  # 게시글 저장소
│   │   ├── comment_repository.dart # 댓글 저장소
│   │   ├── apartment_repository.dart # 아파트 저장소
│   │   ├── noise_repository.dart # 소음 저장소
│   │   └── notification_repository.dart # 알림 저장소
│   └── datasources/
│       ├── local/
│       │   ├── local_storage.dart # 로컬 저장소
│       │   ├── secure_storage.dart # 보안 저장소
│       │   └── cache_manager.dart # 캐시 관리
│       ├── remote/
│       │   ├── firebase_datasource.dart # Firebase 데이터소스
│       │   ├── api_datasource.dart # API 데이터소스
│       │   └── websocket_datasource.dart # 웹소켓 데이터소스
│       └── external/
│           ├── maps_datasource.dart # 지도 데이터소스
│           ├── ocr_datasource.dart # OCR 데이터소스
│           └── push_datasource.dart # 푸시 데이터소스
├── domain/
│   ├── entities/
│   │   ├── user.dart             # 사용자 엔티티
│   │   ├── post.dart             # 게시글 엔티티
│   │   ├── comment.dart          # 댓글 엔티티
│   │   ├── apartment.dart        # 아파트 엔티티
│   │   ├── noise_record.dart     # 소음 기록 엔티티
│   │   └── notification.dart     # 알림 엔티티
│   ├── repositories/
│   │   ├── user_repository.dart  # 사용자 저장소 인터페이스
│   │   ├── post_repository.dart  # 게시글 저장소 인터페이스
│   │   └── ... (다른 저장소 인터페이스)
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart # 로그인 유스케이스
│       │   ├── register_usecase.dart # 회원가입 유스케이스
│       │   └── logout_usecase.dart # 로그아웃 유스케이스
│       ├── posts/
│       │   ├── create_post_usecase.dart # 게시글 생성
│       │   ├── get_posts_usecase.dart # 게시글 조회
│       │   └── delete_post_usecase.dart # 게시글 삭제
│       ├── noise/
│       │   ├── measure_noise_usecase.dart # 소음 측정
│       │   ├── save_noise_record_usecase.dart # 소음 기록 저장
│       │   └── get_noise_history_usecase.dart # 소음 기록 조회
│       └── apartments/
│           ├── verify_apartment_usecase.dart # 아파트 인증
│           ├── get_apartment_info_usecase.dart # 아파트 정보 조회
│           └── get_apartment_ranking_usecase.dart # 아파트 랭킹 조회
├── presentation/
│   ├── pages/
│   │   ├── splash/
│   │   │   ├── splash_page.dart  # 스플래시 페이지
│   │   │   └── splash_viewmodel.dart # 스플래시 뷰모델
│   │   ├── auth/
│   │   │   ├── login_page.dart   # 로그인 페이지
│   │   │   ├── login_viewmodel.dart # 로그인 뷰모델
│   │   │   ├── register_page.dart # 회원가입 페이지
│   │   │   ├── register_viewmodel.dart # 회원가입 뷰모델
│   │   │   ├── phone_verification_page.dart # 휴대폰 인증 페이지
│   │   │   └── phone_verification_viewmodel.dart # 휴대폰 인증 뷰모델
│   │   ├── home/
│   │   │   ├── home_page.dart    # 홈 페이지
│   │   │   ├── home_viewmodel.dart # 홈 뷰모델
│   │   │   └── widgets/
│   │   │       ├── noise_section.dart # 소음 섹션
│   │   │       └── community_section.dart # 커뮤니티 섹션
│   │   ├── noise/
│   │   │   ├── noise_measurement_page.dart # 소음 측정 페이지
│   │   │   ├── noise_measurement_viewmodel.dart # 소음 측정 뷰모델
│   │   │   ├── noise_history_page.dart # 소음 기록 페이지
│   │   │   ├── noise_history_viewmodel.dart # 소음 기록 뷰모델
│   │   │   └── widgets/
│   │   │       ├── noise_visualizer.dart # 소음 시각화 위젯
│   │   │       └── noise_level_indicator.dart # 소음 레벨 표시
│   │   ├── community/
│   │   │   ├── post_list_page.dart # 게시글 목록 페이지
│   │   │   ├── post_list_viewmodel.dart # 게시글 목록 뷰모델
│   │   │   ├── post_detail_page.dart # 게시글 상세 페이지
│   │   │   ├── post_detail_viewmodel.dart # 게시글 상세 뷰모델
│   │   │   ├── create_post_page.dart # 게시글 작성 페이지
│   │   │   ├── create_post_viewmodel.dart # 게시글 작성 뷰모델
│   │   │   └── widgets/
│   │   │       ├── post_card.dart # 게시글 카드
│   │   │       ├── comment_item.dart # 댓글 아이템
│   │   │       └── post_filter.dart # 게시글 필터
│   │   ├── profile/
│   │   │   ├── profile_page.dart # 프로필 페이지
│   │   │   ├── profile_viewmodel.dart # 프로필 뷰모델
│   │   │   ├── edit_profile_page.dart # 프로필 편집 페이지
│   │   │   ├── edit_profile_viewmodel.dart # 프로필 편집 뷰모델
│   │   │   ├── apartment_verification_page.dart # 아파트 인증 페이지
│   │   │   ├── apartment_verification_viewmodel.dart # 아파트 인증 뷰모델
│   │   │   └── widgets/
│   │   │       ├── profile_header.dart # 프로필 헤더
│   │   │       └── verification_form.dart # 인증 폼
│   │   ├── ranking/
│   │   │   ├── ranking_page.dart # 랭킹 페이지
│   │   │   ├── ranking_viewmodel.dart # 랭킹 뷰모델
│   │   │   ├── noise_map_page.dart # 소음 지도 페이지
│   │   │   ├── noise_map_viewmodel.dart # 소음 지도 뷰모델
│   │   │   └── widgets/
│   │   │       ├── ranking_item.dart # 랭킹 아이템
│   │   │       └── noise_map_marker.dart # 소음 지도 마커
│   │   ├── settings/
│   │   │   ├── settings_page.dart # 설정 페이지
│   │   │   ├── settings_viewmodel.dart # 설정 뷰모델
│   │   │   ├── privacy_policy_page.dart # 개인정보 처리방침
│   │   │   ├── terms_of_service_page.dart # 서비스 이용약관
│   │   │   └── widgets/
│   │   │       ├── settings_item.dart # 설정 아이템
│   │   │       └── consent_toggle.dart # 동의 토글
│   │   └── admin/
│   │       ├── admin_dashboard_page.dart # 관리자 대시보드
│   │       ├── admin_dashboard_viewmodel.dart # 관리자 대시보드 뷰모델
│   │       ├── content_moderation_page.dart # 콘텐츠 모더레이션
│   │       ├── content_moderation_viewmodel.dart # 콘텐츠 모더레이션 뷰모델
│   │       └── widgets/
│   │           ├── moderation_item.dart # 모더레이션 아이템
│   │           └── admin_stats_card.dart # 관리자 통계 카드
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_app_bar.dart # 커스텀 앱바
│   │   │   ├── custom_button.dart # 커스텀 버튼
│   │   │   ├── custom_text_field.dart # 커스텀 텍스트 필드
│   │   │   ├── loading_indicator.dart # 로딩 인디케이터
│   │   │   ├── error_widget.dart # 에러 위젯
│   │   │   ├── empty_state_widget.dart # 빈 상태 위젯
│   │   │   ├── confirmation_dialog.dart # 확인 다이얼로그
│   │   │   └── bottom_navigation_bar.dart # 하단 네비게이션 바
│   │   ├── noise/
│   │   │   ├── noise_meter_widget.dart # 소음 측정 위젯
│   │   │   ├── noise_chart_widget.dart # 소음 차트 위젯
│   │   │   └── noise_level_badge.dart # 소음 레벨 배지
│   │   ├── community/
│   │   │   ├── post_card_widget.dart # 게시글 카드 위젯
│   │   │   ├── comment_widget.dart # 댓글 위젯
│   │   │   ├── like_button_widget.dart # 좋아요 버튼 위젯
│   │   │   └── category_chip.dart # 카테고리 칩
│   │   ├── map/
│   │   │   ├── custom_map_widget.dart # 커스텀 지도 위젯
│   │   │   ├── noise_marker_widget.dart # 소음 마커 위젯
│   │   │   └── map_legend_widget.dart # 지도 범례 위젯
│   │   └── forms/
│   │       ├── image_picker_widget.dart # 이미지 선택 위젯
│   │       ├── location_picker_widget.dart # 위치 선택 위젯
│   │       ├── date_picker_widget.dart # 날짜 선택 위젯
│   │       └── validation_text_field.dart # 유효성 검사 텍스트 필드
│   └── viewmodels/
│       ├── base_viewmodel.dart    # 기본 뷰모델
│       ├── auth_viewmodel.dart    # 인증 뷰모델
│       ├── user_viewmodel.dart    # 사용자 뷰모델
│       ├── post_viewmodel.dart    # 게시글 뷰모델
│       ├── noise_viewmodel.dart   # 소음 뷰모델
│       └── apartment_viewmodel.dart # 아파트 뷰모델
├── shared/
│   ├── components/
│   │   ├── adaptive_scaffold.dart # 적응형 스캐폴드
│   │   ├── responsive_builder.dart # 반응형 빌더
│   │   └── platform_widget.dart  # 플랫폼 위젯
│   ├── theme/
│   │   ├── app_colors.dart       # 앱 색상
│   │   ├── app_text_styles.dart  # 앱 텍스트 스타일
│   │   ├── app_theme.dart        # 앱 테마
│   │   └── app_dimensions.dart   # 앱 크기
│   ├── localizations/
│   │   ├── app_localizations.dart # 앱 로컬라이제이션
│   │   ├── l10n.dart             # 로컬라이제이션 설정
│   │   └── messages_ko.dart      # 한국어 메시지
│   └── mixins/
│       ├── validation_mixin.dart # 유효성 검사 믹스인
│       ├── loading_mixin.dart    # 로딩 믹스인
│       └── error_handling_mixin.dart # 에러 처리 믹스인
└── generated/
    ├── assets.dart               # 자동 생성된 assets
    ├── fonts.dart                # 자동 생성된 fonts
    └── l10n/                     # 자동 생성된 로컬라이제이션
```

## 3. Firebase 프로젝트 구조

### 3.1 Firebase 디렉토리 구조
```
firebase/
├── .firebaserc
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── database.rules.json
├── hosting/
│   ├── public/
│   │   ├── index.html
│   │   ├── 404.html
│   │   └── assets/
│   └── firebase.json
├── functions/
│   ├── package.json
│   ├── package-lock.json
│   ├── .env.example
│   ├── .env                      # 환경 변수 (GIT 제외)
│   ├── index.js                  # 함수 엔트리 포인트
│   ├── src/
│   │   ├── auth/
│   │   │   ├── authFunctions.js  # 인증 관련 함수
│   │   │   ├── authSecurity.js   # 인증 보안
│   │   │   └── authMiddleware.js # 인증 미들웨어
│   │   ├── users/
│   │   │   ├── userFunctions.js  # 사용자 관련 함수
│   │   │   ├── userValidation.js # 사용자 검증
│   │   │   └── userUtils.js      # 사용자 유틸리티
│   │   ├── posts/
│   │   │   ├── postFunctions.js  # 게시글 관련 함수
│   │   │   ├── postModeration.js # 게시글 모더레이션
│   │   │   └── postAnalytics.js  # 게시글 분석
│   │   ├── notifications/
│   │   │   ├── notificationFunctions.js # 알림 관련 함수
│   │   │   ├── pushNotifications.js # 푸시 알림
│   │   │   └── emailNotifications.js # 이메일 알림
│   │   ├── analytics/
│   │   │   ├── analyticsFunctions.js # 분석 관련 함수
│   │   │   ├── bigqueryExport.js # BigQuery 내보내기
│   │   │   └── reportGeneration.js # 리포트 생성
│   │   ├── storage/
│   │   │   ├── storageFunctions.js # 저장소 관련 함수
│   │   │   ├── imageProcessing.js # 이미지 처리
│   │   │   └── ocrProcessing.js  # OCR 처리
│   │   ├── scheduled/
│   │   │   ├── scheduledTasks.js # 스케줄된 작업
│   │   │   ├── rankingUpdate.js  # 랭킹 업데이트
│   │   │   └── dataCleanup.js    # 데이터 정리
│   │   ├── firestore/
│   │   │   ├── triggers.js       # Firestore 트리거
│   │   │   ├── dataValidation.js # 데이터 검증
│   │   │   └── indexManagement.js # 인덱스 관리
│   │   ├── security/
│   │   │   ├── securityFunctions.js # 보안 관련 함수
│   │   │   ├── rateLimiting.js   # 속도 제한
│   │   │   └── fraudDetection.js # 부정행위 탐지
│   │   ├── legal/
│   │   │   ├── legalFunctions.js # 법적 관련 함수
│   │   │   ├── consentManagement.js # 동의 관리
│   │   │   └── dataRetention.js  # 데이터 보관
│   │   ├── monitoring/
│   │   │   ├── healthCheck.js    # 헬스 체크
│   │   │   ├── errorHandling.js  # 에러 처리
│   │   │   └── performanceMonitoring.js # 성능 모니터링
│   │   ├── utils/
│   │   │   ├── constants.js      # 상수
│   │   │   ├── helpers.js        # 헬퍼 함수
│   │   │   ├── validators.js     # 검증자
│   │   │   └── formatters.js     # 포맷터
│   │   └── config/
│   │       ├── firebase.js       # Firebase 설정
│   │       ├── database.js       # 데이터베이스 설정
│   │       ├── storage.js        # 저장소 설정
│   │       └── apis.js           # 외부 API 설정
│   ├── test/
│   │   ├── auth/
│   │   │   └── authFunctions.test.js # 인증 함수 테스트
│   │   ├── users/
│   │   │   └── userFunctions.test.js # 사용자 함수 테스트
│   │   └── utils/
│   │       └── testUtils.js      # 테스트 유틸리티
│   └── deployment/
│       ├── deploy.sh             # 배포 스크립트
│       ├── rollback.sh           # 롤백 스크립트
│       └── environment-setup.js  # 환경 설정
├── emulators/
│   ├── firestore/
│   │   ├── firestore.log
│   │   └── debug.log
│   ├── functions/
│   │   ├── functions.log
│   │   └── debug.log
│   └── ui/
│       ├── ui.log
│       └── debug.log
└── backups/
    ├── firestore/
    │   ├── 2024-01-01/
    │   └── 2024-01-02/
    ├── storage/
    │   ├── 2024-01-01/
    │   └── 2024-01-02/
    └── functions/
        ├── 2024-01-01/
        └── 2024-01-02/
```

## 4. 보안 관리가 필요한 파일들

### 4.1 환경 변수 파일들

#### .env.example (GIT 포함)
```bash
# Firebase 설정
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_DATABASE_URL=https://your-project-id-default-rtdb.firebaseio.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef123456

# Google Cloud 설정
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json

# 외부 API 키
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
NAVER_MAPS_API_KEY=your-naver-maps-api-key
KG_MOBILIANCE_API_KEY=your-kg-mobiliance-api-key
KG_MOBILIANCE_API_SECRET=your-kg-mobiliance-api-secret

# 알림 설정
FCM_SERVER_KEY=your-fcm-server-key
SLACK_WEBHOOK_URL=your-slack-webhook-url

# 보안 키
JWT_SECRET=your-jwt-secret
ENCRYPTION_KEY=your-encryption-key
API_SECRET_KEY=your-api-secret-key

# 데이터베이스 설정
BIGQUERY_DATASET=your-dataset
BIGQUERY_PROJECT=your-project-id

# 개발 설정
DEBUG_MODE=false
LOG_LEVEL=info
```

#### .env.development (GIT 제외)
```bash
# 개발 환경 설정
ENVIRONMENT=development
DEBUG_MODE=true
LOG_LEVEL=debug

# Firebase 개발 환경
FIREBASE_PROJECT_ID=noisebattle-dev
FIREBASE_API_KEY=actual-dev-api-key
FIREBASE_AUTH_DOMAIN=noisebattle-dev.firebaseapp.com

# 개발용 API 키
GOOGLE_MAPS_API_KEY=dev-google-maps-api-key
NAVER_MAPS_API_KEY=dev-naver-maps-api-key

# 개발용 보안 키
JWT_SECRET=dev-jwt-secret-key
ENCRYPTION_KEY=dev-encryption-key
```

#### .env.production (GIT 제외)
```bash
# 운영 환경 설정
ENVIRONMENT=production
DEBUG_MODE=false
LOG_LEVEL=error

# Firebase 운영 환경
FIREBASE_PROJECT_ID=noisebattle-prod
FIREBASE_API_KEY=actual-prod-api-key
FIREBASE_AUTH_DOMAIN=noisebattle-prod.firebaseapp.com

# 운영용 API 키
GOOGLE_MAPS_API_KEY=prod-google-maps-api-key
NAVER_MAPS_API_KEY=prod-naver-maps-api-key

# 운영용 보안 키
JWT_SECRET=prod-jwt-secret-key
ENCRYPTION_KEY=prod-encryption-key
```

### 4.2 보안 키 파일들 (모두 GIT 제외)

#### android/app/google-services.json
```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "noisebattle-app",
    "storage_bucket": "noisebattle-app.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef123456",
        "android_client_info": {
          "package_name": "com.noisebattle.app"
        }
      },
      "oauth_client": [
        {
          "client_id": "123456789-abcdef123456.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "actual-android-api-key"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "123456789-abcdef123456.apps.googleusercontent.com",
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

#### ios/Runner/GoogleService-Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>123456789-abcdef123456.apps.googleusercontent.com</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>com.googleusercontent.apps.123456789-abcdef123456</string>
    <key>API_KEY</key>
    <string>actual-ios-api-key</string>
    <key>GCM_SENDER_ID</key>
    <string>123456789</string>
    <key>PLIST_VERSION</key>
    <string>1</string>
    <key>BUNDLE_ID</key>
    <string>com.noisebattle.app</string>
    <key>PROJECT_ID</key>
    <string>noisebattle-app</string>
    <key>STORAGE_BUCKET</key>
    <string>noisebattle-app.appspot.com</string>
    <key>IS_ADS_ENABLED</key>
    <false/>
    <key>IS_ANALYTICS_ENABLED</key>
    <false/>
    <key>IS_APPINVITE_ENABLED</key>
    <true/>
    <key>IS_GCM_ENABLED</key>
    <true/>
    <key>IS_SIGNIN_ENABLED</key>
    <true/>
    <key>GOOGLE_APP_ID</key>
    <string>1:123456789:ios:abcdef123456</string>
</dict>
</plist>
```

#### firebase/functions/serviceAccountKey.json
```json
{
  "type": "service_account",
  "project_id": "noisebattle-app",
  "private_key_id": "abcdef123456",
  "private_key": "-----BEGIN PRIVATE KEY-----\nactual-private-key\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-abcde@noisebattle-app.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-abcde%40noisebattle-app.iam.gserviceaccount.com"
}
```

### 4.3 Android 보안 설정 파일들

#### android/app/key.properties (GIT 제외)
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=your-key-alias
storeFile=../keystore/upload-keystore.jks
```

#### android/keystore/upload-keystore.jks (GIT 제외)
- 바이너리 파일로 키스토어 정보 포함
- 절대 GIT에 커밋하지 않음
- 안전한 위치에 백업 보관

#### android/app/proguard-rules.pro (GIT 포함)
```pro
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# 앱 특정 클래스 유지
-keep class com.noisebattle.app.** { *; }

# 네트워크 관련
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }

# 모델 클래스 유지
-keep class * implements java.io.Serializable { *; }
-keep class * extends java.lang.Enum { *; }

# 디버그 정보 유지
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# 리플렉션 사용 클래스 유지
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
```

### 4.4 iOS 보안 설정 파일들

#### ios/Runner/Info.plist (일부 민감 정보)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>REVERSED_CLIENT_ID</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.123456789-abcdef123456</string>
            </array>
        </dict>
    </array>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>소음 측정 시 위치 정보를 수집합니다.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>소음 측정을 위해 마이크 권한이 필요합니다.</string>
    <key>NSCameraUsageDescription</key>
    <string>프로필 사진 및 게시글 이미지 업로드를 위해 카메라 권한이 필요합니다.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>프로필 사진 및 게시글 이미지 업로드를 위해 사진 라이브러리 권한이 필요합니다.</string>
</dict>
</plist>
```

## 5. .gitignore 설정

### 5.1 루트 .gitignore
```gitignore
# 환경 변수 파일들
.env
.env.local
.env.development
.env.production
.env.test

# Firebase 설정 파일들
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
firebase/functions/.env
firebase/functions/serviceAccountKey.json

# Android 보안 파일들
android/app/key.properties
android/keystore/
android/app/upload-keystore.jks
android/app/release-keystore.jks

# iOS 보안 파일들
ios/Runner/GoogleService-Info.plist
ios/Runner/Info.plist.bak
ios/firebase_app_id_file.json

# 빌드 파일들
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
pubspec.lock

# 로그 파일들
*.log
logs/
firebase/emulators/
firebase/functions/logs/

# 임시 파일들
*.tmp
*.temp
temp/
tmp/

# 백업 파일들
*.bak
*.backup
backups/

# IDE 설정 파일들
.vscode/
.idea/
*.swp
*.swo
*~

# OS 관련 파일들
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# 테스트 결과 파일들
coverage/
test_results/
integration_test/screenshots/

# 문서 임시 파일들
docs/build/
docs/site/

# 의존성 파일들
node_modules/
**/node_modules/
.npm
.yarn

# 캐시 파일들
.cache/
*.pid
*.seed
*.pid.lock

# 디버그 파일들
debug/
*.debug
*.map

# 런타임 파일들
.runtimeconfig.json
firebase-debug.log
firestore-debug.log
ui-debug.log

# 배포 아티팩트
deploy/
dist/
release/
```

### 5.2 Firebase Functions .gitignore
```gitignore
# Firebase Functions 환경 변수
.env
.env.local
.env.development
.env.production

# Node.js
node_modules/
npm-debug.log
yarn-error.log

# Firebase 설정 파일들
serviceAccountKey.json
firebase-adminsdk-*.json

# 런타임 파일들
.runtimeconfig.json
firebase-debug.log

# 빌드 파일들
lib/
dist/
build/

# 테스트 파일들
coverage/
nyc_output/
test-results/

# 임시 파일들
*.tmp
*.temp
temp/

# 로그 파일들
*.log
logs/

# 캐시 파일들
.cache/
.nyc_output/

# IDE 파일들
.vscode/
.idea/
```

## 6. 스크립트 및 자동화

### 6.1 빌드 스크립트 (scripts/build.sh)
```bash
#!/bin/bash

# 소음과 전쟁 앱 빌드 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 환경 변수 확인
check_env() {
    if [ -z "$ENVIRONMENT" ]; then
        log_error "ENVIRONMENT 환경 변수가 설정되지 않았습니다."
        exit 1
    fi
    
    if [ "$ENVIRONMENT" != "development" ] && [ "$ENVIRONMENT" != "production" ]; then
        log_error "ENVIRONMENT는 'development' 또는 'production'이어야 합니다."
        exit 1
    fi
}

# 환경 파일 설정
setup_environment() {
    log_info "환경 설정 중: $ENVIRONMENT"
    
    # 환경별 설정 파일 복사
    if [ "$ENVIRONMENT" == "development" ]; then
        cp .env.development .env
        cp android/app/google-services-dev.json android/app/google-services.json
        cp ios/Runner/GoogleService-Info-dev.plist ios/Runner/GoogleService-Info.plist
    elif [ "$ENVIRONMENT" == "production" ]; then
        cp .env.production .env
        cp android/app/google-services-prod.json android/app/google-services.json
        cp ios/Runner/GoogleService-Info-prod.plist ios/Runner/GoogleService-Info.plist
    fi
}

# 종속성 설치
install_dependencies() {
    log_info "Flutter 종속성 설치 중..."
    flutter pub get
    
    log_info "네이티브 종속성 업데이트 중..."
    cd ios && pod install && cd ..
}

# 코드 생성
generate_code() {
    log_info "코드 생성 중..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
}

# 빌드 실행
build_app() {
    PLATFORM=$1
    
    if [ "$PLATFORM" == "android" ]; then
        log_info "Android 앱 빌드 중..."
        if [ "$ENVIRONMENT" == "development" ]; then
            flutter build apk --debug
        else
            flutter build apk --release
        fi
    elif [ "$PLATFORM" == "ios" ]; then
        log_info "iOS 앱 빌드 중..."
        if [ "$ENVIRONMENT" == "development" ]; then
            flutter build ios --debug
        else
            flutter build ios --release
        fi
    elif [ "$PLATFORM" == "all" ]; then
        build_app android
        build_app ios
    else
        log_error "지원하지 않는 플랫폼: $PLATFORM"
        exit 1
    fi
}

# 테스트 실행
run_tests() {
    log_info "테스트 실행 중..."
    flutter test --coverage
    
    log_info "통합 테스트 실행 중..."
    flutter test integration_test/
}

# 정리
cleanup() {
    log_info "정리 중..."
    rm -f .env
    rm -f android/app/google-services.json
    rm -f ios/Runner/GoogleService-Info.plist
}

# 메인 실행
main() {
    log_info "소음과 전쟁 앱 빌드 시작"
    
    check_env
    setup_environment
    install_dependencies
    generate_code
    
    if [ "$1" == "test" ]; then
        run_tests
    else
        build_app ${1:-all}
    fi
    
    cleanup
    log_info "빌드 완료"
}

# 스크립트 실행
main "$@"
```

### 6.2 배포 스크립트 (scripts/deploy.sh)
```bash
#!/bin/bash

# 소음과 전쟁 앱 배포 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 환경 확인
check_environment() {
    if [ "$1" != "development" ] && [ "$1" != "production" ]; then
        log_error "사용법: $0 [development|production]"
        exit 1
    fi
}

# Git 상태 확인
check_git_status() {
    if [ -n "$(git status --porcelain)" ]; then
        log_error "Git 워킹 디렉토리가 깨끗하지 않습니다. 커밋 후 배포하세요."
        exit 1
    fi
}

# 버전 확인
check_version() {
    local pubspec_version=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)
    log_info "현재 버전: $pubspec_version"
    
    read -p "배포하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "배포가 취소되었습니다."
        exit 0
    fi
}

# Firebase 배포
deploy_firebase() {
    local environment=$1
    
    log_info "Firebase 배포 중: $environment"
    
    # Firebase 프로젝트 선택
    if [ "$environment" == "development" ]; then
        firebase use noisebattle-dev
    else
        firebase use noisebattle-prod
    fi
    
    # Firebase Functions 배포
    cd firebase/functions
    npm install
    npm run build
    cd ../..
    
    # Firebase 서비스 배포
    firebase deploy --only functions,firestore,storage
}

# 앱 배포
deploy_app() {
    local environment=$1
    local platform=$2
    
    export ENVIRONMENT=$environment
    
    # 앱 빌드
    ./scripts/build.sh $platform
    
    if [ "$platform" == "android" ] || [ "$platform" == "all" ]; then
        deploy_android $environment
    fi
    
    if [ "$platform" == "ios" ] || [ "$platform" == "all" ]; then
        deploy_ios $environment
    fi
}

# Android 배포
deploy_android() {
    local environment=$1
    
    log_info "Android 앱 배포 중: $environment"
    
    if [ "$environment" == "development" ]; then
        # 개발 환경: Firebase App Distribution
        firebase appdistribution:distribute \
            build/app/outputs/flutter-apk/app-debug.apk \
            --app "android-app-id" \
            --groups "developers" \
            --release-notes "개발 빌드"
    else
        # 운영 환경: Google Play Store
        fastlane android deploy
    fi
}

# iOS 배포
deploy_ios() {
    local environment=$1
    
    log_info "iOS 앱 배포 중: $environment"
    
    if [ "$environment" == "development" ]; then
        # 개발 환경: Firebase App Distribution
        firebase appdistribution:distribute \
            build/ios/iphoneos/Runner.app \
            --app "ios-app-id" \
            --groups "developers" \
            --release-notes "개발 빌드"
    else
        # 운영 환경: App Store
        fastlane ios deploy
    fi
}

# Slack 알림
send_slack_notification() {
    local environment=$1
    local status=$2
    
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"소음과 전쟁 앱 배포 $status: $environment\"}" \
            $SLACK_WEBHOOK_URL
    fi
}

# 메인 실행
main() {
    local environment=$1
    local platform=${2:-all}
    
    log_info "소음과 전쟁 앱 배포 시작: $environment"
    
    check_environment $environment
    check_git_status
    check_version
    
    # Firebase 배포
    deploy_firebase $environment
    
    # 앱 배포
    deploy_app $environment $platform
    
    # 알림 전송
    send_slack_notification $environment "완료"
    
    log_info "배포 완료: $environment"
}

# 스크립트 실행
main "$@"
```

### 6.3 보안 검사 스크립트 (scripts/security-check.sh)
```bash
#!/bin/bash

# 보안 검사 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 민감 파일 검사
check_sensitive_files() {
    log_info "민감 파일 검사 중..."
    
    local sensitive_files=(
        ".env"
        ".env.local"
        ".env.development"
        ".env.production"
        "android/app/google-services.json"
        "ios/Runner/GoogleService-Info.plist"
        "firebase/functions/serviceAccountKey.json"
        "android/app/key.properties"
        "android/keystore/*.jks"
    )
    
    for file in "${sensitive_files[@]}"; do
        if [ -f "$file" ]; then
            log_error "민감 파일이 존재합니다: $file"
            echo "이 파일은 .gitignore에 포함되어야 합니다."
        fi
    done
}

# Git 히스토리 검사
check_git_history() {
    log_info "Git 히스토리에서 민감 정보 검사 중..."
    
    local sensitive_patterns=(
        "password"
        "secret"
        "private_key"
        "api_key"
        "token"
        "credential"
    )
    
    for pattern in "${sensitive_patterns[@]}"; do
        if git log --all --grep="$pattern" --oneline | head -1 | grep -q .; then
            log_warn "Git 히스토리에 '$pattern' 패턴이 발견되었습니다."
        fi
    done
}

# 하드코딩된 민감 정보 검사
check_hardcoded_secrets() {
    log_info "하드코딩된 민감 정보 검사 중..."
    
    # API 키 패턴
    if grep -r "AIza[0-9A-Za-z\\-_]{35}" lib/ --include="*.dart" 2>/dev/null; then
        log_error "Google API 키가 하드코딩되어 있습니다."
    fi
    
    # Firebase 설정 패턴
    if grep -r "firebase.*api.*key" lib/ --include="*.dart" 2>/dev/null; then
        log_error "Firebase API 키가 하드코딩되어 있습니다."
    fi
    
    # 일반적인 비밀번호 패턴
    if grep -r "password.*=" lib/ --include="*.dart" 2>/dev/null; then
        log_warn "하드코딩된 비밀번호 패턴이 발견되었습니다."
    fi
}

# 종속성 취약점 검사
check_dependencies() {
    log_info "종속성 취약점 검사 중..."
    
    # Flutter 종속성 감사
    if command -v flutter &> /dev/null; then
        flutter pub deps --style=compact | grep -E "(VULNERABILITY|WARNING|ERROR)" || true
    fi
    
    # Node.js 종속성 감사 (Firebase Functions)
    if [ -f "firebase/functions/package.json" ]; then
        cd firebase/functions
        if command -v npm &> /dev/null; then
            npm audit --audit-level=moderate || true
        fi
        cd ../..
    fi
}

# 권한 검사
check_permissions() {
    log_info "파일 권한 검사 중..."
    
    # 스크립트 파일 실행 권한 확인
    find scripts/ -name "*.sh" -not -perm 755 -exec chmod 755 {} \;
    
    # 민감 파일 권한 확인
    find . -name "*.key" -o -name "*.pem" -o -name "*.p12" | while read file; do
        if [ -f "$file" ]; then
            chmod 600 "$file"
            log_info "권한 수정: $file"
        fi
    done
}

# Firebase 보안 규칙 검사
check_firebase_rules() {
    log_info "Firebase 보안 규칙 검사 중..."
    
    if [ -f "firebase/firestore.rules" ]; then
        # 기본 규칙 확인
        if grep -q "allow read, write: if false" firebase/firestore.rules; then
            log_error "Firestore 규칙이 모든 액세스를 차단합니다."
        fi
        
        if grep -q "allow read, write: if true" firebase/firestore.rules; then
            log_error "Firestore 규칙이 모든 액세스를 허용합니다."
        fi
    fi
    
    if [ -f "firebase/storage.rules" ]; then
        # 스토리지 규칙 확인
        if grep -q "allow read, write: if true" firebase/storage.rules; then
            log_error "Storage 규칙이 모든 액세스를 허용합니다."
        fi
    fi
}

# SSL/TLS 설정 검사
check_ssl_config() {
    log_info "SSL/TLS 설정 검사 중..."
    
    # Android 네트워크 보안 설정 확인
    if [ -f "android/app/src/main/res/xml/network_security_config.xml" ]; then
        if grep -q "cleartextTrafficPermitted.*true" android/app/src/main/res/xml/network_security_config.xml; then
            log_warn "Android에서 cleartext 트래픽이 허용되어 있습니다."
        fi
    fi
    
    # iOS App Transport Security 확인
    if [ -f "ios/Runner/Info.plist" ]; then
        if grep -q "NSAllowsArbitraryLoads" ios/Runner/Info.plist; then
            log_warn "iOS에서 임의 로드가 허용되어 있습니다."
        fi
    fi
}

# 보안 검사 실행
main() {
    log_info "보안 검사 시작"
    
    check_sensitive_files
    check_git_history
    check_hardcoded_secrets
    check_dependencies
    check_permissions
    check_firebase_rules
    check_ssl_config
    
    log_info "보안 검사 완료"
}

# 스크립트 실행
main "$@"
```

## 7. 문서화 구조

### 7.1 docs/ 디렉토리 구조
```
docs/
├── README.md
├── api/
│   ├── firebase-functions.md
│   ├── rest-api.md
│   └── websocket-api.md
├── architecture/
│   ├── system-architecture.md
│   ├── mvvm-pattern.md
│   └── database-design.md
├── security/
│   ├── security-overview.md
│   ├── authentication.md
│   └── data-protection.md
├── development/
│   ├── getting-started.md
│   ├── coding-standards.md
│   ├── testing-guide.md
│   └── deployment-guide.md
├── legal/
│   ├── privacy-policy.md
│   ├── terms-of-service.md
│   └── compliance.md
└── troubleshooting/
    ├── common-issues.md
    ├── debugging.md
    └── performance.md
```

### 7.2 개발자 가이드 템플릿
```markdown
# 소음과 전쟁 개발자 가이드

## 개발 환경 설정

### 1. 필수 도구 설치
- Flutter SDK (3.16.0 이상)
- Android Studio
- Xcode (macOS만)
- Firebase CLI
- Git

### 2. 프로젝트 설정
```bash
# 저장소 클론
git clone https://github.com/your-org/noisebattle.git
cd noisebattle

# 환경 변수 설정
cp .env.example .env.development

# 종속성 설치
flutter pub get
cd firebase/functions && npm install
```

### 3. 보안 설정
- 모든 민감 파일이 .gitignore에 포함되어 있는지 확인
- API 키는 환경 변수로 관리
- Firebase 설정 파일은 별도 관리

### 4. 빌드 및 실행
```bash
# 개발 환경 빌드
ENVIRONMENT=development ./scripts/build.sh

# 앱 실행
flutter run
```

## 코딩 표준

### 1. Dart 코딩 스타일
- [Effective Dart](https://dart.dev/guides/language/effective-dart) 준수
- `dart format` 사용
- `dart analyze` 통과

### 2. 파일 구조
- MVVM 패턴 준수
- 기능별 폴더 구조
- 명확한 네이밍 규칙

### 3. 주석 및 문서화
- 공개 API에 대한 문서 주석
- 복잡한 로직에 대한 설명
- TODO 주석 최소화

## 보안 가이드

### 1. 민감 정보 관리
- 환경 변수 사용
- 하드코딩 금지
- 정기적인 보안 검사

### 2. 인증 및 권한
- Firebase Auth 사용
- 역할 기반 권한 관리
- 세션 관리

### 3. 데이터 보호
- 개인정보 암호화
- 안전한 전송
- 적절한 보관 기간

## 배포 가이드

### 1. 배포 전 체크리스트
- [ ] 모든 테스트 통과
- [ ] 보안 검사 완료
- [ ] 코드 리뷰 완료
- [ ] 문서 업데이트

### 2. 배포 절차
```bash
# 개발 환경 배포
./scripts/deploy.sh development

# 운영 환경 배포
./scripts/deploy.sh production
```

### 3. 배포 후 확인
- 앱 정상 동작 확인
- 모니터링 대시보드 확인
- 사용자 피드백 모니터링
```

이 파일 구조 개발 계획서는 전체 프로젝트의 구조를 체계적으로 정리하고, 보안 관리가 필요한 파일들을 명확히 구분하여 개발자들이 안전하게 프로젝트를 관리할 수 있도록 돕습니다. 