# Law 개발 계획서

> **Project:** 소음과 전쟁 - 법적 자문 및 컴플라이언스 가이드

## 1. 법적 자문 개요

### 1.1 주요 법률 영역
- **개인정보보호법**: 사용자 개인정보 수집 및 처리
- **정보통신망법**: 온라인 서비스 운영 관련 규정
- **주택법**: 공동주택 관련 규정
- **소음·진동관리법**: 소음 측정 및 관리 관련
- **민법**: 층간소음으로 인한 손해배상
- **형법**: 명예훼손, 모욕, 사이버 범죄
- **소비자보호법**: 앱 사용자 보호
- **전자상거래법**: 온라인 거래 관련 (향후 확장 시)

### 1.2 법적 위험 분석
```
┌─────────────────────────────────────────┐
│              법적 위험 매트릭스            │
├─────────────────────────────────────────┤
│ 높은 위험                                │
│ - 개인정보 침해 및 유출                   │
│ - 명예훼손 및 허위정보 유포               │
│ - 위치정보 오남용                        │
├─────────────────────────────────────────┤
│ 중간 위험                                │
│ - 사용자 간 분쟁 중재                    │
│ - 부정확한 소음 측정 데이터               │
│ - 아파트 정보 오인증                     │
├─────────────────────────────────────────┤
│ 낮은 위험                                │
│ - 일반적인 서비스 이용 약관               │
│ - 사용자 문의 및 고객 서비스              │
└─────────────────────────────────────────┘
```

## 2. 개인정보보호법 관련 사항

### 2.1 개인정보 수집 및 이용
```markdown
# 개인정보 처리방침 (필수 사항)

## 수집하는 개인정보 항목
### 필수 정보
- 이메일 주소 (회원가입, 로그인)
- 휴대폰 번호 (본인인증)
- 닉네임 (서비스 이용)

### 선택 정보
- 프로필 사진
- 거주지 주소 (아파트 인증 시)
- 위치 정보 (소음 측정 시)

## 개인정보 처리 목적
- 회원 가입 및 관리
- 본인 인증 및 부정 이용 방지
- 서비스 제공 및 개선
- 고객 상담 및 불만 처리
- 법령상 의무 이행

## 보유 및 이용 기간
- 회원 탈퇴 시 즉시 삭제
- 법령에 의한 보관 의무 기간 준수
- 부정 이용 방지를 위한 최소 기간 보관
```

### 2.2 법적 근거 및 동의
```dart
// lib/core/legal/consent_types.dart
enum ConsentType {
  essential('필수'),     // 서비스 이용에 필수
  optional('선택'),      // 부가 서비스 이용
  marketing('마케팅'),   // 마케팅 정보 수신
  location('위치'),      // 위치 정보 수집
  analytics('분석');     // 서비스 분석

  const ConsentType(this.displayName);
  final String displayName;
}

class ConsentManager {
  static final Map<ConsentType, ConsentInfo> _consentRequirements = {
    ConsentType.essential: ConsentInfo(
      required: true,
      legalBasis: '정보통신망법 제22조',
      purpose: '서비스 이용을 위한 회원 관리',
      retentionPeriod: '회원 탈퇴 시 즉시 삭제',
    ),
    ConsentType.location: ConsentInfo(
      required: false,
      legalBasis: '위치정보법 제15조',
      purpose: '소음 측정 및 지역별 통계 제공',
      retentionPeriod: '동의 철회 시 즉시 삭제',
    ),
    ConsentType.marketing: ConsentInfo(
      required: false,
      legalBasis: '정보통신망법 제50조',
      purpose: '이벤트 및 마케팅 정보 제공',
      retentionPeriod: '동의 철회 시 즉시 삭제',
    ),
  };
}

class ConsentInfo {
  final bool required;
  final String legalBasis;
  final String purpose;
  final String retentionPeriod;
  
  ConsentInfo({
    required this.required,
    required this.legalBasis,
    required this.purpose,
    required this.retentionPeriod,
  });
}
```

