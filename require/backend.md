# Backend 개발 계획서

> **Project:** 소음과 전쟁 - Firebase 백엔드 설정 및 구현 가이드

## 1. Firebase 프로젝트 설정

### 1.1 Firebase 프로젝트 생성
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init

# 프로젝트 구조 선택
? Which Firebase CLI features do you want to set up for this directory?
 ◉ Firestore: Deploy security rules and create indexes
 ◉ Functions: Configure and deploy Cloud Functions
 ◉ Hosting: Configure and deploy Firebase Hosting sites
 ◉ Storage: Deploy Cloud Storage security rules
 ◉ Emulators: Set up local emulators for Firebase features

# 프로젝트 선택 또는 생성
? Please select an option: Create a new project
? Project name: noisebattle
? Project ID: noisebattle-app
```

### 1.2 Firebase 프로젝트 구성
```
noisebattle-firebase/
├── .firebaserc
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── functions/
│   ├── package.json
│   ├── index.js
│   ├── src/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── posts/
│   │   ├── notifications/
│   │   ├── noise_records/    # 소음 녹음 처리
│   │   └── analytics/
│   └── .env
├── hosting/
│   └── public/
└── emulators/
```

### 1.3 Firebase 환경 설정
```json
// firebase.json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": {
    "predeploy": "npm --prefix \"$RESOURCE_DIR\" run build",
    "source": "functions",
    "runtime": "nodejs18",
    "region": "asia-northeast3"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "hosting": {
    "public": "hosting/public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
  },
  "emulators": {
    "functions": {
      "port": 5001
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

## 2. Authentication 설정

### 2.1 인증 제공업체 활성화
```javascript
// Firebase Console에서 설정할 인증 제공업체
// Authentication > Sign-in method에서 활성화

// 1. 이메일/비밀번호 인증
// 2. Google 로그인
// 3. 카카오 로그인 (Custom Token 사용)
// 4. 네이버 로그인 (Custom Token 사용)
// 5. 휴대폰 번호 인증
```

### 2.2 Authentication 관련 Cloud Functions
```javascript
// functions/src/auth/authFunctions.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { getAuth } = require('firebase-admin/auth');

// 사용자 계정 생성 시 자동 실행
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName, photoURL } = user;
  
  try {
    // Firestore에 사용자 프로필 생성
    await admin.firestore().collection('users').doc(uid).set({
      uid,
      email,
      nickname: displayName || '익명사용자',
      profileImageUrl: photoURL,
      isVerified: false,
      isApartmentVerified: false,
      apartmentInfo: null,
      socialLogins: {},
      preferences: {
        pushNotifications: true,
        emailNotifications: true,
        locationSharing: false
      },
      statistics: {
        postCount: 0,
        commentCount: 0,
        likeCount: 0,
        reportCount: 0,
        noiseRecordCount: 0  // 소음 녹음 횟수 추가
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      isBlocked: false,
      role: 'user'
    });
    
    console.log(`User profile created for ${uid}`);
  } catch (error) {
    console.error('Error creating user profile:', error);
  }
});

// 사용자 계정 삭제 시 자동 실행
exports.deleteUserProfile = functions.auth.user().onDelete(async (user) => {
  const { uid } = user;
  
  try {
    // 사용자 관련 데이터 삭제 (소음 녹음 파일 포함)
    await deleteUserData(uid);
    console.log(`User data deleted for ${uid}`);
  } catch (error) {
    console.error('Error deleting user data:', error);
  }
});

// 휴대폰 번호 인증
exports.verifyPhoneNumber = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    const { phoneNumber, verificationCode } = data;
    
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }
    
    try {
      // 휴대폰 번호 검증 로직 (KG모빌리언스 API 연동)
      const isValid = await verifyWithKGMobiliance(phoneNumber, verificationCode);
      
      if (isValid) {
        // 사용자 정보 업데이트
        await admin.firestore().collection('users').doc(context.auth.uid).update({
          phoneNumber,
          isVerified: true,
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        
        return { success: true, message: '휴대폰 번호 인증이 완료되었습니다.' };
      } else {
        throw new functions.https.HttpsError('invalid-argument', '인증 코드가 올바르지 않습니다.');
      }
    } catch (error) {
      console.error('Phone verification error:', error);
      throw new functions.https.HttpsError('internal', '인증 처리 중 오류가 발생했습니다.');
    }
  });

// 소셜 로그인 연동
exports.linkSocialLogin = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    const { provider, socialId, email } = data;
    
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }
    
    try {
      const userRef = admin.firestore().collection('users').doc(context.auth.uid);
      
      await userRef.update({
        [`socialLogins.${provider}`]: {
          id: socialId,
          email: email,
          linkedAt: admin.firestore.FieldValue.serverTimestamp()
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      return { success: true, message: `${provider} 계정이 연동되었습니다.` };
    } catch (error) {
      console.error('Social login linking error:', error);
      throw new functions.https.HttpsError('internal', '소셜 로그인 연동 중 오류가 발생했습니다.');
    }
  });

// 사용자 데이터 삭제 함수
async function deleteUserData(uid) {
  const batch = admin.firestore().batch();
  
  // 사용자 문서 삭제
  const userRef = admin.firestore().collection('users').doc(uid);
  batch.delete(userRef);
  
  // 게시글 삭제
  const postsSnapshot = await admin.firestore()
    .collection('posts')
    .where('userId', '==', uid)
    .get();
  
  postsSnapshot.forEach(doc => batch.delete(doc.ref));
  
  // 댓글 삭제
  const commentsSnapshot = await admin.firestore()
    .collection('comments')
    .where('userId', '==', uid)
    .get();
  
  commentsSnapshot.forEach(doc => batch.delete(doc.ref));

  // 소음 녹음 기록 삭제
  const noiseRecordsSnapshot = await admin.firestore()
    .collection('noise_records')
    .where('userId', '==', uid)
    .get();
  
  noiseRecordsSnapshot.forEach(doc => batch.delete(doc.ref));
  
  // 알림 삭제
  const notificationsSnapshot = await admin.firestore()
    .collection('notifications')
    .where('userId', '==', uid)
    .get();
  
  notificationsSnapshot.forEach(doc => batch.delete(doc.ref));
  
  await batch.commit();

  // Storage에서 사용자 파일들 삭제
  await deleteUserFiles(uid);
}

// 사용자 Storage 파일 삭제 함수
async function deleteUserFiles(uid) {
  const { Storage } = require('@google-cloud/storage');
  const storage = new Storage();
  const bucket = storage.bucket();

  // 사용자 관련 폴더들 삭제
  const folders = [
    `profiles/${uid}/`,
    `noise_records/${uid}/`,
    `verification/${uid}/`
  ];

  for (const folder of folders) {
    try {
      const [files] = await bucket.getFiles({ prefix: folder });
      for (const file of files) {
        await file.delete();
        console.log(`Deleted file: ${file.name}`);
      }
    } catch (error) {
      console.error(`Error deleting files in ${folder}:`, error);
    }
  }
}

// KG모빌리언스 API 연동 함수
async function verifyWithKGMobiliance(phoneNumber, verificationCode) {
  // 실제 구현 시 KG모빌리언스 API 호출
  // 여기서는 예시로 간단한 검증 로직
  return verificationCode === '123456'; // 실제로는 API 응답 처리
}
```

### 2.3 인증 보안 설정
```javascript
// functions/src/auth/authSecurity.js
const admin = require('firebase-admin');
const rateLimit = require('express-rate-limit');

// 로그인 시도 제한
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15분
  max: 5, // 최대 5회 시도
  message: '로그인 시도 횟수를 초과했습니다. 15분 후 다시 시도해주세요.',
  standardHeaders: true,
  legacyHeaders: false,
});

// 계정 잠금 시스템
async function checkAccountLock(uid) {
  const userDoc = await admin.firestore().collection('users').doc(uid).get();
  const userData = userDoc.data();
  
  if (userData.isBlocked) {
    throw new functions.https.HttpsError('permission-denied', '계정이 잠금되었습니다.');
  }
  
  return userData;
}

// 의심스러운 활동 감지
async function detectSuspiciousActivity(uid, activity) {
  const suspiciousActivities = [
    'multiple_login_attempts',
    'rapid_api_calls',
    'unusual_location'
  ];
  
  if (suspiciousActivities.includes(activity)) {
    await admin.firestore().collection('security_logs').add({
      userId: uid,
      activity,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      ipAddress: context.rawRequest.ip,
      userAgent: context.rawRequest.headers['user-agent']
    });
    
    // 심각한 경우 계정 임시 잠금
    if (activity === 'multiple_login_attempts') {
      await admin.firestore().collection('users').doc(uid).update({
        isBlocked: true,
        blockedReason: '의심스러운 로그인 활동',
        blockedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  }
}

module.exports = {
  loginLimiter,
  checkAccountLock,
  detectSuspiciousActivity
};
```

## 3. Firestore 데이터베이스 설정

### 3.1 보안 규칙 설정
```javascript
// firestore.rules
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
    
    // 소음 기록 규칙 (업데이트됨)
    match /noise_records/{recordId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                    request.auth.uid == resource.data.userId &&
                    validateNoiseRecordData(resource.data);
      allow update, delete: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
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

    // 소음 기록 데이터 검증 함수 (신규)
    function validateNoiseRecordData(data) {
      return data.userId is string &&
             data.fileName is string && data.fileName.size() <= 100 &&
             data.measurements is map &&
             data.measurements.keys().hasAll(['maxDecibel', 'avgDecibel', 'minDecibel', 'duration']) &&
             data.location is map &&
             data.location.keys().hasAll(['coordinates', 'address']);
    }
  }
}
```

### 3.2 인덱스 설정
```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "boardType", "order": "ASCENDING" },
        { "fieldPath": "isDeleted", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "boardType", "order": "ASCENDING" },
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "location.sido", "order": "ASCENDING" },
        { "fieldPath": "location.sigungu", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "apartmentId", "order": "ASCENDING" },
        { "fieldPath": "isDeleted", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "engagement.trendingScore", "order": "DESCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "comments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "postId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "noise_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "recordedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "noise_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "location.address.sido", "order": "ASCENDING" },
        { "fieldPath": "location.address.sigungu", "order": "ASCENDING" },
        { "fieldPath": "recordedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "noise_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "apartmentId", "order": "ASCENDING" },
        { "fieldPath": "recordedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "noise_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "measurements.maxDecibel", "order": "DESCENDING" },
        { "fieldPath": "recordedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "isRead", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

### 3.3 데이터 트리거 함수
```javascript
// functions/src/firestore/triggers.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 게시글 생성 시 트리거
exports.onPostCreate = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const postId = context.params.postId;
    
    try {
      // 1. 사용자 통계 업데이트
      await admin.firestore().collection('users').doc(post.userId).update({
        'statistics.postCount': admin.firestore.FieldValue.increment(1),
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });
      
      // 2. 아파트 통계 업데이트 (아파트 ID가 있는 경우)
      if (post.apartmentId) {
        await updateApartmentStats(post.apartmentId);
      }
      
      // 3. 지역 통계 업데이트
      if (post.location) {
        await updateRegionStats(post.location);
      }
      
      // 4. 콘텐츠 모더레이션
      await moderateContent(postId, post.content);
      
      // 5. 빅데이터 분석용 데이터 전송
      await exportToBigQuery('posts', postId, post);
      
      console.log(`Post created: ${postId}`);
    } catch (error) {
      console.error('Error in onPostCreate:', error);
    }
  });

