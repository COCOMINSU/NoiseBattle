# Database 개발 계획서

> **Project:** 소음과 전쟁 - Firebase Firestore 기반 데이터베이스 설계

## 1. 데이터베이스 아키텍처 개요

### 1.1 기술 스택
- **Primary Database**: Firebase Firestore (NoSQL 문서 데이터베이스)
- **Real-time Database**: Firebase Realtime Database (실시간 알림용)
- **Storage**: Firebase Cloud Storage (이미지, 오디오 파일)
- **Analytics**: Firebase Analytics + Google Analytics
- **Big Data**: Google BigQuery (데이터 분석 및 랭킹 시스템)

### 1.2 데이터베이스 구조 원칙
- **확장성**: 대용량 데이터 처리 가능한 구조
- **성능**: 효율적인 쿼리를 위한 인덱스 설계
- **보안**: 역할 기반 접근 제어 (RBAC)
- **분석**: 빅데이터 분석을 위한 데이터 구조화

## 2. 컬렉션 구조

### 2.1 users 컬렉션
```javascript
// users/{userId}
{
  "uid": "string",                    // Firebase Auth UID
  "email": "string",                  // 이메일 주소
  "phoneNumber": "string",            // 휴대폰 번호 (본인인증용)
  "nickname": "string",               // 사용자 닉네임
  "profileImageUrl": "string",        // 프로필 이미지 URL
  "isVerified": boolean,              // 본인인증 완료 여부
  "isApartmentVerified": boolean,     // 아파트 인증 완료 여부
  "apartmentInfo": {                  // 아파트 정보
    "name": "string",                 // 아파트 명
    "address": {
      "sido": "string",               // 시/도
      "sigungu": "string",            // 시/군/구
      "eupmyeondong": "string",       // 읍/면/동
      "detailAddress": "string",      // 상세 주소
      "postalCode": "string",         // 우편번호
      "coordinates": {                // 좌표 정보
        "latitude": number,
        "longitude": number
      }
    },
    "dong": "string",                 // 동
    "ho": "string",                   // 호수
    "verifiedAt": timestamp,          // 인증 완료 시각
    "verificationMethod": "string"    // 인증 방법 (document, etc.)
  },
  "socialLogins": {                   // 소셜 로그인 정보
    "google": {
      "id": "string",
      "email": "string"
    },
    "kakao": {
      "id": "string",
      "email": "string"
    },
    "naver": {
      "id": "string",
      "email": "string"
    }
  },
  "preferences": {                    // 사용자 설정
    "pushNotifications": boolean,
    "emailNotifications": boolean,
    "locationSharing": boolean,
    "autoLocationTag": boolean        // 자동 위치 태그 (신규)
  },
  "statistics": {                     // 사용자 통계
    "postCount": number,
    "commentCount": number,
    "likeCount": number,
    "reportCount": number,
    "noiseRecordCount": number        // 소음 녹음 횟수 (신규)
  },
  "storage": {                        // 사용자 스토리지 사용량 (신규)
    "totalSizeBytes": number,         // 총 사용량 (바이트)
    "audioFileCount": number,         // 오디오 파일 수
    "lastCleanupAt": timestamp        // 마지막 정리 시각
  },
  "createdAt": timestamp,
  "updatedAt": timestamp,
  "lastLoginAt": timestamp,
  "isActive": boolean,                // 활성 상태
  "isBlocked": boolean,               // 차단 여부
  "role": "string"                    // user, admin, moderator
}
```

### 2.2 posts 컬렉션
```javascript
// posts/{postId}
{
  "id": "string",                     // 게시글 ID
  "userId": "string",                 // 작성자 ID
  "title": "string",                  // 제목
  "content": "string",                // 내용
  "category": "string",               // 카테고리
  "boardType": "string",              // 게시판 유형
  "tags": ["string"],                 // 태그 배열
  "imageUrls": ["string"],            // 이미지 URL 배열
  "noiseRecord": {                    // 소음 측정 데이터 (업데이트됨)
    "recordId": "string",             // 소음 기록 ID
    "maxDecibel": number,
    "avgDecibel": number,
    "minDecibel": number,
    "duration": number,               // 측정 시간 (초)
    "audioFileUrl": "string",         // 오디오 파일 URL
    "recordedAt": timestamp,
    "location": {
      "coordinates": {
        "latitude": number,
        "longitude": number
      },
      "address": {
        "sido": "string",
        "sigungu": "string", 
        "eupmyeondong": "string",
        "detailAddress": "string"
      },
      "accuracy": number              // GPS 정확도 (미터)
    },
    "deviceInfo": {                   // 측정 기기 정보
      "model": "string",
      "os": "string",
      "osVersion": "string",            // OS 버전
      "appVersion": "string",           // 앱 버전
      "microphoneType": "string",       // 마이크 타입
      "calibrationOffset": number       // 교정 오프셋 (dB)
    }
  },
  "location": {                       // 게시글 위치 정보
    "sido": "string",
    "sigungu": "string",
    "eupmyeondong": "string",
    "apartmentName": "string",
    "coordinates": {
      "latitude": number,
      "longitude": number
    }
  },
  "visibility": "string",             // public, apartment, private
  "apartmentId": "string",            // 아파트 ID (우리 아파트 모임용)
  "metrics": {                        // 게시글 지표
    "likeCount": number,
    "commentCount": number,
    "viewCount": number,
    "shareCount": number,
    "reportCount": number
  },
  "engagement": {                     // 참여도 지표
    "score": number,                  // 참여도 점수
    "lastEngagementAt": timestamp,
    "trendingScore": number           // 트렌딩 점수
  },
  "moderation": {                     // 게시글 관리
    "isApproved": boolean,
    "isReported": boolean,
    "reportReasons": ["string"],
    "moderatedAt": timestamp,
    "moderatorId": "string"
  },
  "createdAt": timestamp,
  "updatedAt": timestamp,
  "deletedAt": timestamp,
  "isDeleted": boolean,
  "isLocked": boolean,                // 댓글 잠금
  "isPinned": boolean,                // 상단 고정
  "isFeatured": boolean               // 추천 게시글
}
```