### 2.3 개인정보 처리 위탁
```markdown
# 개인정보 처리 위탁 현황

## 위탁업체별 처리 업무
| 업체명 | 위탁업무 | 개인정보 항목 | 보유기간 |
|--------|----------|---------------|----------|
| Google Firebase | 데이터베이스 관리 | 전체 개인정보 | 서비스 이용 기간 |
| Google Cloud | 클라우드 서비스 | 전체 개인정보 | 서비스 이용 기간 |
| KG모빌리언스 | 본인인증 | 이름, 휴대폰번호 | 인증 완료 후 즉시 삭제 |
| 푸시 서비스 | 알림 발송 | 기기 토큰 | 알림 발송 후 즉시 삭제 |

## 위탁 계약 필수 사항
- 개인정보 보호 관련 법령 준수
- 목적 외 이용 및 제3자 제공 금지
- 재위탁 시 사전 동의
- 수탁업체 관리 감독
- 계약 종료 시 개인정보 반환/삭제
```

## 3. 명예훼손 및 표현의 자유

### 3.1 명예훼손 관련 리스크
```markdown
# 명예훼손 관련 주요 쟁점

## 형법상 명예훼손 (제307조)
- 공연히 사실을 적시하여 타인의 명예를 훼손
- 아파트명, 호수 등을 명시한 비판 게시물
- 특정 주민에 대한 비방성 글

## 모욕죄 (제311조)
- 공연히 사람을 모욕하는 경우
- 욕설, 비하 표현이 포함된 댓글

## 허위사실유포 (제307조 제2항)
- 거짓 정보를 유포하여 명예훼손
- 허위 소음 신고, 조작된 측정값

## 모니터링 및 대응 방안
1. 사전 예방
   - 게시판 이용수칙 명시
   - 금지 키워드 자동 필터링
   - 사용자 신고 기능

2. 사후 대응
   - 신고 접수 시 즉시 검토
   - 법적 검토 후 게시물 삭제
   - 반복 위반 시 계정 제재
```

### 3.2 게시물 모니터링 시스템
```dart
// lib/core/legal/content_moderation.dart
class ContentModerationService {
  static final List<String> _prohibitedKeywords = [
    '바퀴벌레', '중국인', '외국인', '미친', '정신병',
    // 차별 표현, 욕설, 비하 표현 등
  ];
  
  static final List<String> _sensitiveKeywords = [
    '호수', '동', '층', '101호', '102호',
    // 특정 주민 식별 가능한 표현
  ];
  
  static ModerationResult moderateContent(String content) {
    // 1. 금지 키워드 검사
    for (final keyword in _prohibitedKeywords) {
      if (content.contains(keyword)) {
        return ModerationResult(
          action: ModerationAction.block,
          reason: '부적절한 표현이 포함되어 있습니다.',
        );
      }
    }
    
    // 2. 민감 키워드 검사
    for (final keyword in _sensitiveKeywords) {
      if (content.contains(keyword)) {
        return ModerationResult(
          action: ModerationAction.review,
          reason: '관리자 검토가 필요한 내용입니다.',
        );
      }
    }
    
    // 3. AI 기반 감정 분석
    final sentimentScore = _analyzeSentiment(content);
    if (sentimentScore < -0.8) {
      return ModerationResult(
        action: ModerationAction.review,
        reason: '부정적 감정이 감지되었습니다.',
      );
    }
    
    return ModerationResult(
      action: ModerationAction.approve,
      reason: '정상적인 내용입니다.',
    );
  }
  
  static double _analyzeSentiment(String content) {
    // 감정 분석 API 호출 (Google Cloud Natural Language API 등)
    // 임시로 간단한 키워드 기반 분석
    final negativeWords = ['짜증', '화남', '죽이고싶다', '미치겠다'];
    final positiveWords = ['좋다', '감사', '이해', '해결'];
    
    int negativeCount = 0;
    int positiveCount = 0;
    
    for (final word in negativeWords) {
      if (content.contains(word)) negativeCount++;
    }
    
    for (final word in positiveWords) {
      if (content.contains(word)) positiveCount++;
    }
    
    if (negativeCount + positiveCount == 0) return 0;
    
    return (positiveCount - negativeCount) / (positiveCount + negativeCount);
  }
}

enum ModerationAction {
  approve,  // 승인
  review,   // 검토 대기
  block,    // 차단
}

class ModerationResult {
  final ModerationAction action;
  final String reason;
  
  ModerationResult({required this.action, required this.reason});
}
```