// 게시글 업데이트 시 트리거
exports.onPostUpdate = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const postId = context.params.postId;
    
    try {
      // 좋아요 수 변경 시 처리
      if (before.metrics.likeCount !== after.metrics.likeCount) {
        await updateEngagementScore(postId, after.metrics);
      }
      
      // 댓글 수 변경 시 처리
      if (before.metrics.commentCount !== after.metrics.commentCount) {
        await updateEngagementScore(postId, after.metrics);
      }
      
      // 게시글 삭제 시 처리
      if (!before.isDeleted && after.isDeleted) {
        await handlePostDeletion(postId, after.userId);
      }
      
      console.log(`Post updated: ${postId}`);
    } catch (error) {
      console.error('Error in onPostUpdate:', error);
    }
  });

// 댓글 생성 시 트리거
exports.onCommentCreate = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const commentId = context.params.commentId;
    
    try {
      // 1. 게시글 댓글 수 증가
      await admin.firestore().collection('posts').doc(comment.postId).update({
        'metrics.commentCount': admin.firestore.FieldValue.increment(1),
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });
      
      // 2. 사용자 통계 업데이트
      await admin.firestore().collection('users').doc(comment.userId).update({
        'statistics.commentCount': admin.firestore.FieldValue.increment(1),
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });
      
      // 3. 게시글 작성자에게 알림 전송
      await sendCommentNotification(comment.postId, comment.userId);
      
      // 4. 콘텐츠 모더레이션
      await moderateContent(commentId, comment.content);
      
      console.log(`Comment created: ${commentId}`);
    } catch (error) {
      console.error('Error in onCommentCreate:', error);
    }
  });

// 소음 기록 생성 시 트리거 (업데이트됨)
exports.onNoiseRecordCreate = functions.firestore
  .document('noise_records/{recordId}')
  .onCreate(async (snap, context) => {
    const record = snap.data();
    const recordId = context.params.recordId;
    
    try {
      // 1. 사용자 통계 업데이트 (소음 기록 횟수 증가)
      await admin.firestore().collection('users').doc(record.userId).update({
        'statistics.noiseRecordCount': admin.firestore.FieldValue.increment(1),
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });

      // 2. 지역별 소음 통계 업데이트
      if (record.location) {
        await updateRegionNoiseStats(record.location, record.measurements);
      }
      
      // 3. 아파트별 소음 통계 업데이트
      if (record.apartmentId) {
        await updateApartmentNoiseStats(record.apartmentId, record.measurements);
      }
      
      // 4. 빅데이터 분석용 데이터 전송
      await exportToBigQuery('noise_records', recordId, record);

      // 5. 자동으로 썸네일 및 오디오 분석 트리거
      if (record.audioFileUrl) {
        await processAudioFile(recordId, record.audioFileUrl);
      }
      
      console.log(`Noise record created: ${recordId}`);
    } catch (error) {
      console.error('Error in onNoiseRecordCreate:', error);
    }
  });