### 2.3 comments 컬렉션
```javascript
// comments/{commentId}
{
  "id": "string",
  "postId": "string",                 // 게시글 ID
  "userId": "string",                 // 댓글 작성자 ID
  "parentCommentId": "string",        // 대댓글인 경우 부모 댓글 ID
  "content": "string",                // 댓글 내용
  "depth": number,                    // 댓글 깊이 (0: 댓글, 1: 대댓글)
  "imageUrls": ["string"],            // 이미지 URL 배열
  "metrics": {
    "likeCount": number,
    "dislikeCount": number,
    "reportCount": number
  },
  "isDeleted": boolean,
  "deletedAt": timestamp,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### 2.4 apartments 컬렉션
```javascript
// apartments/{apartmentId}
{
  "id": "string",
  "name": "string",                   // 아파트 명
  "address": {
    "sido": "string",
    "sigungu": "string",
    "eupmyeondong": "string",
    "detailAddress": "string",
    "postalCode": "string",
    "coordinates": {
      "latitude": number,
      "longitude": number
    }
  },
  "buildingInfo": {                   // 건물 정보
    "buildYear": number,
    "totalDong": number,
    "totalHo": number,
    "floors": number,
    "parkingSpaces": number
  },
  "noiseStatistics": {                // 소음 통계 (업데이트됨)
    "totalReports": number,
    "totalRecords": number,           // 소음 녹음 기록 수 (신규)
    "avgNoiseLevel": number,
    "maxNoiseLevel": number,
    "lastReportAt": timestamp,
    "lastRecordAt": timestamp,        // 마지막 녹음 시각 (신규)
    "noiseIndex": number,             // 소음 지수
    "trendingScore": number,          // 트렌딩 점수
    "hourlyStats": {                  // 시간대별 통계 (신규)
      "0": { "avgDecibel": number, "recordCount": number },
      "1": { "avgDecibel": number, "recordCount": number },
      // ... 24시간
      "23": { "avgDecibel": number, "recordCount": number }
    },
    "weeklyTrend": {                  // 주간 트렌드 (신규)
      "thisWeek": number,
      "lastWeek": number,
      "changePercent": number
    }
  },
  "verifiedResidents": number,        // 인증된 주민 수
  "totalPosts": number,               // 총 게시글 수
  "createdAt": timestamp,
  "updatedAt": timestamp,
  "isActive": boolean
}
```

### 2.5 noise_records 컬렉션 (대폭 업데이트)
```javascript
// noise_records/{recordId}
{
  "id": "string",
  "userId": "string",                 // 녹음자 ID
  "fileName": "string",               // 사용자 지정 파일명
  "customTitle": "string",            // 사용자 지정 제목 (신규)
  "description": "string",            // 소음 상황 설명 (신규)
  "measurements": {                   // 측정 데이터
    "maxDecibel": number,
    "avgDecibel": number,
    "minDecibel": number,
    "duration": number,               // 측정 시간 (초)
    "sampleRate": number,             // 샘플링 주파수
    "sampleCount": number,            // 총 샘플 수
    "frequencyData": [number]         // 주파수 분석 데이터 (선택적)
  },
  "deviceInfo": {                     // 측정 기기 정보
    "model": "string",                // 기기 모델
    "os": "string",                   // 운영체제
    "osVersion": "string",            // OS 버전
    "appVersion": "string",           // 앱 버전
    "microphoneType": "string",       // 마이크 타입
    "calibrationOffset": number       // 교정 오프셋 (dB)
  },
  "location": {                       // 위치 정보 (확장됨)
    "coordinates": {
      "latitude": number,
      "longitude": number
    },
    "address": {                      // 역지오코딩 주소
      "sido": "string",
      "sigungu": "string",
      "eupmyeondong": "string",
      "detailAddress": "string",
      "postalCode": "string"
    },
    "accuracy": number,               // GPS 정확도 (미터)
    "altitude": number,               // 고도 (미터)
    "indoorOutdoor": "string",        // "indoor" / "outdoor" / "unknown"
    "floorLevel": number,             // 층수 (실내인 경우)
    "locationSource": "string"        // "gps" / "network" / "manual"
  },
  "audioFile": {                      // 오디오 파일 정보 (신규)
    "audioFileUrl": "string",         // Storage URL
    "fileSizeBytes": number,          // 파일 크기
    "format": "string",               // 파일 형식 (mp3, wav, etc.)
    "uploadedAt": timestamp,          // 업로드 완료 시각
    "processingStatus": "string",     // "pending" / "processing" / "completed" / "failed"
    "thumbnailUrl": "string",         // 스펙트로그램 썸네일 URL
    "downloadCount": number           // 다운로드 횟수
  },
  "audioMetadata": {                  // 오디오 메타데이터 (자동 생성)
    "actualDuration": number,         // 실제 오디오 길이 (초)
    "bitrate": number,                // 비트레이트
    "channels": number,               // 채널 수
    "codec": "string",                // 코덱
    "peakAmplitude": number,          // 최대 진폭
    "rmsLevel": number                // RMS 레벨
  },
  "frequencyAnalysis": {              // 주파수 분석 결과 (자동 생성)
    "dominantFrequency": number,      // 주요 주파수 (Hz)
    "frequencySpectrum": [number],    // 주파수 스펙트럼
    "noiseType": "string",            // 소음 유형 분류
    "confidence": number,             // 분류 신뢰도
    "harmonics": [number]             // 하모닉 성분
  },
  "environmentalContext": {           // 환경 정보 (신규)
    "weather": "string",              // 날씨 (API 연동)
    "temperature": number,            // 온도 (°C)
    "humidity": number,               // 습도 (%)
    "windSpeed": number,              // 풍속 (m/s)
    "timeOfDay": "string",            // "morning" / "afternoon" / "evening" / "night"
    "dayOfWeek": "string"             // 요일
  },
  "sharing": {                        // 공유 설정 (신규)
    "isPublic": boolean,              // 공개 여부
    "allowDownload": boolean,         // 다운로드 허용
    "sharedWithUsers": ["string"],    // 공유된 사용자 ID 목록
    "shareToken": "string",           // 공유 토큰
    "shareExpiry": timestamp          // 공유 만료일
  },
  "tags": ["string"],                 // 사용자 정의 태그
  "apartmentId": "string",            // 연관 아파트 ID
  "relatedPostId": "string",          // 연관 게시글 ID (게시글로 변환된 경우)
  "recordedAt": timestamp,            // 녹음 시각
  "createdAt": timestamp,             // 생성 시각
  "updatedAt": timestamp,             // 수정 시각
  "isVerified": boolean,              // 검증된 측정값 여부
  "verifiedBy": "string",             // 검증자 ID
  "verifiedAt": timestamp,            // 검증 시각
  "isProcessed": boolean,             // 처리 완료 여부
  "processedAt": timestamp,           // 처리 완료 시각
  "isDeleted": boolean,               // 삭제 여부
  "deletedAt": timestamp              // 삭제 시각
}
```

### 2.6 user_noise_collections 컬렉션 (신규)
```javascript
// user_noise_collections/{collectionId}
{
  "id": "string",
  "userId": "string",                 // 소유자 ID
  "title": "string",                  // 컬렉션 제목
  "description": "string",            // 설명
  "noiseRecordIds": ["string"],       // 포함된 녹음 ID 목록
  "coverImageUrl": "string",          // 커버 이미지
  "isPublic": boolean,                // 공개 여부
  "tags": ["string"],                 // 태그
  "statistics": {                     // 컬렉션 통계
    "totalRecords": number,
    "totalDuration": number,          // 총 길이 (초)
    "avgDecibel": number,
    "maxDecibel": number
  },
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

### 2.7 rankings 컬렉션 (집계 데이터)
```javascript
// rankings/{rankingType}
{
  "type": "string",                   // region, apartment, user
  "period": "string",                 // daily, weekly, monthly, yearly
  "lastUpdated": timestamp,
  "data": [
    {
      "rank": number,
      "id": "string",                 // 지역/아파트/사용자 ID
      "name": "string",               // 이름
      "score": number,                // 점수
      "noiseIndex": number,           // 소음 지수
      "totalReports": number,         // 총 신고 수
      "totalRecords": number,         // 총 녹음 수 (신규)
      "change": number,               // 순위 변동
      "metadata": {
        "address": "string",
        "coordinates": {
          "latitude": number,
          "longitude": number
        },
        "avgDecibel": number,         // 평균 데시벨 (신규)
        "peakHours": ["string"]       // 피크 시간대 (신규)
      }
    }
  ]
}
```

### 2.8 notifications 컬렉션
```javascript
// notifications/{notificationId}
{
  "id": "string",
  "userId": "string",                 // 수신자 ID
  "type": "string",                   // comment, like, report, system, noise_processed
  "title": "string",
  "message": "string",
  "data": {                           // 알림 관련 데이터
    "postId": "string",
    "commentId": "string",
    "fromUserId": "string",
    "noiseRecordId": "string"         // 소음 기록 관련 (신규)
  },
  "isRead": boolean,
  "isDelivered": boolean,
  "deliveredAt": timestamp,
  "readAt": timestamp,
  "createdAt": timestamp,
  "expiresAt": timestamp
}
```

### 2.9 reports 컬렉션
```javascript
// reports/{reportId}
{
  "id": "string",
  "reporterId": "string",             // 신고자 ID
  "targetType": "string",             // post, comment, user, noise_record
  "targetId": "string",               // 신고 대상 ID
  "targetUserId": "string",           // 신고 대상 사용자 ID
  "reason": "string",                 // 신고 사유
  "description": "string",            // 신고 상세 설명
  "evidence": {                       // 증거 자료
    "imageUrls": ["string"],
    "additionalInfo": "string"
  },
  "status": "string",                 // pending, processing, resolved, rejected
  "moderatorId": "string",            // 처리 담당자 ID
  "moderatorNote": "string",          // 처리 의견
  "actions": ["string"],              // 취해진 조치
  "createdAt": timestamp,
  "processedAt": timestamp,
  "resolvedAt": timestamp
}
```

### 2.10 region_noise_stats 컬렉션 (신규)
```javascript
// region_noise_stats/{regionKey}
{
  "regionKey": "string",              // "{sido}_{sigungu}_{eupmyeondong}"
  "sido": "string",
  "sigungu": "string", 
  "eupmyeondong": "string",
  "totalRecords": number,             // 총 녹음 수
  "avgDecibel": number,               // 평균 데시벨
  "maxDecibel": number,               // 최고 데시벨
  "totalDecibel": number,             // 총 데시벨 합
  "hourlyDistribution": {             // 시간대별 분포
    "0": number, "1": number, "2": number, // 각 시간대별 기록 수
    // ... 24시간
    "23": number
  },
  "weeklyTrend": {                    // 주간 트렌드
    "currentWeek": number,
    "previousWeek": number,
    "changePercent": number
  },
  "topNoiseTypes": [                  // 주요 소음 유형
    {
      "type": "string",
      "count": number,
      "avgDecibel": number
    }
  ],
  "lastUpdated": timestamp,
  "createdAt": timestamp
}
```

## 3. 인덱스 설계

### 3.1 복합 인덱스 (업데이트됨)
```javascript
// posts 컬렉션 인덱스
{
  "boardType": "ASC",
  "createdAt": "DESC"
}

{
  "boardType": "ASC",
  "category": "ASC",
  "createdAt": "DESC"
}

{
  "location.sido": "ASC",
  "location.sigungu": "ASC",
  "createdAt": "DESC"
}

{
  "apartmentId": "ASC",
  "createdAt": "DESC"
}

{
  "isDeleted": "ASC",
  "visibility": "ASC",
  "createdAt": "DESC"
}

// 트렌딩 게시글용
{
  "engagement.trendingScore": "DESC",
  "createdAt": "DESC"
}

// 소음 관련 게시글 검색용 (신규)
{
  "noiseRecord.maxDecibel": "DESC",
  "createdAt": "DESC"
}

// noise_records 컬렉션 인덱스 (신규/업데이트)
{
  "userId": "ASC",
  "recordedAt": "DESC"
}

{
  "location.address.sido": "ASC",
  "location.address.sigungu": "ASC",
  "recordedAt": "DESC"
}

{
  "location.address.sido": "ASC",
  "location.address.sigungu": "ASC",
  "location.address.eupmyeondong": "ASC",
  "recordedAt": "DESC"
}

{
  "apartmentId": "ASC",
  "recordedAt": "DESC"
}

{
  "measurements.maxDecibel": "DESC",
  "recordedAt": "DESC"
}

{
  "sharing.isPublic": "ASC",
  "recordedAt": "DESC"
}

{
  "isProcessed": "ASC",
  "createdAt": "ASC"
}

// 시간대별 분석용 (신규)
{
  "environmentalContext.timeOfDay": "ASC",
  "measurements.avgDecibel": "DESC"
}

// 날씨별 분석용 (신규)
{
  "environmentalContext.weather": "ASC",
  "measurements.avgDecibel": "DESC"
}

// 기기별 분석용 (신규)
{
  "deviceInfo.model": "ASC",
  "measurements.avgDecibel": "DESC"
}
```

### 3.2 단일 필드 인덱스 (업데이트됨)
```javascript
// 자주 사용되는 필드들
"userId"
"postId"
"createdAt"
"updatedAt"
"recordedAt"
"isDeleted"
"isProcessed"
"isVerified"
"apartmentId"
"noiseStatistics.noiseIndex"
"fileName"
"sharing.isPublic"
"audioFile.processingStatus"
"frequencyAnalysis.noiseType"
```

## 4. 쿼리 최적화

### 4.1 게시글 조회 쿼리
```javascript
// 게시판별 게시글 조회
const getPosts = async (boardType, category = null, lastDoc = null) => {
  let query = firestore
    .collection('posts')
    .where('boardType', '==', boardType)
    .where('isDeleted', '==', false)
    .where('visibility', '==', 'public');
  
  if (category) {
    query = query.where('category', '==', category);
  }
  
  query = query.orderBy('createdAt', 'desc').limit(20);
  
  if (lastDoc) {
    query = query.startAfter(lastDoc);
  }
  
  return await query.get();
};

// 지역별 게시글 조회
const getPostsByRegion = async (sido, sigungu, eupmyeondong = null) => {
  let query = firestore
    .collection('posts')
    .where('location.sido', '==', sido)
    .where('location.sigungu', '==', sigungu)
    .where('isDeleted', '==', false);
  
  if (eupmyeondong) {
    query = query.where('location.eupmyeondong', '==', eupmyeondong);
  }
  
  return await query.orderBy('createdAt', 'desc').limit(20).get();
};

// 소음 기록이 있는 게시글 조회 (신규)
const getNoisePostsByDecibel = async (minDecibel = 60) => {
  return await firestore
    .collection('posts')
    .where('noiseRecord.maxDecibel', '>=', minDecibel)
    .where('isDeleted', '==', false)
    .orderBy('noiseRecord.maxDecibel', 'desc')
    .orderBy('createdAt', 'desc')
    .limit(20)
    .get();
};

// 아파트 인증 사용자 게시글 필터링
const getVerifiedPosts = async (boardType) => {
  const postsQuery = firestore
    .collection('posts')
    .where('boardType', '==', boardType)
    .where('isDeleted', '==', false)
    .orderBy('createdAt', 'desc')
    .limit(20);
  
  const postsSnapshot = await postsQuery.get();
  
  // 클라이언트 측에서 사용자 인증 상태 확인
  const verifiedPosts = [];
  for (const doc of postsSnapshot.docs) {
    const post = doc.data();
    const userDoc = await firestore.collection('users').doc(post.userId).get();
    const user = userDoc.data();
    
    if (user.isApartmentVerified) {
      verifiedPosts.push({ ...post, userAddress: user.apartmentInfo.address });
    }
  }
  
  return verifiedPosts;
};
```

### 4.2 소음 데이터 집계 쿼리 (대폭 업데이트)
```javascript
// 사용자별 소음 기록 조회 (신규)
const getUserNoiseRecords = async (userId, limit = 20, startAfter = null) => {
  let query = firestore
    .collection('noise_records')
    .where('userId', '==', userId)
    .where('isDeleted', '==', false)
    .orderBy('recordedAt', 'desc')
    .limit(limit);
  
  if (startAfter) {
    query = query.startAfter(startAfter);
  }
  
  return await query.get();
};

// 공개 소음 기록 조회 (신규)
const getPublicNoiseRecords = async (limit = 20) => {
  return await firestore
    .collection('noise_records')
    .where('sharing.isPublic', '==', true)
    .where('isDeleted', '==', false)
    .where('isProcessed', '==', true)
    .orderBy('recordedAt', 'desc')
    .limit(limit)
    .get();
};

// 데시벨 범위별 소음 기록 조회 (신규)
const getNoiseRecordsByDecibelRange = async (minDecibel, maxDecibel = 120) => {
  return await firestore
    .collection('noise_records')
    .where('measurements.maxDecibel', '>=', minDecibel)
    .where('measurements.maxDecibel', '<=', maxDecibel)
    .where('isDeleted', '==', false)
    .orderBy('measurements.maxDecibel', 'desc')
    .orderBy('recordedAt', 'desc')
    .limit(50)
    .get();
};

// 지역별 소음 통계
const getRegionNoiseStats = async (sido, sigungu, eupmyeondong) => {
  const query = firestore
    .collection('noise_records')
    .where('location.address.sido', '==', sido)
    .where('location.address.sigungu', '==', sigungu)
    .where('location.address.eupmyeondong', '==', eupmyeondong)
    .where('recordedAt', '>=', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)) // 최근 30일
    .where('isDeleted', '==', false);
  
  const snapshot = await query.get();
  
  const stats = {
    totalRecords: snapshot.size,
    avgDecibel: 0,
    maxDecibel: 0,
    minDecibel: 200,
    records: [],
    hourlyDistribution: new Array(24).fill(0),
    noiseTypeDistribution: {}
  };
  
  snapshot.forEach(doc => {
    const record = doc.data();
    const measurements = record.measurements;
    const recordedAt = record.recordedAt.toDate();
    
    stats.records.push(measurements.avgDecibel);
    stats.maxDecibel = Math.max(stats.maxDecibel, measurements.maxDecibel);
    stats.minDecibel = Math.min(stats.minDecibel, measurements.avgDecibel);
    
    // 시간대별 분포
    const hour = recordedAt.getHours();
    stats.hourlyDistribution[hour]++;
    
    // 소음 유형별 분포
    const noiseType = record.frequencyAnalysis?.noiseType || 'unknown';
    stats.noiseTypeDistribution[noiseType] = (stats.noiseTypeDistribution[noiseType] || 0) + 1;
  });
  
  if (stats.records.length > 0) {
    stats.avgDecibel = stats.records.reduce((a, b) => a + b, 0) / stats.records.length;
    stats.minDecibel = stats.minDecibel === 200 ? 0 : stats.minDecibel;
  }
  
  return stats;
};

// 아파트별 소음 통계 (업데이트)
const getApartmentNoiseStats = async (apartmentId) => {
  const query = firestore
    .collection('noise_records')
    .where('apartmentId', '==', apartmentId)
    .where('recordedAt', '>=', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000))
    .where('isDeleted', '==', false)
    .orderBy('recordedAt', 'desc');
  
  const snapshot = await query.get();
  
  const stats = {
    totalRecords: snapshot.size,
    avgDecibel: 0,
    maxDecibel: 0,
    recentTrend: [],
    floorAnalysis: {},
    timePatterns: new Array(24).fill(0)
  };
  
  snapshot.forEach(doc => {
    const record = doc.data();
    const measurements = record.measurements;
    const location = record.location;
    const recordedAt = record.recordedAt.toDate();
    
    stats.avgDecibel += measurements.avgDecibel;
    stats.maxDecibel = Math.max(stats.maxDecibel, measurements.maxDecibel);
    
    // 층별 분석
    if (location.floorLevel) {
      const floor = location.floorLevel;
      if (!stats.floorAnalysis[floor]) {
        stats.floorAnalysis[floor] = { count: 0, avgDecibel: 0, totalDecibel: 0 };
      }
      stats.floorAnalysis[floor].count++;
      stats.floorAnalysis[floor].totalDecibel += measurements.avgDecibel;
      stats.floorAnalysis[floor].avgDecibel = stats.floorAnalysis[floor].totalDecibel / stats.floorAnalysis[floor].count;
    }
    
    // 시간 패턴 분석
    const hour = recordedAt.getHours();
    stats.timePatterns[hour]++;
    
    // 최근 7일 트렌드
    const daysDiff = Math.floor((Date.now() - recordedAt.getTime()) / (1000 * 60 * 60 * 24));
    if (daysDiff < 7) {
      stats.recentTrend.push({
        day: daysDiff,
        decibel: measurements.avgDecibel,
        date: recordedAt.toISOString().split('T')[0]
      });
    }
  });
  
  if (stats.totalRecords > 0) {
    stats.avgDecibel = stats.avgDecibel / stats.totalRecords;
  }
  
  return stats;
};

// 소음 유형별 통계 (신규)
const getNoiseTypeStatistics = async (timeRange = 30) => {
  const startDate = new Date(Date.now() - timeRange * 24 * 60 * 60 * 1000);
  
  const snapshot = await firestore
    .collection('noise_records')
    .where('recordedAt', '>=', startDate)
    .where('isDeleted', '==', false)
    .where('isProcessed', '==', true)
    .get();
  
  const typeStats = {};
  
  snapshot.forEach(doc => {
    const record = doc.data();
    const noiseType = record.frequencyAnalysis?.noiseType || 'unknown';
    const avgDecibel = record.measurements.avgDecibel;
    
    if (!typeStats[noiseType]) {
      typeStats[noiseType] = {
        count: 0,
        totalDecibel: 0,
        avgDecibel: 0,
        maxDecibel: 0,
        locations: new Set()
      };
    }
    
    typeStats[noiseType].count++;
    typeStats[noiseType].totalDecibel += avgDecibel;
    typeStats[noiseType].maxDecibel = Math.max(typeStats[noiseType].maxDecibel, record.measurements.maxDecibel);
    
    const regionKey = `${record.location.address.sido}_${record.location.address.sigungu}`;
    typeStats[noiseType].locations.add(regionKey);
  });
  
  // 평균 계산 및 Set을 Array로 변환
  Object.keys(typeStats).forEach(type => {
    const stats = typeStats[type];
    stats.avgDecibel = stats.totalDecibel / stats.count;
    stats.locations = Array.from(stats.locations);
  });
  
  return typeStats;
};
```

## 5. 실시간 데이터 업데이트

### 5.1 Cloud Functions - 집계 데이터 업데이트 (업데이트)
```javascript
// 아파트 통계 업데이트
exports.updateApartmentStats = functions.firestore
  .document('noise_records/{recordId}')
  .onWrite(async (change, context) => {
    if (!change.after.exists) return; // 삭제된 경우
    
    const record = change.after.data();
    const apartmentId = record.apartmentId;
    
    if (!apartmentId) return;
    
    const apartmentRef = firestore.collection('apartments').doc(apartmentId);
    
    // 해당 아파트의 소음 기록 통계 계산
    const recordsQuery = firestore
      .collection('noise_records')
      .where('apartmentId', '==', apartmentId)
      .where('isDeleted', '==', false);
    
    const recordsSnapshot = await recordsQuery.get();
    
    let totalDecibel = 0;
    let maxDecibel = 0;
    let recordCount = 0;
    const hourlyStats = new Array(24).fill(0).map(() => ({ totalDecibel: 0, count: 0 }));
    
    recordsSnapshot.forEach(doc => {
      const recordData = doc.data();
      const measurements = recordData.measurements;
      const recordedAt = recordData.recordedAt.toDate();
      
      totalDecibel += measurements.avgDecibel;
      maxDecibel = Math.max(maxDecibel, measurements.maxDecibel);
      recordCount++;
      
      // 시간대별 통계
      const hour = recordedAt.getHours();
      hourlyStats[hour].totalDecibel += measurements.avgDecibel;
      hourlyStats[hour].count++;
    });
    
    const avgDecibel = recordCount > 0 ? totalDecibel / recordCount : 0;
    
    // 시간대별 평균 계산
    const hourlyStatsFormatted = {};
    hourlyStats.forEach((stat, hour) => {
      hourlyStatsFormatted[hour] = {
        avgDecibel: stat.count > 0 ? stat.totalDecibel / stat.count : 0,
        recordCount: stat.count
      };
    });
    
    // 소음 지수 계산
    const noiseIndex = calculateNoiseIndex(recordCount, avgDecibel, maxDecibel);
    
    await apartmentRef.update({
      'noiseStatistics.totalRecords': recordCount,
      'noiseStatistics.avgNoiseLevel': avgDecibel,
      'noiseStatistics.maxNoiseLevel': maxDecibel,
      'noiseStatistics.noiseIndex': noiseIndex,
      'noiseStatistics.lastRecordAt': admin.firestore.FieldValue.serverTimestamp(),
      'noiseStatistics.hourlyStats': hourlyStatsFormatted,
      'updatedAt': admin.firestore.FieldValue.serverTimestamp()
    });
  });

// 지역별 소음 통계 업데이트 (신규)
exports.updateRegionNoiseStats = functions.firestore
  .document('noise_records/{recordId}')
  .onWrite(async (change, context) => {
    if (!change.after.exists) return;
    
    const record = change.after.data();
    const location = record.location;
    
    if (!location?.address) return;
    
    const regionKey = `${location.address.sido}_${location.address.sigungu}_${location.address.eupmyeondong}`;
    const regionRef = firestore.collection('region_noise_stats').doc(regionKey);
    
    // 해당 지역의 모든 소음 기록 재계산
    const recordsQuery = firestore
      .collection('noise_records')
      .where('location.address.sido', '==', location.address.sido)
      .where('location.address.sigungu', '==', location.address.sigungu)
      .where('location.address.eupmyeondong', '==', location.address.eupmyeondong)
      .where('isDeleted', '==', false);
    
    const recordsSnapshot = await recordsQuery.get();
    
    let totalDecibel = 0;
    let maxDecibel = 0;
    const hourlyDistribution = new Array(24).fill(0);
    const noiseTypes = {};
    
    recordsSnapshot.forEach(doc => {
      const recordData = doc.data();
      const measurements = recordData.measurements;
      const recordedAt = recordData.recordedAt.toDate();
      const noiseType = recordData.frequencyAnalysis?.noiseType || 'unknown';
      
      totalDecibel += measurements.avgDecibel;
      maxDecibel = Math.max(maxDecibel, measurements.maxDecibel);
      
      // 시간대별 분포
      const hour = recordedAt.getHours();
      hourlyDistribution[hour]++;
      
      // 소음 유형별 분포
      if (!noiseTypes[noiseType]) {
        noiseTypes[noiseType] = { count: 0, avgDecibel: 0, totalDecibel: 0 };
      }
      noiseTypes[noiseType].count++;
      noiseTypes[noiseType].totalDecibel += measurements.avgDecibel;
    });
    
    // 소음 유형별 평균 계산
    const topNoiseTypes = Object.keys(noiseTypes).map(type => ({
      type,
      count: noiseTypes[type].count,
      avgDecibel: noiseTypes[type].totalDecibel / noiseTypes[type].count
    })).sort((a, b) => b.count - a.count).slice(0, 5);
    
    const totalRecords = recordsSnapshot.size;
    const avgDecibel = totalRecords > 0 ? totalDecibel / totalRecords : 0;
    
    // 시간대별 분포를 객체로 변환
    const hourlyDistributionObj = {};
    hourlyDistribution.forEach((count, hour) => {
      hourlyDistributionObj[hour] = count;
    });
    
    await regionRef.set({
      regionKey,
      sido: location.address.sido,
      sigungu: location.address.sigungu,
      eupmyeondong: location.address.eupmyeondong,
      totalRecords,
      avgDecibel,
      maxDecibel,
      totalDecibel,
      hourlyDistribution: hourlyDistributionObj,
      topNoiseTypes,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
  });

// 소음 지수 계산 함수
function calculateNoiseIndex(recordCount, avgNoise, maxNoise) {
  const recordWeight = Math.min(recordCount / 50, 1) * 30; // 기록 수 가중치 (최대 30점)
  const avgNoiseWeight = Math.min(avgNoise / 100, 1) * 40; // 평균 소음 가중치 (최대 40점)
  const maxNoiseWeight = Math.min(maxNoise / 120, 1) * 30; // 최고 소음 가중치 (최대 30점)
  
  return Math.round(recordWeight + avgNoiseWeight + maxNoiseWeight);
}
```

### 5.2 랭킹 시스템 업데이트 (업데이트)
```javascript
// 일일 랭킹 업데이트 (Cloud Scheduler)
exports.updateDailyRankings = functions.pubsub
  .schedule('0 1 * * *') // 매일 오전 1시
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    // 지역별 랭킹 업데이트
    await updateRegionRankings();
    
    // 아파트별 랭킹 업데이트
    await updateApartmentRankings();
    
    // 사용자별 랭킹 업데이트 (신규)
    await updateUserRankings();
    
    // 주간/월간 랭킹 업데이트
    await updateWeeklyMonthlyRankings();
  });

const updateRegionRankings = async () => {
  const { BigQuery } = require('@google-cloud/bigquery');
  const bigquery = new BigQuery();
  
  const query = `
    SELECT 
      location_sido,
      location_sigungu,
      location_eupmyeondong,
      COUNT(*) as total_records,
      AVG(avg_decibel) as avg_noise_level,
      MAX(max_decibel) as peak_noise_level,
      -- 소음 지수 공식: (기록 수 × 0.3) + (평균 소음 레벨 × 0.4) + (피크 소음 × 0.3)
      (COUNT(*) * 0.3) + (AVG(avg_decibel) * 0.4) + (MAX(max_decibel) * 0.3) as noise_index
    FROM \`noisebattle.noise_records\`
    WHERE recorded_at >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
      AND is_deleted = FALSE
      AND is_processed = TRUE
    GROUP BY location_sido, location_sigungu, location_eupmyeondong
    HAVING COUNT(*) >= 5  -- 최소 5개 이상의 기록이 있는 지역만
    ORDER BY noise_index DESC
    LIMIT 100
  `;
  
  const [rows] = await bigquery.query(query);
  
  const rankingData = rows.map((row, index) => ({
    rank: index + 1,
    id: `${row.location_sido}-${row.location_sigungu}-${row.location_eupmyeondong}`,
    name: `${row.location_sido} ${row.location_sigungu} ${row.location_eupmyeondong}`,
    score: row.noise_index,
    noiseIndex: row.noise_index,
    totalReports: 0, // 기존 호환성을 위해 유지
    totalRecords: row.total_records,
    change: 0, // 이전 랭킹과 비교하여 계산
    metadata: {
      address: `${row.location_sido} ${row.location_sigungu} ${row.location_eupmyeondong}`,
      coordinates: null, // 지오코딩 API로 좌표 계산
      avgDecibel: row.avg_noise_level,
      peakHours: [] // 별도 쿼리로 계산
    }
  }));
  
  await firestore.collection('rankings').doc('region-daily').set({
    type: 'region',
    period: 'daily',
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    data: rankingData
  });
};