### 3.3 법적 대응 절차
```markdown
# 명예훼손 신고 대응 절차

## 1. 신고 접수
- 신고 대상: 게시물 ID, 댓글 ID
- 신고 사유: 명예훼손, 모욕, 허위사실유포
- 신고자 정보: 실명, 연락처, 피해 내용

## 2. 1차 검토 (24시간 내)
- 내용 확인 및 사실 관계 조사
- 법적 판단 요소 검토
- 임시 조치 (게시물 숨김 등)

## 3. 법적 검토 (3일 내)
- 외부 법무법인 자문 의뢰
- 명예훼손 성립 여부 판단
- 처리 방안 결정

## 4. 최종 처리
- 삭제 또는 복구 결정
- 당사자 통지
- 재발 방지 조치

## 5. 분쟁 해결
- 당사자 간 조정 중재
- 필요시 법적 절차 안내
- 증거 자료 보존
```

## 4. 위치정보 및 소음 측정 관련

### 4.1 위치정보보호법 준수
```markdown
# 위치정보 수집 및 이용 동의서

## 수집 목적
- 지역별 소음 현황 파악
- 아파트별 소음 통계 제공
- 소음지도 서비스 제공

## 수집 방법
- GPS 기반 위치 정보
- 사용자 직접 입력 (주소)
- 네트워크 기반 위치 정보

## 이용 및 제공
- 개인 식별이 불가능한 형태로 가공
- 통계 자료 생성 목적으로만 이용
- 제3자 제공 금지

## 위치정보 관리
- 암호화 저장
- 접근 권한 제한
- 주기적 삭제 (6개월)
```

### 4.2 소음 측정의 법적 한계
```dart
// lib/core/legal/noise_measurement_disclaimer.dart
class NoiseMeasurementDisclaimer {
  static const String legalNotice = '''
소음 측정값 관련 법적 고지사항

1. 측정값의 한계
- 본 앱의 소음 측정값은 스마트폰 내장 마이크를 이용한 참고용 데이터입니다.
- 소음·진동관리법에 따른 공식 측정기기가 아닙니다.
- 법적 효력이 없으며 공식 소음 측정을 대체할 수 없습니다.

2. 측정 환경의 영향
- 스마트폰 기종, 마이크 성능에 따라 측정값이 달라질 수 있습니다.
- 주변 환경, 측정 위치에 따라 오차가 발생할 수 있습니다.
- 실제 소음 수준과 차이가 있을 수 있습니다.

3. 법적 대응 시 주의사항
- 공식 소음 측정은 전문 기관에 의뢰하시기 바랍니다.
- 층간소음 분쟁 시 법적 증거로 사용할 수 없습니다.
- 정확한 측정이 필요한 경우 공인 측정기관을 이용하시기 바랍니다.
''';
  
  static void showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('소음 측정 관련 안내'),
        content: SingleChildScrollView(
          child: Text(legalNotice),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
```

## 5. 층간소음 관련 민사 책임

### 5.1 민법상 손해배상 책임
```markdown
# 층간소음 관련 민사 분쟁 대응 가이드

## 손해배상 성립 요건
1. 가해 행위: 층간소음 발생
2. 손해 발생: 정신적 피해, 재산상 손해
3. 인과관계: 소음과 피해 간 관련성
4. 고의 또는 과실: 고의적 소음 발생

## 플랫폼 책임 제한
- 정보통신망법 제44조의2 (온라인서비스제공자의 책임 제한)
- 사용자가 게시한 정보에 대한 책임 면제
- 명백한 권리 침해 시 삭제 의무

## 면책 조항
서비스 이용약관에 포함할 면책 사항:
- 사용자 간 분쟁에 대한 책임 제한
- 소음 측정값의 정확성에 대한 책임 제한
- 부정확한 정보로 인한 피해 책임 제한
```