// 소음 기록 오디오 파일 처리 함수 (신규)
async function processAudioFile(recordId, audioFileUrl) {
  try {
    // 오디오 파일 메타데이터 추출
    const audioMetadata = await extractAudioMetadata(audioFileUrl);
    
    // FFT 분석을 통한 주파수 분석 (선택적)
    const frequencyAnalysis = await analyzeAudioFrequency(audioFileUrl);
    
    // 소음 기록에 분석 결과 추가
    await admin.firestore().collection('noise_records').doc(recordId).update({
      audioMetadata: audioMetadata,
      frequencyAnalysis: frequencyAnalysis,
      processedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`Audio processing completed for record: ${recordId}`);
  } catch (error) {
    console.error('Error processing audio file:', error);
  }
}

// 오디오 메타데이터 추출 함수 (신규)
async function extractAudioMetadata(audioFileUrl) {
  const ffmpeg = require('fluent-ffmpeg');
  const path = require('path');
  const os = require('os');
  const fs = require('fs');
  
  const bucketObj = storage.bucket(audioFileUrl.split('://')[1].split('/')[0]);
  const fileName = audioFileUrl.split('/').pop();
  const tempFilePath = path.join(os.tmpdir(), path.basename(fileName));
  
  // 파일 다운로드
  await bucketObj.file(fileName).download({ destination: tempFilePath });
  
  return new Promise((resolve, reject) => {
    ffmpeg.ffprobe(tempFilePath, (err, metadata) => {
      fs.unlinkSync(tempFilePath); // 임시 파일 삭제
      
      if (err) {
        reject(err);
        return;
      }
      
      const audioStream = metadata.streams.find(stream => stream.codec_type === 'audio');
      
      resolve({
        duration: parseFloat(metadata.format.duration || 0),
        bitrate: parseInt(metadata.format.bit_rate || 0),
        sampleRate: parseInt(audioStream?.sample_rate || 0),
        channels: parseInt(audioStream?.channels || 0),
        codec: audioStream?.codec_name || 'unknown',
        size: parseInt(metadata.format.size || 0)
      });
    });
  });
}

// 오디오 품질 검증 함수 (신규)
async function validateAudioQuality(bucket, fileName) {
  const metadata = await extractAudioMetadata(bucket, fileName);
  
  // 최소 품질 요구사항 검증
  const requirements = {
    minDuration: 1, // 최소 1초
    maxDuration: 300, // 최대 5분
    minSampleRate: 8000, // 최소 8kHz
    maxFileSize: 50 * 1024 * 1024 // 최대 50MB
  };
  
  if (metadata.duration < requirements.minDuration || 
      metadata.duration > requirements.maxDuration ||
      metadata.sampleRate < requirements.minSampleRate ||
      metadata.size > requirements.maxFileSize) {
    
    // 품질 요구사항 미달 시 파일 삭제 및 사용자 알림
    const bucketObj = storage.bucket(bucket);
    await bucketObj.file(fileName).delete();
    
    // 사용자에게 오류 알림 전송
    const userId = fileName.split('/')[1];
    await admin.firestore().collection('notifications').add({
      userId,
      type: 'audio_processing_error',
      title: '오디오 파일 처리 오류',
      message: '업로드한 오디오 파일이 품질 요구사항을 만족하지 않습니다.',
      data: { fileName, reason: 'quality_requirements_not_met' },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    throw new Error('Audio quality requirements not met');
  }
  
  return metadata;
}

// 오디오 주파수 분석 함수 (신규)
async function analyzeAudioFrequency(audioFileUrl) {
  // Web Audio API 또는 전문 오디오 분석 라이브러리 사용
  // 여기서는 예시 데이터 반환
  return {
    dominantFrequency: 1000, // Hz
    frequencySpectrum: [], // 주파수 스펙트럼 배열
    noiseType: 'mechanical', // 'human', 'mechanical', 'ambient' 등
    confidence: 0.8
  };
}

// 헬퍼 함수들
async function updateApartmentStats(apartmentId) {
  const apartmentRef = admin.firestore().collection('apartments').doc(apartmentId);
  
  // 해당 아파트의 게시글 수 계산
  const postsSnapshot = await admin.firestore()
    .collection('posts')
    .where('apartmentId', '==', apartmentId)
    .where('isDeleted', '==', false)
    .get();
  
  await apartmentRef.update({
    'totalPosts': postsSnapshot.size,
    'updatedAt': admin.firestore.FieldValue.serverTimestamp()
  });
}

async function updateRegionStats(location) {
  // 지역별 통계 업데이트 로직
  const regionKey = `${location.sido}_${location.sigungu}_${location.eupmyeondong}`;
  const regionRef = admin.firestore().collection('region_stats').doc(regionKey);
  
  await regionRef.set({
    sido: location.sido,
    sigungu: location.sigungu,
    eupmyeondong: location.eupmyeondong,
    postCount: admin.firestore.FieldValue.increment(1),
    lastUpdated: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });
}

// 지역별 소음 통계 업데이트 함수 (업데이트됨)
async function updateRegionNoiseStats(location, measurements) {
  const regionKey = `${location.address.sido}_${location.address.sigungu}_${location.address.eupmyeondong}`;
  const regionRef = admin.firestore().collection('region_noise_stats').doc(regionKey);
  
  const currentStats = await regionRef.get();
  const data = currentStats.exists ? currentStats.data() : {
    totalRecords: 0,
    avgDecibel: 0,
    maxDecibel: 0,
    totalDecibel: 0
  };
  
  const newTotalRecords = data.totalRecords + 1;
  const newTotalDecibel = data.totalDecibel + measurements.avgDecibel;
  const newAvgDecibel = newTotalDecibel / newTotalRecords;
  const newMaxDecibel = Math.max(data.maxDecibel, measurements.maxDecibel);
  
  await regionRef.set({
    sido: location.address.sido,
    sigungu: location.address.sigungu,
    eupmyeondong: location.address.eupmyeondong,
    totalRecords: newTotalRecords,
    avgDecibel: newAvgDecibel,
    maxDecibel: newMaxDecibel,
    totalDecibel: newTotalDecibel,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp()
  });
}

// 아파트별 소음 통계 업데이트 함수 (업데이트됨)
async function updateApartmentNoiseStats(apartmentId, measurements) {
  const apartmentRef = admin.firestore().collection('apartments').doc(apartmentId);
  
  const currentApartment = await apartmentRef.get();
  const apartmentData = currentApartment.data();
  
  const currentStats = apartmentData?.noiseStatistics || {
    totalReports: 0,
    avgNoiseLevel: 0,
    maxNoiseLevel: 0,
    totalDecibel: 0
  };
  
  const newTotalReports = currentStats.totalReports + 1;
  const newTotalDecibel = currentStats.totalDecibel + measurements.avgDecibel;
  const newAvgNoiseLevel = newTotalDecibel / newTotalReports;
  const newMaxNoiseLevel = Math.max(currentStats.maxNoiseLevel, measurements.maxDecibel);
  
  // 소음 지수 재계산
  const noiseIndex = calculateNoiseIndex(newTotalReports, newAvgNoiseLevel, newMaxNoiseLevel);
  
  await apartmentRef.update({
    'noiseStatistics.totalReports': newTotalReports,
    'noiseStatistics.avgNoiseLevel': newAvgNoiseLevel,
    'noiseStatistics.maxNoiseLevel': newMaxNoiseLevel,
    'noiseStatistics.totalDecibel': newTotalDecibel,
    'noiseStatistics.noiseIndex': noiseIndex,
    'noiseStatistics.lastReportAt': admin.firestore.FieldValue.serverTimestamp(),
    'updatedAt': admin.firestore.FieldValue.serverTimestamp()
  });
}

// 소음 지수 계산 함수
function calculateNoiseIndex(reportCount, avgNoise, maxNoise) {
  const reportWeight = Math.min(reportCount / 10, 1) * 30; // 리포트 수 가중치 (최대 30점)
  const avgNoiseWeight = Math.min(avgNoise / 100, 1) * 40; // 평균 소음 가중치 (최대 40점)
  const maxNoiseWeight = Math.min(maxNoise / 120, 1) * 30; // 최고 소음 가중치 (최대 30점)
  
  return Math.round(reportWeight + avgNoiseWeight + maxNoiseWeight);
}

async function moderateContent(docId, content) {
  const moderationResult = await callContentModerationAPI(content);
  
  if (moderationResult.isInappropriate) {
    // 부적절한 콘텐츠 처리
    await admin.firestore().collection('moderation_queue').add({
      docId,
      content,
      reason: moderationResult.reason,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }
}

async function updateEngagementScore(postId, metrics) {
  const engagementScore = calculateEngagementScore(metrics);
  
  await admin.firestore().collection('posts').doc(postId).update({
    'engagement.score': engagementScore,
    'engagement.lastEngagementAt': admin.firestore.FieldValue.serverTimestamp()
  });
}

async function sendCommentNotification(postId, commenterId) {
  const postDoc = await admin.firestore().collection('posts').doc(postId).get();
  const post = postDoc.data();
  
  if (post.userId !== commenterId) {
    await admin.firestore().collection('notifications').add({
      userId: post.userId,
      type: 'comment',
      title: '새 댓글',
      message: '내 게시글에 댓글이 달렸습니다.',
      data: {
        postId,
        commenterId
      },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }
}

async function handlePostDeletion(postId, userId) {
  // 게시글 삭제 시 관련 데이터 정리
  const batch = admin.firestore().batch();
  
  // 관련 댓글 삭제
  const commentsSnapshot = await admin.firestore()
    .collection('comments')
    .where('postId', '==', postId)
    .get();
  
  commentsSnapshot.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  // 관련 알림 삭제
  const notificationsSnapshot = await admin.firestore()
    .collection('notifications')
    .where('data.postId', '==', postId)
    .get();
  
  notificationsSnapshot.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
}

function calculateEngagementScore(metrics) {
  const { likeCount, commentCount, viewCount, shareCount } = metrics;
  return (likeCount * 2) + (commentCount * 3) + (viewCount * 0.1) + (shareCount * 5);
}

async function callContentModerationAPI(content) {
  // 콘텐츠 모더레이션 API 호출
  // 실제 구현 시 Google Cloud Natural Language API 등 사용
  return { isInappropriate: false, reason: '' };
}

async function exportToBigQuery(collection, docId, data) {
  // BigQuery로 데이터 내보내기
  const { BigQuery } = require('@google-cloud/bigquery');
  const bigquery = new BigQuery();
  
  const datasetId = 'noisebattle';
  const tableId = collection;
  
  const row = {
    document_id: docId,
    data: JSON.stringify(data),
    timestamp: new Date().toISOString()
  };
  
  await bigquery.dataset(datasetId).table(tableId).insert([row]);
}
```

## 4. Cloud Storage 설정

### 4.1 Storage 보안 규칙 (업데이트됨)
```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 프로필 이미지 업로드
    match /profiles/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   isImageFile(fileName) &&
                   request.resource.size < 5 * 1024 * 1024; // 5MB 제한
    }
    
    // 게시글 이미지 업로드
    match /posts/{postId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                   isImageFile(fileName) &&
                   request.resource.size < 10 * 1024 * 1024; // 10MB 제한
    }
    
    // 소음 녹음 파일 업로드 (업데이트됨)
    match /noise_records/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                   request.auth.uid == userId &&
                   isAudioFile(fileName) &&
                   request.resource.size < 50 * 1024 * 1024; // 50MB 제한
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // 아파트 인증 서류 (임시)
    match /verification/{userId}/{fileName} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   isDocumentFile(fileName) &&
                   request.resource.size < 20 * 1024 * 1024; // 20MB 제한
    }
    
    // 헬퍼 함수들
    function isImageFile(fileName) {
      return fileName.matches('.*\\.(jpg|jpeg|png|gif|webp)$');
    }
    
    function isAudioFile(fileName) {
      return fileName.matches('.*\\.(mp3|wav|m4a|aac|opus|ogg)$');
    }
    
    function isDocumentFile(fileName) {
      return fileName.matches('.*\\.(jpg|jpeg|png|pdf)$');
    }
  }
}
```

### 4.2 파일 업로드 및 관리 함수 (업데이트됨)
```javascript
// functions/src/storage/storageFunctions.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');
const vision = require('@google-cloud/vision');

const storage = new Storage();
const visionClient = new vision.ImageAnnotatorClient();

// 이미지 업로드 후 처리
exports.processImage = functions.storage
  .object()
  .onFinalize(async (object) => {
    const { name, bucket, contentType } = object;
    
    if (!contentType.startsWith('image/')) {
      console.log('Not an image file, skipping processing');
      return;
    }
    
    try {
      // 1. 이미지 리사이징
      await resizeImage(bucket, name);
      
      // 2. 썸네일 생성
      await generateThumbnail(bucket, name);
      
      // 3. 안전하지 않은 콘텐츠 검사
      await checkSafeContent(bucket, name);
      
      console.log(`Image processed: ${name}`);
    } catch (error) {
      console.error('Error processing image:', error);
    }
  });

// 오디오 파일 업로드 후 처리 (신규)
exports.processAudioFile = functions.storage
  .object()
  .onFinalize(async (object) => {
    const { name, bucket, contentType } = object;
    
    if (!contentType.startsWith('audio/')) {
      console.log('Not an audio file, skipping processing');
      return;
    }
    
    // 소음 녹음 파일만 처리
    if (!name.includes('noise_records/')) {
      return;
    }
    
    try {
      // 1. 오디오 메타데이터 추출
      const metadata = await extractAudioMetadata(bucket, name);
      
      // 2. 오디오 품질 검증
      await validateAudioQuality(bucket, name);
      
      // 3. 썸네일(스펙트로그램) 생성
      await generateAudioThumbnail(bucket, name);
      
      // 4. 파일 정보를 Firestore에 업데이트
      await updateNoiseRecordFileInfo(name, metadata);
      
      console.log(`Audio file processed: ${name}`);
    } catch (error) {
      console.error('Error processing audio file:', error);
    }
  });

// 아파트 인증 서류 OCR 처리
exports.processVerificationDocument = functions.storage
  .object()
  .onFinalize(async (object) => {
    const { name, bucket } = object;
    
    if (!name.includes('verification/')) {
      return;
    }
    
    try {
      // 1. OCR 처리
      const extractedText = await extractTextFromImage(bucket, name);
      
      // 2. 주소 정보 추출
      const addressInfo = extractAddressInfo(extractedText);
      
      // 3. 사용자 정보 업데이트
      const userId = name.split('/')[1];
      await updateUserVerificationStatus(userId, addressInfo);
      
      // 4. 임시 파일 삭제
      await deleteTemporaryFile(bucket, name);
      
      console.log(`Verification document processed: ${name}`);
    } catch (error) {
      console.error('Error processing verification document:', error);
    }
  });

// 파일 삭제 시 처리
exports.cleanupOnDelete = functions.storage
  .object()
  .onDelete(async (object) => {
    const { name } = object;
    
    try {
      // 관련 썸네일 삭제
      if (name.includes('posts/') || name.includes('profiles/') || name.includes('noise_records/')) {
        await deleteRelatedThumbnails(name);
      }
      
      // 데이터베이스에서 파일 참조 제거
      await removeFileReferences(name);
      
      console.log(`File cleanup completed: ${name}`);
    } catch (error) {
      console.error('Error in file cleanup:', error);
    }
  });

// 이미지 리사이징 함수
async function resizeImage(bucket, fileName) {
  const sharp = require('sharp');
  const path = require('path');
  const os = require('os');
  const fs = require('fs');
  
  const bucketObj = storage.bucket(bucket);
  const file = bucketObj.file(fileName);
  const tempFilePath = path.join(os.tmpdir(), path.basename(fileName));
  const resizedFilePath = path.join(os.tmpdir(), `resized_${path.basename(fileName)}`);
  
  // 원본 파일 다운로드
  await file.download({ destination: tempFilePath });
  
  // 리사이징 (최대 1920x1080)
  await sharp(tempFilePath)
    .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 80 })
    .toFile(resizedFilePath);
  
  // 리사이징된 파일 업로드
  const resizedFileName = `resized/${fileName}`;
  await bucketObj.upload(resizedFilePath, { destination: resizedFileName });
  
  // 임시 파일 삭제
  fs.unlinkSync(tempFilePath);
  fs.unlinkSync(resizedFilePath);
}

// 썸네일 생성 함수
async function generateThumbnail(bucket, fileName) {
  const sharp = require('sharp');
  const path = require('path');
  const os = require('os');
  const fs = require('fs');
  
  const bucketObj = storage.bucket(bucket);
  const file = bucketObj.file(fileName);
  const tempFilePath = path.join(os.tmpdir(), path.basename(fileName));
  const thumbnailPath = path.join(os.tmpdir(), `thumb_${path.basename(fileName)}`);
  
  // 원본 파일 다운로드
  await file.download({ destination: tempFilePath });
  
  // 썸네일 생성 (300x300)
  await sharp(tempFilePath)
    .resize(300, 300, { fit: 'cover' })
    .jpeg({ quality: 60 })
    .toFile(thumbnailPath);
  
  // 썸네일 업로드
  const thumbnailFileName = `thumbnails/${fileName}`;
  await bucketObj.upload(thumbnailPath, { destination: thumbnailFileName });
  
  // 임시 파일 삭제
  fs.unlinkSync(tempFilePath);
  fs.unlinkSync(thumbnailPath);
}

// 안전하지 않은 콘텐츠 검사
async function checkSafeContent(bucket, fileName) {
  const [result] = await visionClient.safeSearchDetection(`gs://${bucket}/${fileName}`);
  const safeSearch = result.safeSearchAnnotation;
  
  if (safeSearch.adult === 'VERY_LIKELY' || 
      safeSearch.violence === 'VERY_LIKELY' || 
      safeSearch.racy === 'VERY_LIKELY') {
    
    // 부적절한 이미지 삭제
    await storage.bucket(bucket).file(fileName).delete();
    
    // 관리자에게 알림
    await admin.firestore().collection('moderation_alerts').add({
      type: 'inappropriate_image',
      fileName,
      safeSearch,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }
}

// OCR 텍스트 추출
async function extractTextFromImage(bucket, fileName) {
  const [result] = await visionClient.textDetection(`gs://${bucket}/${fileName}`);
  const detections = result.textAnnotations;
  
  if (detections.length > 0) {
    return detections[0].description;
  }
  
  return '';
}

// 주소 정보 추출
function extractAddressInfo(text) {
  const addressPatterns = [
    /([가-힣]+[시도])\s+([가-힣]+[시군구])\s+([가-힣]+[읍면동])/,
    /([가-힣]+아파트)/,
    /(\d+동\s+\d+호)/
  ];
  
  const extractedInfo = {};
  
  for (const pattern of addressPatterns) {
    const match = text.match(pattern);
    if (match) {
      if (pattern.source.includes('시도')) {
        extractedInfo.address = match[0];
      } else if (pattern.source.includes('아파트')) {
        extractedInfo.apartmentName = match[0];
      } else if (pattern.source.includes('동')) {
        extractedInfo.unit = match[0];
      }
    }
  }
  
  return extractedInfo;
}

// 사용자 인증 상태 업데이트
async function updateUserVerificationStatus(userId, addressInfo) {
  const userRef = admin.firestore().collection('users').doc(userId);
  const userData = (await userRef.get()).data();
  
  if (userData && userData.apartmentInfo) {
    const requestedAddress = userData.apartmentInfo.address.detailAddress;
    
    // 주소 매칭 확인
    if (addressInfo.address && addressInfo.address.includes(requestedAddress)) {
      await userRef.update({
        'isApartmentVerified': true,
        'apartmentInfo.verifiedAt': admin.firestore.FieldValue.serverTimestamp(),
        'apartmentInfo.verificationMethod': 'document',
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });
      
      // 인증 완료 알림
      await admin.firestore().collection('notifications').add({
        userId,
        type: 'verification_complete',
        title: '아파트 인증 완료',
        message: '아파트 인증이 완료되었습니다.',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    } else {
      // 인증 실패 알림
      await admin.firestore().collection('notifications').add({
        userId,
        type: 'verification_failed',
        title: '아파트 인증 실패',
        message: '제출하신 서류에서 주소 정보를 확인할 수 없습니다.',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  }
}

// 임시 파일 삭제
async function deleteTemporaryFile(bucket, fileName) {
  await storage.bucket(bucket).file(fileName).delete();
}

// 관련 썸네일 삭제
async function deleteRelatedThumbnails(fileName) {
  const thumbnailName = `thumbnails/${fileName}`;
  const resizedName = `resized/${fileName}`;
  const audioThumbnailName = `thumbnails/audio/${fileName}`;
  
  try {
    await storage.bucket().file(thumbnailName).delete();
    await storage.bucket().file(resizedName).delete();
    await storage.bucket().file(audioThumbnailName).delete();
  } catch (error) {
    console.log('Thumbnail not found, skipping deletion');
  }
}

// 데이터베이스 파일 참조 제거
async function removeFileReferences(fileName) {
  if (fileName.includes('posts/')) {
    const postId = fileName.split('/')[1];
    await admin.firestore().collection('posts').doc(postId).update({
      imageUrls: admin.firestore.FieldValue.arrayRemove(fileName)
    });
  } else if (fileName.includes('noise_records/')) {
    // 소음 기록에서 파일 참조 제거
    const userId = fileName.split('/')[1];
    const fileNameOnly = fileName.split('/')[2];
    
    const recordQuery = await admin.firestore()
      .collection('noise_records')
      .where('userId', '==', userId)
      .where('fileName', '==', fileNameOnly)
      .limit(1)
      .get();
    
    if (!recordQuery.empty) {
      const recordDoc = recordQuery.docs[0];
      await recordDoc.ref.update({
        audioFileUrl: admin.firestore.FieldValue.delete(),
        isDeleted: true,
        deletedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
  }
}
```

## 5. 소음 기록 관리 Cloud Functions (신규 섹션)

### 5.1 소음 기록 생성 및 관리
```javascript
// functions/src/noise_records/noiseRecordFunctions.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');

const storage = new Storage();

// 소음 기록 생성 API
exports.createNoiseRecord = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const {
      fileName,
      measurements,
      location,
      deviceInfo,
      duration
    } = data;

    try {
      // 소음 기록 문서 생성
      const recordRef = await admin.firestore().collection('noise_records').add({
        userId: context.auth.uid,
        fileName,
        measurements: {
          maxDecibel: measurements.maxDecibel,
          avgDecibel: measurements.avgDecibel,
          minDecibel: measurements.minDecibel,
          duration: duration,
          sampleCount: measurements.sampleCount || 0
        },
        location: {
          coordinates: {
            latitude: location.latitude,
            longitude: location.longitude
          },
          address: location.address,
          accuracy: location.accuracy || null
        },
        deviceInfo: {
          model: deviceInfo.model,
          os: deviceInfo.os,
          appVersion: deviceInfo.appVersion,
          microphoneType: deviceInfo.microphoneType || 'unknown'
        },
        recordedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isVerified: false,
        isProcessed: false,
        audioFileUrl: null // 파일 업로드 후 업데이트됨
      });

      return { 
        success: true, 
        recordId: recordRef.id,
        message: '소음 기록이 생성되었습니다.' 
      };
    } catch (error) {
      console.error('Error creating noise record:', error);
      throw new functions.https.HttpsError('internal', '소음 기록 생성 중 오류가 발생했습니다.');
    }
  });

// 사용자 소음 기록 목록 조회
exports.getUserNoiseRecords = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const { limit = 20, startAfter = null } = data;

    try {
      let query = admin.firestore()
        .collection('noise_records')
        .where('userId', '==', context.auth.uid)
        .orderBy('recordedAt', 'desc')
        .limit(limit);

      if (startAfter) {
        const startAfterDoc = await admin.firestore()
          .collection('noise_records')
          .doc(startAfter)
          .get();
        query = query.startAfter(startAfterDoc);
      }

      const snapshot = await query.get();
      const records = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        recordedAt: doc.data().recordedAt?.toDate()?.toISOString()
      }));

      return { 
        success: true, 
        records,
        hasMore: snapshot.docs.length === limit
      };
    } catch (error) {
      console.error('Error getting user noise records:', error);
      throw new functions.https.HttpsError('internal', '소음 기록 조회 중 오류가 발생했습니다.');
    }
  });

// 소음 기록 삭제
exports.deleteNoiseRecord = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const { recordId } = data;

    try {
      const recordRef = admin.firestore().collection('noise_records').doc(recordId);
      const recordDoc = await recordRef.get();

      if (!recordDoc.exists) {
        throw new functions.https.HttpsError('not-found', '소음 기록을 찾을 수 없습니다.');
      }

      const recordData = recordDoc.data();
      
      // 소유자 확인
      if (recordData.userId !== context.auth.uid) {
        throw new functions.https.HttpsError('permission-denied', '삭제 권한이 없습니다.');
      }

      // Storage에서 오디오 파일 삭제
      if (recordData.audioFileUrl) {
        const fileName = `noise_records/${recordData.userId}/${recordData.fileName}`;
        try {
          await storage.bucket().file(fileName).delete();
        } catch (error) {
          console.error('Error deleting audio file:', error);
        }
      }

      // Firestore에서 기록 삭제
      await recordRef.delete();

      // 사용자 통계 업데이트
      await admin.firestore().collection('users').doc(context.auth.uid).update({
        'statistics.noiseRecordCount': admin.firestore.FieldValue.increment(-1),
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });

      return { 
        success: true, 
        message: '소음 기록이 삭제되었습니다.' 
      };
    } catch (error) {
      console.error('Error deleting noise record:', error);
      throw new functions.https.HttpsError('internal', '소음 기록 삭제 중 오류가 발생했습니다.');
    }
  });

// 소음 기록에서 게시글 생성
exports.createPostFromNoiseRecord = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const {
      recordId,
      title,
      content,
      category,
      boardType = 'noise_review'
    } = data;

    try {
      // 소음 기록 조회
      const recordDoc = await admin.firestore().collection('noise_records').doc(recordId).get();
      
      if (!recordDoc.exists) {
        throw new functions.https.HttpsError('not-found', '소음 기록을 찾을 수 없습니다.');
      }

      const recordData = recordDoc.data();
      
      // 소유자 확인
      if (recordData.userId !== context.auth.uid) {
        throw new functions.https.HttpsError('permission-denied', '권한이 없습니다.');
      }

      // 게시글 생성
      const postRef = await admin.firestore().collection('posts').add({
        userId: context.auth.uid,
        title,
        content,
        category,
        boardType,
        tags: [],
        imageUrls: [],
        noiseRecord: {
          recordId: recordId,
          maxDecibel: recordData.measurements.maxDecibel,
          avgDecibel: recordData.measurements.avgDecibel,
          minDecibel: recordData.measurements.minDecibel,
          duration: recordData.measurements.duration,
          audioFileUrl: recordData.audioFileUrl,
          recordedAt: recordData.recordedAt,
          location: recordData.location
        },
        location: {
          sido: recordData.location.address.sido,
          sigungu: recordData.location.address.sigungu,
          eupmyeondong: recordData.location.address.eupmyeondong,
          coordinates: recordData.location.coordinates
        },
        visibility: 'public',
        apartmentId: recordData.apartmentId || null,
        metrics: {
          likeCount: 0,
          commentCount: 0,
          viewCount: 0,
          shareCount: 0,
          reportCount: 0
        },
        engagement: {
          score: 0,
          lastEngagementAt: admin.firestore.FieldValue.serverTimestamp(),
          trendingScore: 0
        },
        moderation: {
          isApproved: true,
          isReported: false,
          reportReasons: []
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        isDeleted: false,
        isLocked: false,
        isPinned: false,
        isFeatured: false
      });

      return { 
        success: true, 
        postId: postRef.id,
        message: '소음 기록으로부터 게시글이 생성되었습니다.' 
      };
    } catch (error) {
      console.error('Error creating post from noise record:', error);
      throw new functions.https.HttpsError('internal', '게시글 생성 중 오류가 발생했습니다.');
    }
  });

// 지역별 소음 통계 조회
exports.getRegionNoiseStats = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const { sido, sigungu, eupmyeondong, days = 30 } = data;

    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      let query = admin.firestore()
        .collection('noise_records')
        .where('recordedAt', '>=', startDate);

      if (sido) {
        query = query.where('location.address.sido', '==', sido);
      }
      if (sigungu) {
        query = query.where('location.address.sigungu', '==', sigungu);
      }
      if (eupmyeondong) {
        query = query.where('location.address.eupmyeondong', '==', eupmyeondong);
      }

      const snapshot = await query.get();
      
      if (snapshot.empty) {
        return {
          success: true,
          stats: {
            totalRecords: 0,
            avgDecibel: 0,
            maxDecibel: 0,
            minDecibel: 0
          }
        };
      }

      let totalDecibel = 0;
      let maxDecibel = 0;
      let minDecibel = 200;
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        const avgDecibel = data.measurements.avgDecibel;
        const maxDecibelRecord = data.measurements.maxDecibel;
        
        totalDecibel += avgDecibel;
        maxDecibel = Math.max(maxDecibel, maxDecibelRecord);
        minDecibel = Math.min(minDecibel, avgDecibel);
      });

      const stats = {
        totalRecords: snapshot.size,
        avgDecibel: totalDecibel / snapshot.size,
        maxDecibel,
        minDecibel: minDecibel === 200 ? 0 : minDecibel
      };

      return { success: true, stats };
    } catch (error) {
      console.error('Error getting region noise stats:', error);
      throw new functions.https.HttpsError('internal', '지역 소음 통계 조회 중 오류가 발생했습니다.');
    }
  });