// 사용자별 랭킹 업데이트 (신규)
const updateUserRankings = async () => {
  const usersSnapshot = await firestore
    .collection('users')
    .where('statistics.noiseRecordCount', '>', 0)
    .orderBy('statistics.noiseRecordCount', 'desc')
    .limit(100)
    .get();
  
  const rankingData = [];
  
  for (let i = 0; i < usersSnapshot.docs.length; i++) {
    const userDoc = usersSnapshot.docs[i];
    const userData = userDoc.data();
    
    // 사용자의 평균 소음 레벨 계산
    const userRecordsQuery = await firestore
      .collection('noise_records')
      .where('userId', '==', userDoc.id)
      .where('isDeleted', '==', false)
      .where('recordedAt', '>=', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000))
      .get();
    
    let avgDecibel = 0;
    if (!userRecordsQuery.empty) {
      const totalDecibel = userRecordsQuery.docs.reduce((sum, doc) => {
        return sum + doc.data().measurements.avgDecibel;
      }, 0);
      avgDecibel = totalDecibel / userRecordsQuery.size;
    }
    
    rankingData.push({
      rank: i + 1,
      id: userDoc.id,
      nickname: userData.nickname || '익명사용자',
      totalRecords: userData.statistics.noiseRecordCount,
      avgDecibel: avgDecibel,
      postCount: userData.statistics.postCount,
      isVerified: userData.isApartmentVerified
    });
  }
  
  await firestore.collection('rankings').doc('user-daily').set({
    type: 'user',
    period: 'daily',
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    data: rankingData
  });
};
```

## 6. 데이터 보안 및 규칙 (업데이트)

### 6.1 Firestore Security Rules (업데이트)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 문서 규칙
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // 관리자는 모든 사용자 정보 접근 가능
      allow read, write: if request.auth != null && 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // 게시글 규칙
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                    request.auth.uid == resource.data.userId &&
                    validatePostData(resource.data);
      allow update: if request.auth != null && 
                    (request.auth.uid == resource.data.userId || 
                     hasModeratorRole(request.auth.uid));
      allow delete: if request.auth != null && 
                    (request.auth.uid == resource.data.userId || 
                     hasModeratorRole(request.auth.uid));
    }
    
    // 댓글 규칙
    match /comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                    request.auth.uid == resource.data.userId &&
                    validateCommentData(resource.data);
      allow update, delete: if request.auth != null && 
                           (request.auth.uid == resource.data.userId || 
                            hasModeratorRole(request.auth.uid));
    }
    
    // 아파트 정보 규칙
    match /apartments/{apartmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && hasModeratorRole(request.auth.uid);
    }
    
    // 소음 기록 규칙 (대폭 업데이트)
    match /noise_records/{recordId} {
      allow read: if request.auth != null && 
                  (request.auth.uid == resource.data.userId || 
                   resource.data.sharing.isPublic == true ||
                   request.auth.uid in resource.data.sharing.sharedWithUsers ||
                   hasModeratorRole(request.auth.uid));
      allow create: if request.auth != null && 
                    request.auth.uid == resource.data.userId &&
                    validateNoiseRecordData(resource.data);
      allow update: if request.auth != null && 
                    request.auth.uid == resource.data.userId &&
                    validateNoiseRecordUpdate(resource.data, request.resource.data);
      allow delete: if request.auth != null && 
                    (request.auth.uid == resource.data.userId || 
                     hasModeratorRole(request.auth.uid));
    }
    
    // 사용자 소음 컬렉션 규칙 (신규)
    match /user_noise_collections/{collectionId} {
      allow read: if request.auth != null && 
                  (request.auth.uid == resource.data.userId || 
                   resource.data.isPublic == true);
      allow create, update, delete: if request.auth != null && 
                                    request.auth.uid == resource.data.userId;
    }
    
    // 지역 소음 통계 규칙 (신규)
    match /region_noise_stats/{regionKey} {
      allow read: if request.auth != null;
      allow write: if false; // Cloud Functions에서만 업데이트
    }
    
    // 랭킹 규칙 (읽기 전용)
    match /rankings/{rankingId} {
      allow read: if request.auth != null;
      allow write: if false; // Cloud Functions에서만 업데이트
    }
    
    // 알림 규칙
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
    
    // 신고 규칙
    match /reports/{reportId} {
      allow read: if request.auth != null && 
                  (request.auth.uid == resource.data.reporterId || 
                   hasModeratorRole(request.auth.uid));
      allow create: if request.auth != null && 
                    request.auth.uid == resource.data.reporterId;
      allow update: if request.auth != null && hasModeratorRole(request.auth.uid);
    }
    
    // 헬퍼 함수들
    function hasModeratorRole(uid) {
      return get(/databases/$(database)/documents/users/$(uid)).data.role in ['admin', 'moderator'];
    }
    
    function validatePostData(data) {
      return data.title is string && data.title.size() <= 100 &&
             data.content is string && data.content.size() <= 10000 &&
             data.category is string &&
             data.boardType is string;
    }
    
    function validateCommentData(data) {
      return data.content is string && data.content.size() <= 1000 &&
             data.postId is string;
    }

    // 소음 기록 데이터 검증 함수 (업데이트)
    function validateNoiseRecordData(data) {
      return data.userId is string &&
             data.fileName is string && data.fileName.size() <= 100 &&
             data.measurements is map &&
             data.measurements.keys().hasAll(['maxDecibel', 'avgDecibel', 'minDecibel', 'duration']) &&
             data.location is map &&
             data.location.keys().hasAll(['coordinates', 'address']) &&
             data.deviceInfo is map &&
             data.sharing is map &&
             data.sharing.keys().hasAll(['isPublic', 'allowDownload']) &&
             validateDecibelRange(data.measurements);
    }
    
    // 소음 기록 업데이트 검증 함수 (신규)
    function validateNoiseRecordUpdate(oldData, newData) {
      // 측정 데이터는 수정 불가
      return oldData.measurements == newData.measurements &&
             oldData.location.coordinates == newData.location.coordinates &&
             oldData.recordedAt == newData.recordedAt;
    }
    
    // 데시벨 범위 검증 함수 (신규)
    function validateDecibelRange(measurements) {
      return measurements.maxDecibel >= 0 && measurements.maxDecibel <= 200 &&
             measurements.avgDecibel >= 0 && measurements.avgDecibel <= 200 &&
             measurements.minDecibel >= 0 && measurements.minDecibel <= 200 &&
             measurements.avgDecibel <= measurements.maxDecibel &&
             measurements.minDecibel <= measurements.avgDecibel;
    }
  }
}
```