### 5.2 분쟁 조정 및 해결
```dart
// lib/core/legal/dispute_resolution.dart
class DisputeResolutionService {
  static Future<void> reportDispute({
    required String reporterId,
    required String targetUserId,
    required String postId,
    required String reason,
    required String description,
  }) async {
    // 1. 분쟁 신고 접수
    await FirebaseFirestore.instance.collection('disputes').add({
      'reporterId': reporterId,
      'targetUserId': targetUserId,
      'postId': postId,
      'reason': reason,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // 2. 자동 중재 시도
    final autoResolution = await _attemptAutoResolution(reason);
    if (autoResolution != null) {
      await _applyAutoResolution(autoResolution);
      return;
    }
    
    // 3. 관리자 검토 대기열에 추가
    await _addToModerationQueue(reporterId, targetUserId, postId);
  }
  
  static Future<AutoResolution?> _attemptAutoResolution(String reason) async {
    // 자동 해결 가능한 경우
    switch (reason) {
      case 'spam':
        return AutoResolution(
          action: 'hide_post',
          duration: Duration(hours: 24),
        );
      case 'inappropriate_language':
        return AutoResolution(
          action: 'filter_content',
          duration: Duration(hours: 1),
        );
      default:
        return null;
    }
  }
  
  static Future<void> _applyAutoResolution(AutoResolution resolution) async {
    // 자동 해결 조치 적용
    switch (resolution.action) {
      case 'hide_post':
        // 게시물 임시 숨김
        break;
      case 'filter_content':
        // 내용 필터링
        break;
    }
  }
  
  static Future<void> _addToModerationQueue(
    String reporterId,
    String targetUserId,
    String postId,
  ) async {
    await FirebaseFirestore.instance.collection('moderation_queue').add({
      'reporterId': reporterId,
      'targetUserId': targetUserId,
      'postId': postId,
      'priority': _calculatePriority(reporterId, targetUserId),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  static int _calculatePriority(String reporterId, String targetUserId) {
    // 우선순위 계산 로직
    // 반복 신고, 사용자 등급 등 고려
    return 1;
  }
}

class AutoResolution {
  final String action;
  final Duration duration;
  
  AutoResolution({required this.action, required this.duration});
}
```

## 6. 아파트 인증 관련 법적 이슈

### 6.1 거주 증명 서류 처리
```markdown
# 아파트 인증 관련 법적 검토 사항

## 서류 인증 과정의 법적 근거
1. 개인정보보호법 제15조 (개인정보 수집·이용)
   - 서비스 제공을 위한 최소 필요 정보 수집
   - 사용자 동의 하에 거주 증명 서류 처리

2. 정보통신망법 제23조 (동의를 받는 방법)
   - 서류 처리 목적 명시
   - 처리 기간 및 방법 고지

## 서류 보관 및 삭제
- 인증 완료 후 즉시 삭제 원칙
- 부정 이용 방지를 위한 최소 기간 보관
- 암호화 저장 및 접근 권한 제한

## 오인증 방지 조치
- OCR 기술의 정확도 한계 고지
- 관리자 수동 검토 시스템 병행
- 허위 인증 시 계정 제재 정책
```

### 6.2 부동산 정보 활용 제한
```dart
// lib/core/legal/property_info_compliance.dart
class PropertyInfoCompliance {
  static const List<String> _sensitivePropertyInfo = [
    '시세', '매매가', '전세가', '월세',
    '평수', '층수', '방향', '조건',
  ];
  
  static bool isPropertyDiscussionAllowed(String content) {
    // 부동산 거래 관련 정보 포함 여부 확인
    for (final info in _sensitivePropertyInfo) {
      if (content.contains(info)) {
        return false;
      }
    }
    return true;
  }
  
  static String getPropertyInfoGuideline() {
    return '''
부동산 정보 게시 가이드라인

1. 금지 사항
- 아파트 매매/전세 가격 정보
- 개별 호실의 거래 정보
- 부동산 중개 및 광고성 내용

2. 허용 사항
- 소음 관련 경험담
- 아파트 시설 관련 정보
- 주민 간 소통 내용

3. 주의 사항
- 특정 호실 식별 가능한 정보 제한
- 개인 사생활 침해 금지
- 허위 정보 유포 금지
''';
  }
}
```