```

### 5.2 오디오 파일 업로드 관리
```javascript
// functions/src/noise_records/audioUploadFunctions.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 오디오 파일 업로드 URL 생성
exports.generateAudioUploadUrl = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const { recordId, fileName, contentType } = data;

    // 지원되는 오디오 형식 확인
    const supportedTypes = ['audio/mp3', 'audio/wav', 'audio/m4a', 'audio/aac', 'audio/opus', 'audio/ogg'];
    if (!supportedTypes.includes(contentType)) {
      throw new functions.https.HttpsError('invalid-argument', '지원되지 않는 오디오 형식입니다.');
    }

    try {
      // 소음 기록 존재 확인
      const recordDoc = await admin.firestore().collection('noise_records').doc(recordId).get();
      if (!recordDoc.exists || recordDoc.data().userId !== context.auth.uid) {
        throw new functions.https.HttpsError('permission-denied', '권한이 없습니다.');
      }

      const { Storage } = require('@google-cloud/storage');
      const storage = new Storage();
      
      const bucketName = storage.bucket().name;
      const filePath = `noise_records/${context.auth.uid}/${fileName}`;
      
      // Signed URL 생성 (15분 유효)
      const [signedUrl] = await storage
        .bucket(bucketName)
        .file(filePath)
        .getSignedUrl({
          version: 'v4',
          action: 'write',
          expires: Date.now() + 15 * 60 * 1000, // 15분
          contentType: contentType,
          extensionHeaders: {
            'x-goog-meta-record-id': recordId,
            'x-goog-meta-user-id': context.auth.uid
          }
        });

      // 소음 기록에 파일명 업데이트
      await admin.firestore().collection('noise_records').doc(recordId).update({
        fileName: fileName,
        uploadStartedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      return { 
        success: true, 
        uploadUrl: signedUrl,
        filePath: filePath
      };
    } catch (error) {
      console.error('Error generating upload URL:', error);
      throw new functions.https.HttpsError('internal', '업로드 URL 생성 중 오류가 발생했습니다.');
    }
  });