## 7. 백업 및 복구 전략

### 7.1 자동 백업 설정 (업데이트)
```javascript
// Cloud Functions - 자동 백업
exports.scheduledBackup = functions.pubsub
  .schedule('0 2 * * *') // 매일 오전 2시
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    const projectId = process.env.GCP_PROJECT;
    const timestamp = new Date().toISOString().split('T')[0];
    
    // Firestore 백업 (소음 기록 포함)
    const firestoreBackup = await gcs.bucket(`${projectId}-firestore-backup`);
    
    // BigQuery 백업 (소음 데이터 포함)
    const bigqueryBackup = await bigquery
      .dataset('noisebattle')
      .table('noise_records')
      .export(`gs://${projectId}-bigquery-backup/noise_records-${timestamp}.json`);
      
    // Storage 백업 (오디오 파일)
    const audioFilesBackup = await backupAudioFiles(timestamp);
      
    console.log('Backup completed successfully');
  });

// 오디오 파일 백업 함수 (신규)
async function backupAudioFiles(timestamp) {
  const { Storage } = require('@google-cloud/storage');
  const storage = new Storage();
  
  const sourceBucket = storage.bucket();
  const backupBucket = storage.bucket(`${process.env.GCP_PROJECT}-audio-backup`);
  
  // noise_records 폴더의 모든 오디오 파일 백업
  const [files] = await sourceBucket.getFiles({
    prefix: 'noise_records/',
    delimiter: '/'
  });
  
  const backupPromises = files.map(async (file) => {
    const backupFileName = `${timestamp}/${file.name}`;
    return file.copy(backupBucket.file(backupFileName));
  });
  
  await Promise.all(backupPromises);
  console.log(`Backed up ${files.length} audio files`);
}
```

### 7.2 데이터 복구 절차 (업데이트)
1. **Firestore 복구**: Firebase Console에서 백업 선택 후 복구
2. **BigQuery 복구**: 백업 파일에서 테이블 재생성
3. **Storage 복구**: 오디오 파일 백업에서 복구
4. **인덱스 재구축**: 복구 후 필요한 인덱스 재생성
5. **통계 데이터 재계산**: Cloud Functions 트리거로 통계 재계산

## 8. 모니터링 및 최적화

### 8.1 성능 모니터링 (업데이트)
- **읽기/쓰기 작업 모니터링**: Firebase Console
- **쿼리 성능 분석**: BigQuery 쿼리 실행 계획
- **인덱스 사용률 추적**: Firestore 인덱스 분석
- **Storage 사용량 모니터링**: 오디오 파일 용량 추적
- **비용 모니터링**: GCP 청구 알림 설정

### 8.2 최적화 전략 (업데이트)
- **인덱스 최적화**: 자주 사용되는 쿼리 패턴 분석
- **배치 작업**: 여러 문서 업데이트 시 batch 사용
- **캐싱**: 자주 조회되는 통계 데이터 Redis 캐싱
- **페이지네이션**: 대용량 데이터 조회 시 커서 기반 페이지네이션
- **오디오 파일 압축**: 업로드 시 자동 압축으로 용량 최적화
- **CDN 활용**: 오디오 파일 및 썸네일 전송 최적화

### 8.3 데이터 정리 정책 (신규)
```javascript
// 데이터 정리 Cloud Function
exports.cleanupOldData = functions.pubsub
  .schedule('0 3 * * 0') // 매주 일요일 오전 3시
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    // 1. 90일 이상 된 미처리 소음 기록 삭제
    await cleanupUnprocessedRecords();
    
    // 2. 6개월 이상 된 삭제된 기록들 완전 삭제
    await permanentDeleteOldRecords();
    
    // 3. 사용자별 Storage 할당량 확인
    await checkUserStorageQuotas();
    
    // 4. 임시 파일 정리
    await cleanupTemporaryFiles();
  });

async function cleanupUnprocessedRecords() {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - 90);
  
  const unprocessedQuery = await firestore
    .collection('noise_records')
    .where('isProcessed', '==', false)
    .where('createdAt', '<', cutoffDate)
    .get();
  
  const batch = firestore.batch();
  unprocessedQuery.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`Cleaned up ${unprocessedQuery.size} unprocessed records`);
}

async function checkUserStorageQuotas() {
  const users = await firestore.collection('users').get();
  const storageLimit = 500 * 1024 * 1024; // 500MB per user
  
  for (const userDoc of users.docs) {
    const userId = userDoc.id;
    const userData = userDoc.data();
    
    if (userData.storage?.totalSizeBytes > storageLimit) {
      // 사용자에게 알림 전송
      await firestore.collection('notifications').add({
        userId,
        type: 'storage_quota_exceeded',
        title: '저장 공간 부족',
        message: '저장 공간이 부족합니다. 오래된 녹음 파일을 정리해주세요.',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  }
}
```

이 데이터베이스 설계는 frontend.md, backend.md, security.md와 연계하여 확장 가능한 소음 모니터링 플랫폼을 구축합니다. 