## 7. 서비스 이용약관 및 개인정보 처리방침

### 7.1 서비스 이용약관 (주요 조항)
```markdown
# 서비스 이용약관

## 제1조 (목적)
이 약관은 소음과 전쟁 서비스 이용에 관한 회사와 회원 간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.

## 제2조 (정의)
1. "서비스"란 회사가 제공하는 층간소음 관련 커뮤니티 및 측정 서비스를 의미합니다.
2. "회원"이란 본 약관에 동의하고 서비스를 이용하는 자를 의미합니다.

## 제3조 (서비스 이용 및 제한)
1. 회원은 본 약관 및 관련 법령을 준수하여야 합니다.
2. 회원은 다음 행위를 하여서는 안 됩니다:
   - 타인의 개인정보 무단 수집·이용
   - 허위 정보 유포
   - 명예훼손 및 모욕적 내용 게시
   - 부동산 거래 관련 정보 게시

## 제4조 (소음 측정 서비스)
1. 소음 측정값은 참고용이며 법적 효력이 없습니다.
2. 측정값의 정확성에 대해 회사는 책임을 지지 않습니다.
3. 공식 소음 측정이 필요한 경우 전문 기관을 이용하시기 바랍니다.

## 제5조 (면책 조항)
1. 회사는 천재지변, 불가항력으로 인한 서비스 장애에 대해 책임을 지지 않습니다.
2. 회원이 게시한 정보의 신뢰성, 정확성에 대해 책임을 지지 않습니다.
3. 회원 간 분쟁에 대해 회사는 조정 역할만 수행합니다.

## 제6조 (분쟁 해결)
1. 서비스 이용과 관련한 분쟁은 대한민국 법령에 따라 해결합니다.
2. 관할 법원은 서울중앙지방법원으로 합니다.
```

### 7.2 개인정보 처리방침 템플릿
```dart
// lib/core/legal/privacy_policy_template.dart
class PrivacyPolicyTemplate {
  static String generatePrivacyPolicy() {
    return '''
개인정보 처리방침

소음과 전쟁('회사')는 개인정보보호법, 정보통신망법 등 관련 법령에 따라 
이용자의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 
하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.

## 1. 개인정보 수집 항목 및 목적
### 필수 정보
- 이메일 주소: 회원 가입, 로그인, 고객 상담
- 휴대폰 번호: 본인 인증, 중요 알림 발송
- 닉네임: 서비스 이용, 게시물 작성

### 선택 정보
- 프로필 사진: 프로필 표시
- 주소 정보: 아파트 인증, 지역별 서비스 제공
- 위치 정보: 소음 측정, 지역 통계 생성

## 2. 개인정보 처리 위탁
${_generateProcessingDelegationInfo()}

## 3. 개인정보 보유 및 이용 기간
- 회원 탈퇴 시 즉시 삭제
- 법령에 의한 보관 의무가 있는 경우 해당 기간 동안 보관
- 부정 이용 방지: 1년간 보관

## 4. 개인정보 처리 거부권
이용자는 개인정보 수집·이용에 대한 동의를 거부할 권리가 있으며, 
동의 거부 시 서비스 이용이 제한될 수 있습니다.

## 5. 개인정보보호 책임자
- 성명: 개인정보보호 담당자
- 연락처: privacy@noisebattle.com
- 전화번호: 02-1234-5678

## 시행일자
이 개인정보 처리방침은 2024년 1월 1일부터 시행됩니다.
''';
  }
  
  static String _generateProcessingDelegationInfo() {
    return '''
| 수탁업체 | 위탁업무 | 개인정보 항목 | 보유기간 |
|----------|----------|---------------|----------|
| Google LLC | 데이터베이스 관리 | 전체 개인정보 | 서비스 이용 기간 |
| Firebase | 클라우드 서비스 | 전체 개인정보 | 서비스 이용 기간 |
| KG모빌리언스 | 본인 인증 | 이름, 휴대폰 번호 | 인증 완료 후 즉시 삭제 |
''';
  }
}
```