// 오디오 파일 업로드 완료 처리
exports.completeAudioUpload = functions.region('asia-northeast3')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
    }

    const { recordId, filePath } = data;

    try {
      // 파일 존재 확인
      const { Storage } = require('@google-cloud/storage');
      const storage = new Storage();
      const file = storage.bucket().file(filePath);
      const [exists] = await file.exists();

      if (!exists) {
        throw new functions.https.HttpsError('not-found', '업로드된 파일을 찾을 수 없습니다.');
      }

      // 소음 기록 업데이트
      await admin.firestore().collection('noise_records').doc(recordId).update({
        audioFileUrl: `gs://${storage.bucket().name}/${filePath}`,
        uploadCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
        isProcessed: false
      });

      return { 
        success: true, 
        message: '오디오 파일 업로드가 완료되었습니다.' 
      };
    } catch (error) {
      console.error('Error completing audio upload:', error);
      throw new functions.https.HttpsError('internal', '업로드 완료 처리 중 오류가 발생했습니다.');
    }
  });
```

## 6. Cloud Functions 스케줄러

### 6.1 정기 작업 설정
```javascript
// functions/src/scheduled/scheduledTasks.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 일일 랭킹 업데이트 (매일 오전 1시)
exports.updateDailyRankings = functions.pubsub
  .schedule('0 1 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting daily ranking update...');
    
    try {
      await updateRegionRankings();
      await updateApartmentRankings();
      await updateUserRankings();
      
      console.log('Daily ranking update completed');
    } catch (error) {
      console.error('Error updating daily rankings:', error);
    }
  });