## 8. 법적 대응 프로세스

### 8.1 법적 분쟁 대응 체계
```dart
// lib/core/legal/legal_response_system.dart
class LegalResponseSystem {
  static Future<void> handleLegalNotice({
    required String noticeType,
    required String content,
    required String contactInfo,
  }) async {
    // 1. 법적 고지 접수
    await _recordLegalNotice(noticeType, content, contactInfo);
    
    // 2. 긴급도 분류
    final urgency = _classifyUrgency(noticeType);
    
    // 3. 법무팀 알림
    await _notifyLegalTeam(urgency, content);
    
    // 4. 임시 조치
    if (urgency == UrgencyLevel.high) {
      await _applyEmergencyMeasures(content);
    }
  }
  
  static Future<void> _recordLegalNotice(
    String noticeType,
    String content,
    String contactInfo,
  ) async {
    await FirebaseFirestore.instance.collection('legal_notices').add({
      'type': noticeType,
      'content': content,
      'contactInfo': contactInfo,
      'status': 'received',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  static UrgencyLevel _classifyUrgency(String noticeType) {
    switch (noticeType) {
      case 'court_order':
      case 'police_investigation':
        return UrgencyLevel.high;
      case 'privacy_complaint':
      case 'defamation_claim':
        return UrgencyLevel.medium;
      case 'general_inquiry':
        return UrgencyLevel.low;
      default:
        return UrgencyLevel.medium;
    }
  }
  
  static Future<void> _notifyLegalTeam(UrgencyLevel urgency, String content) async {
    final notification = {
      'type': 'legal_notice',
      'urgency': urgency.name,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // 법무팀 알림 시스템 (이메일, SMS 등)
    await _sendUrgentNotification(notification);
  }
  
  static Future<void> _applyEmergencyMeasures(String content) async {
    // 긴급 조치 (게시물 임시 삭제, 서비스 일시 중단 등)
    if (content.contains('개인정보 유출')) {
      await _suspendDataProcessing();
    }
    
    if (content.contains('명예훼손')) {
      await _temporarilyHideContent();
    }
  }
  
  static Future<void> _suspendDataProcessing() async {
    // 개인정보 처리 일시 중단
    await FirebaseFirestore.instance
        .collection('system_settings')
        .doc('data_processing')
        .update({'suspended': true});
  }
  
  static Future<void> _temporarilyHideContent() async {
    // 관련 게시물 임시 숨김
    // 구체적인 구현 필요
  }
  
  static Future<void> _sendUrgentNotification(Map<String, dynamic> notification) async {
    // 긴급 알림 발송 시스템
    // 이메일, SMS, 슬랙 등 다중 채널 알림
  }
}

enum UrgencyLevel {
  low,
  medium,
  high,
}
```