// 주간 베스트 게시글 선정 (매주 월요일 오전 12시)
exports.selectWeeklyBestPosts = functions.pubsub
  .schedule('0 0 * * 1')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting weekly best posts selection...');
    
    try {
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      
      // 지난 주 게시글 중 추천 수가 높은 게시글 선정
      const bestPosts = await admin.firestore()
        .collection('posts')
        .where('boardType', '==', 'noise_review')
        .where('createdAt', '>=', weekAgo)
        .orderBy('metrics.likeCount', 'desc')
        .limit(10)
        .get();
      
      const bestPostsData = bestPosts.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      // 주간 베스트 컬렉션에 저장
      await admin.firestore().collection('weekly_best').add({
        posts: bestPostsData,
        weekOf: weekAgo,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log('Weekly best posts selection completed');
    } catch (error) {
      console.error('Error selecting weekly best posts:', error);
    }
  });

// 월간 베스트 게시글 선정 (매월 1일 오전 12시)
exports.selectMonthlyBestPosts = functions.pubsub
  .schedule('0 0 1 * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting monthly best posts selection...');
    
    try {
      const monthAgo = new Date();
      monthAgo.setMonth(monthAgo.getMonth() - 1);
      
      // 지난 달 게시글 중 추천 수가 높은 게시글 선정
      const bestPosts = await admin.firestore()
        .collection('posts')
        .where('boardType', '==', 'noise_review')
        .where('createdAt', '>=', monthAgo)
        .orderBy('metrics.likeCount', 'desc')
        .limit(20)
        .get();
      
      const bestPostsData = bestPosts.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      
      // 월간 베스트 컬렉션에 저장
      await admin.firestore().collection('monthly_best').add({
        posts: bestPostsData,
        monthOf: monthAgo,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log('Monthly best posts selection completed');
    } catch (error) {
      console.error('Error selecting monthly best posts:', error);
    }
  });

// 데이터 정리 작업 (매일 오전 3시)
exports.cleanupOldData = functions.pubsub
  .schedule('0 3 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting data cleanup...');
    
    try {
      // 1. 오래된 알림 삭제 (30일 이상)
      await cleanupOldNotifications();
      
      // 2. 만료된 토큰 삭제
      await cleanupExpiredTokens();
      
      // 3. 임시 파일 삭제
      await cleanupTemporaryFiles();
      
      // 4. 비활성 사용자 처리
      await processInactiveUsers();
      
      console.log('Data cleanup completed');
    } catch (error) {
      console.error('Error during data cleanup:', error);
    }
  });

// 백업 작업 (매일 오전 2시)
exports.backupData = functions.pubsub
  .schedule('0 2 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    console.log('Starting data backup...');
    
    try {
      const { Storage } = require('@google-cloud/storage');
      const storage = new Storage();
      
      const projectId = process.env.GCP_PROJECT;
      const timestamp = new Date().toISOString().split('T')[0];
      
      // Firestore 백업
      const backupOperation = await admin.firestore().backup({
        databaseId: '(default)',
        collectionIds: ['users', 'posts', 'comments', 'apartments', 'noise_records'],
        outputUriPrefix: `gs://${projectId}-backup/firestore-${timestamp}`
      });
      
      console.log('Firestore backup initiated:', backupOperation.name);
      
      // BigQuery 백업
      const { BigQuery } = require('@google-cloud/bigquery');
      const bigquery = new BigQuery();
      
      const dataset = bigquery.dataset('noisebattle');
      const tables = ['posts', 'users', 'noise_records'];
      
      for (const tableName of tables) {
        const table = dataset.table(tableName);
        const destination = `gs://${projectId}-backup/bigquery-${timestamp}/${tableName}.json`;
        
        await table.export(destination);
        console.log(`${tableName} table backed up to ${destination}`);
      }
      
      console.log('Data backup completed');
    } catch (error) {
      console.error('Error during data backup:', error);
    }
  });

// 헬퍼 함수들
async function updateRegionRankings() {
  const { BigQuery } = require('@google-cloud/bigquery');
  const bigquery = new BigQuery();
  
  const query = `
    SELECT 
      location_sido,
      location_sigungu,
      location_eupmyeondong,
      COUNT(*) as post_count,
      AVG(noise_max_decibel) as avg_noise_level,
      SUM(like_count) as total_likes,
      (COUNT(*) * 0.3) + (AVG(noise_max_decibel) * 0.4) + (SUM(like_count) * 0.3) as noise_index
    FROM \`noisebattle.posts\`
    WHERE created_at >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
      AND noise_max_decibel IS NOT NULL
    GROUP BY location_sido, location_sigungu, location_eupmyeondong
    ORDER BY noise_index DESC
    LIMIT 100
  `;
  
  const [rows] = await bigquery.query(query);
  
  const rankingData = rows.map((row, index) => ({
    rank: index + 1,
    id: `${row.location_sido}-${row.location_sigungu}-${row.location_eupmyeondong}`,
    name: `${row.location_sido} ${row.location_sigungu} ${row.location_eupmyeondong}`,
    score: row.noise_index,
    postCount: row.post_count,
    avgNoiseLevel: row.avg_noise_level,
    totalLikes: row.total_likes
  }));
  
  await admin.firestore().collection('rankings').doc('region-daily').set({
    type: 'region',
    period: 'daily',
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    data: rankingData
  });
}

async function updateApartmentRankings() {
  // 아파트별 랭킹 업데이트 로직
  const apartmentsSnapshot = await admin.firestore()
    .collection('apartments')
    .orderBy('noiseStatistics.noiseIndex', 'desc')
    .limit(100)
    .get();
  
  const rankingData = apartmentsSnapshot.docs.map((doc, index) => {
    const data = doc.data();
    return {
      rank: index + 1,
      id: doc.id,
      name: data.name,
      score: data.noiseStatistics.noiseIndex,
      postCount: data.totalPosts,
      avgNoiseLevel: data.noiseStatistics.avgNoiseLevel,
      address: data.address
    };
  });
  
  await admin.firestore().collection('rankings').doc('apartment-daily').set({
    type: 'apartment',
    period: 'daily',
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    data: rankingData
  });
}

async function updateUserRankings() {
  // 사용자별 랭킹 업데이트 로직
  const usersSnapshot = await admin.firestore()
    .collection('users')
    .orderBy('statistics.postCount', 'desc')
    .limit(100)
    .get();
  
  const rankingData = usersSnapshot.docs.map((doc, index) => {
    const data = doc.data();
    return {
      rank: index + 1,
      id: doc.id,
      nickname: data.nickname,
      postCount: data.statistics.postCount,
      commentCount: data.statistics.commentCount,
      likeCount: data.statistics.likeCount
    };
  });
  
  await admin.firestore().collection('rankings').doc('user-daily').set({
    type: 'user',
    period: 'daily',
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    data: rankingData
  });
}