### 8.2 증거 보전 시스템
```dart
// lib/core/legal/evidence_preservation.dart
class EvidencePreservation {
  static Future<void> preserveEvidence({
    required String caseId,
    required String targetType,
    required String targetId,
    required String requestedBy,
  }) async {
    // 1. 증거 데이터 수집
    final evidenceData = await _collectEvidenceData(targetType, targetId);
    
    // 2. 해시값 생성 (무결성 보장)
    final hashValue = _generateHash(evidenceData);
    
    // 3. 안전한 저장소에 보관
    await _storeEvidence(caseId, evidenceData, hashValue);
    
    // 4. 보전 기록 생성
    await _recordPreservation(caseId, targetType, targetId, requestedBy);
  }
  
  static Future<Map<String, dynamic>> _collectEvidenceData(
    String targetType,
    String targetId,
  ) async {
    switch (targetType) {
      case 'post':
        return await _collectPostEvidence(targetId);
      case 'comment':
        return await _collectCommentEvidence(targetId);
      case 'user':
        return await _collectUserEvidence(targetId);
      default:
        return {};
    }
  }
  
  static Future<Map<String, dynamic>> _collectPostEvidence(String postId) async {
    final post = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();
    
    final comments = await FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .get();
    
    return {
      'post': post.data(),
      'comments': comments.docs.map((doc) => doc.data()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  static Future<Map<String, dynamic>> _collectCommentEvidence(String commentId) async {
    final comment = await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .get();
    
    return {
      'comment': comment.data(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  static Future<Map<String, dynamic>> _collectUserEvidence(String userId) async {
    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    // 개인정보 제외하고 필요한 정보만 수집
    final userData = user.data() ?? {};
    userData.remove('phoneNumber');
    userData.remove('email');
    
    return {
      'user': userData,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  static String _generateHash(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static Future<void> _storeEvidence(
    String caseId,
    Map<String, dynamic> data,
    String hashValue,
  ) async {
    await FirebaseFirestore.instance.collection('evidence').add({
      'caseId': caseId,
      'data': data,
      'hashValue': hashValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  static Future<void> _recordPreservation(
    String caseId,
    String targetType,
    String targetId,
    String requestedBy,
  ) async {
    await FirebaseFirestore.instance.collection('preservation_records').add({
      'caseId': caseId,
      'targetType': targetType,
      'targetId': targetId,
      'requestedBy': requestedBy,
      'status': 'preserved',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
```

## 9. 컴플라이언스 체크리스트

### 9.1 정기 법적 검토 사항
```markdown
# 월간 법적 검토 체크리스트

## 개인정보보호 관련
- [ ] 개인정보 처리 현황 점검
- [ ] 위탁업체 관리 감독
- [ ] 개인정보 보호 교육 실시
- [ ] 개인정보 유출 사고 점검

## 콘텐츠 관리
- [ ] 게시물 모니터링 시스템 점검
- [ ] 신고 처리 현황 검토
- [ ] 명예훼손 분쟁 현황 점검
- [ ] 자동 필터링 시스템 업데이트

## 서비스 운영
- [ ] 이용약관 개정 필요성 검토
- [ ] 개인정보 처리방침 업데이트
- [ ] 법적 고지 대응 현황 점검
- [ ] 증거 보전 시스템 점검

## 법률 동향
- [ ] 관련 법률 개정 사항 확인
- [ ] 판례 동향 분석
- [ ] 규제 기관 가이드라인 확인
- [ ] 업계 모범 사례 조사
```