async function cleanupOldNotifications() {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  
  const oldNotifications = await admin.firestore()
    .collection('notifications')
    .where('createdAt', '<', thirtyDaysAgo)
    .get();
  
  const batch = admin.firestore().batch();
  oldNotifications.forEach(doc => batch.delete(doc.ref));
  
  await batch.commit();
  console.log(`Deleted ${oldNotifications.size} old notifications`);
}

async function cleanupExpiredTokens() {
  // 만료된 토큰 정리 로직
  const expiredTokens = await admin.firestore()
    .collection('tokens')
    .where('expiresAt', '<', new Date())
    .get();
  
  const batch = admin.firestore().batch();
  expiredTokens.forEach(doc => batch.delete(doc.ref));
  
  await batch.commit();
  console.log(`Deleted ${expiredTokens.size} expired tokens`);
}

async function cleanupTemporaryFiles() {
  const { Storage } = require('@google-cloud/storage');
  const storage = new Storage();
  
  const [files] = await storage.bucket().getFiles({
    prefix: 'verification/',
    maxResults: 1000
  });
  
  const oneDayAgo = new Date();
  oneDayAgo.setDate(oneDayAgo.getDate() - 1);
  
  for (const file of files) {
    const [metadata] = await file.getMetadata();
    const created = new Date(metadata.timeCreated);
    
    if (created < oneDayAgo) {
      await file.delete();
      console.log(`Deleted temporary file: ${file.name}`);
    }
  }
}

async function processInactiveUsers() {
  const sixMonthsAgo = new Date();
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
  
  const inactiveUsers = await admin.firestore()
    .collection('users')
    .where('lastLoginAt', '<', sixMonthsAgo)
    .where('isActive', '==', true)
    .get();
  
  const batch = admin.firestore().batch();
  inactiveUsers.forEach(doc => {
    batch.update(doc.ref, {
      isActive: false,
      deactivatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });
  
  await batch.commit();
  console.log(`Processed ${inactiveUsers.size} inactive users`);
}
```

## 7. 환경 변수 및 설정

### 7.1 환경 변수 설정
```bash
# functions/.env
# Firebase 설정
FIREBASE_PROJECT_ID=noisebattle-app
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@noisebattle-app.iam.gserviceaccount.com

# Google Cloud 설정
GOOGLE_CLOUD_PROJECT=noisebattle-app
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json

# 외부 API 키
KG_MOBILIANCE_API_KEY=your_kg_mobiliance_api_key
KG_MOBILIANCE_API_SECRET=your_kg_mobiliance_api_secret
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
NAVER_MAPS_API_KEY=your_naver_maps_api_key

# 알림 설정
FCM_SERVER_KEY=your_fcm_server_key
SLACK_WEBHOOK_URL=your_slack_webhook_url

# 데이터베이스 설정
BIGQUERY_DATASET=noisebattle
BIGQUERY_TABLE_PREFIX=prod_

# 보안 설정
JWT_SECRET=your_jwt_secret_key
ENCRYPTION_KEY=your_encryption_key
```

### 7.2 Firebase 설정 파일
```javascript
// functions/src/config/firebase.js
const admin = require('firebase-admin');

// 환경에 따른 설정
const isDevelopment = process.env.NODE_ENV === 'development';
const isProduction = process.env.NODE_ENV === 'production';

const firebaseConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  storageBucket: `${process.env.FIREBASE_PROJECT_ID}.appspot.com`,
  databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}-default-rtdb.firebaseio.com`
};

// Firebase Admin SDK 초기화
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(firebaseConfig),
    databaseURL: firebaseConfig.databaseURL,
    storageBucket: firebaseConfig.storageBucket
  });
}

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();
const messaging = admin.messaging();

// 개발 환경에서는 에뮬레이터 사용
if (isDevelopment) {
  db.settings({
    host: 'localhost:8080',
    ssl: false
  });
}

module.exports = {
  admin,
  db,
  auth,
  storage,
  messaging,
  isDevelopment,
  isProduction
};
```

## 8. 배포 및 모니터링

### 8.1 배포 스크립트
```bash
#!/bin/bash
# deploy.sh

echo "Starting deployment..."

# 환경 확인
if [ "$1" = "prod" ]; then
  echo "Deploying to production..."
  export NODE_ENV=production
  firebase use noisebattle-app
elif [ "$1" = "dev" ]; then
  echo "Deploying to development..."
  export NODE_ENV=development
  firebase use noisebattle-dev
else
  echo "Usage: ./deploy.sh [prod|dev]"
  exit 1
fi

# 빌드
echo "Building functions..."
cd functions
npm run build
cd ..

# 배포
echo "Deploying to Firebase..."
firebase deploy --only functions,firestore,storage

echo "Deployment completed!"
```

### 8.2 모니터링 설정
```javascript
// functions/src/monitoring/monitoring.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// 에러 모니터링
exports.errorMonitoring = functions.https.onRequest((req, res) => {
  const error = req.body;
  
  // 에러 로그를 Firestore에 저장
  admin.firestore().collection('error_logs').add({
    error: error.message,
    stack: error.stack,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    userAgent: req.headers['user-agent'],
    ip: req.ip
  });
  
  // 심각한 에러인 경우 슬랙 알림
  if (error.level === 'critical') {
    sendSlackAlert(error);
  }
  
  res.status(200).send('Error logged');
});

// 성능 모니터링
exports.performanceMonitoring = functions.https.onRequest((req, res) => {
  const metrics = req.body;
  
  // 성능 지표를 BigQuery에 저장
  const { BigQuery } = require('@google-cloud/bigquery');
  const bigquery = new BigQuery();
  
  const dataset = bigquery.dataset('noisebattle');
  const table = dataset.table('performance_metrics');
  
  table.insert([{
    timestamp: new Date().toISOString(),
    ...metrics
  }]);
  
  res.status(200).send('Metrics logged');
});

// 슬랙 알림 함수
async function sendSlackAlert(error) {
  const axios = require('axios');
  
  const message = {
    text: `🚨 Critical Error Alert`,
    attachments: [{
      color: 'danger',
      fields: [{
        title: 'Error Message',
        value: error.message,
        short: false
      }, {
        title: 'Timestamp',
        value: new Date().toISOString(),
        short: true
      }]
    }]
  };
  
  await axios.post(process.env.SLACK_WEBHOOK_URL, message);
}
```

### 8.3 헬스 체크
```javascript
// functions/src/health/healthCheck.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.healthCheck = functions.https.onRequest(async (req, res) => {
  const healthStatus = {
    timestamp: new Date().toISOString(),
    services: {}
  };
  
  try {
    // Firestore 연결 확인
    await admin.firestore().collection('health').doc('test').get();
    healthStatus.services.firestore = 'healthy';
  } catch (error) {
    healthStatus.services.firestore = 'unhealthy';
  }
  
  try {
    // Authentication 확인
    await admin.auth().listUsers(1);
    healthStatus.services.auth = 'healthy';
  } catch (error) {
    healthStatus.services.auth = 'unhealthy';
  }
  
  try {
    // Storage 확인
    const [files] = await admin.storage().bucket().getFiles({ maxResults: 1 });
    healthStatus.services.storage = 'healthy';
  } catch (error) {
    healthStatus.services.storage = 'unhealthy';
  }
  
  const isHealthy = Object.values(healthStatus.services).every(status => status === 'healthy');
  
  res.status(isHealthy ? 200 : 503).json(healthStatus);
});
```

이 백엔드 개발 계획서는 frontend.md, database.md, security.md, law.md와 연계하여 Firebase 기반의 안정적이고 확장 가능한 백엔드 시스템을 구축합니다. 