### 9.2 연간 법적 감사
```dart
// lib/core/legal/annual_compliance_audit.dart
class AnnualComplianceAudit {
  static Future<ComplianceReport> conductAnnualAudit() async {
    final report = ComplianceReport();
    
    // 1. 개인정보 처리 감사
    report.privacyCompliance = await _auditPrivacyCompliance();
    
    // 2. 콘텐츠 관리 감사
    report.contentCompliance = await _auditContentCompliance();
    
    // 3. 법적 대응 감사
    report.legalResponseCompliance = await _auditLegalResponseCompliance();
    
    // 4. 개선 사항 도출
    report.improvementPlans = await _generateImprovementPlans(report);
    
    return report;
  }
  
  static Future<PrivacyComplianceResult> _auditPrivacyCompliance() async {
    // 개인정보 처리 관련 감사
    return PrivacyComplianceResult(
      dataRetentionCompliance: await _checkDataRetention(),
      consentManagementCompliance: await _checkConsentManagement(),
      thirdPartyProcessingCompliance: await _checkThirdPartyProcessing(),
    );
  }
  
  static Future<ContentComplianceResult> _auditContentCompliance() async {
    // 콘텐츠 관리 관련 감사
    return ContentComplianceResult(
      moderationEffectiveness: await _checkModerationEffectiveness(),
      reportProcessingCompliance: await _checkReportProcessing(),
      automatedFilteringCompliance: await _checkAutomatedFiltering(),
    );
  }
  
  static Future<LegalResponseComplianceResult> _auditLegalResponseCompliance() async {
    // 법적 대응 관련 감사
    return LegalResponseComplianceResult(
      responseTimeCompliance: await _checkResponseTimes(),
      evidencePreservationCompliance: await _checkEvidencePreservation(),
      legalNoticeHandlingCompliance: await _checkLegalNoticeHandling(),
    );
  }
  
  static Future<List<ImprovementPlan>> _generateImprovementPlans(
    ComplianceReport report,
  ) async {
    final plans = <ImprovementPlan>[];
    
    // 개선 계획 생성 로직
    if (report.privacyCompliance.score < 80) {
      plans.add(ImprovementPlan(
        area: 'Privacy Compliance',
        description: '개인정보 보호 정책 강화',
        priority: Priority.high,
        deadline: DateTime.now().add(Duration(days: 30)),
      ));
    }
    
    return plans;
  }
  
  // 각종 체크 메서드들
  static Future<bool> _checkDataRetention() async {
    // 데이터 보관 기간 준수 여부 확인
    return true;
  }
  
  static Future<bool> _checkConsentManagement() async {
    // 동의 관리 시스템 점검
    return true;
  }
  
  static Future<bool> _checkThirdPartyProcessing() async {
    // 제3자 처리 위탁 관리 점검
    return true;
  }
  
  static Future<double> _checkModerationEffectiveness() async {
    // 콘텐츠 모더레이션 효과성 측정
    return 85.0;
  }
  
  static Future<bool> _checkReportProcessing() async {
    // 신고 처리 절차 준수 여부
    return true;
  }
  
  static Future<bool> _checkAutomatedFiltering() async {
    // 자동 필터링 시스템 점검
    return true;
  }
  
  static Future<bool> _checkResponseTimes() async {
    // 법적 대응 시간 준수 여부
    return true;
  }
  
  static Future<bool> _checkEvidencePreservation() async {
    // 증거 보전 시스템 점검
    return true;
  }
  
  static Future<bool> _checkLegalNoticeHandling() async {
    // 법적 고지 처리 절차 점검
    return true;
  }
}

class ComplianceReport {
  late PrivacyComplianceResult privacyCompliance;
  late ContentComplianceResult contentCompliance;
  late LegalResponseComplianceResult legalResponseCompliance;
  late List<ImprovementPlan> improvementPlans;
}

class PrivacyComplianceResult {
  final bool dataRetentionCompliance;
  final bool consentManagementCompliance;
  final bool thirdPartyProcessingCompliance;
  
  PrivacyComplianceResult({
    required this.dataRetentionCompliance,
    required this.consentManagementCompliance,
    required this.thirdPartyProcessingCompliance,
  });
  
  double get score {
    int compliantItems = 0;
    if (dataRetentionCompliance) compliantItems++;
    if (consentManagementCompliance) compliantItems++;
    if (thirdPartyProcessingCompliance) compliantItems++;
    
    return (compliantItems / 3) * 100;
  }
}

class ContentComplianceResult {
  final double moderationEffectiveness;
  final bool reportProcessingCompliance;
  final bool automatedFilteringCompliance;
  
  ContentComplianceResult({
    required this.moderationEffectiveness,
    required this.reportProcessingCompliance,
    required this.automatedFilteringCompliance,
  });
}

class LegalResponseComplianceResult {
  final bool responseTimeCompliance;
  final bool evidencePreservationCompliance;
  final bool legalNoticeHandlingCompliance;
  
  LegalResponseComplianceResult({
    required this.responseTimeCompliance,
    required this.evidencePreservationCompliance,
    required this.legalNoticeHandlingCompliance,
  });
}

class ImprovementPlan {
  final String area;
  final String description;
  final Priority priority;
  final DateTime deadline;
  
  ImprovementPlan({
    required this.area,
    required this.description,
    required this.priority,
    required this.deadline,
  });
}

enum Priority {
  low,
  medium,
  high,
}
```

이 법적 자문 개발 계획서는 security.md, database.md, backend.md와 연계하여 법적 리스크를 최소화하고 컴플라이언스를 보장하는 체계를 구축합니다. 