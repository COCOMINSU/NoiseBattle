/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");

// Firebase Admin SDK 초기화
const admin = require("firebase-admin");

admin.initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// 사용자 생성 시 자동 프로필 생성
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  const {uid, email, displayName, photoURL} = user;

  try {
    // Firestore에 사용자 프로필 생성
    await admin.firestore().collection("users").doc(uid).set({
      uid,
      email,
      nickname: displayName || "익명사용자",
      profileImageUrl: photoURL,
      isVerified: false,
      isApartmentVerified: false,
      apartmentInfo: null,
      socialLogins: {},
      preferences: {
        pushNotifications: true,
        emailNotifications: true,
        locationSharing: false,
      },
      statistics: {
        postCount: 0,
        commentCount: 0,
        likeCount: 0,
        reportCount: 0,
        noiseRecordCount: 0,
      },
      storage: {
        totalSizeBytes: 0,
        audioFileCount: 0,
        lastCleanupAt: null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      isBlocked: false,
      role: "user",
    });

    logger.info(`User profile created for ${uid}`);
  } catch (error) {
    logger.error("Error creating user profile:", error);
  }
});

// 사용자 계정 삭제 시 자동 실행
exports.deleteUserProfile = functions.auth.user().onDelete(async (user) => {
  const {uid} = user;

  try {
    // 사용자 관련 데이터 삭제 (소음 녹음 파일 포함)
    await deleteUserData(uid);
    logger.info(`User data deleted for ${uid}`);
  } catch (error) {
    logger.error("Error deleting user data:", error);
  }
});

// 소음 데이터 통계 업데이트
exports.updateNoiseStatistics = functions.firestore
    .document("noise_records/{recordId}")
    .onCreate(async (snap, context) => {
      const noiseData = snap.data();
      const userId = noiseData.userId;

      try {
        // 사용자 통계 업데이트
        const userRef = admin.firestore().collection("users").doc(userId);
        await userRef.update({
          "statistics.noiseRecordCount":
              admin.firestore.FieldValue.increment(1),
          "storage.audioFileCount":
              admin.firestore.FieldValue.increment(1),
          "updatedAt": admin.firestore.FieldValue.serverTimestamp(),
        });

        logger.info(`Noise statistics updated for user ${userId}`);
      } catch (error) {
        logger.error("Error updating noise statistics:", error);
      }
    });

// 푸시 알림 전송 (새 게시글 작성 시)
exports.sendPushNotification = functions.firestore
    .document("posts/{postId}")
    .onCreate(async (snap, context) => {
      const postData = snap.data();
      const userId = postData.userId;

      try {
        // 작성자 정보 가져오기
        const userDoc = await admin.firestore()
            .collection("users").doc(userId).get();
        const userData = userDoc.data();

        if (!userData) {
          logger.warn(`User data not found for ${userId}`);
          return;
        }

        // 같은 아파트 사용자들에게 알림 전송
        if (postData.apartmentId) {
          const apartmentUsers = await admin.firestore()
              .collection("users")
              .where("apartmentInfo.apartmentId", "==",
                  postData.apartmentId)
              .get();

          const tokens = [];
          apartmentUsers.forEach((doc) => {
            const user = doc.data();
            if (user.fcmToken && user.uid !== userId) {
              tokens.push(user.fcmToken);
            }
          });

          if (tokens.length > 0) {
            const message = {
              notification: {
                title: "새로운 소음 신고",
                body: `${userData.nickname}님이 새로운 게시글을 작성했습니다.`,
              },
              data: {
                postId: context.params.postId,
                type: "new_post",
              },
              tokens: tokens,
            };

            const response = await admin.messaging().sendMulticast(message);
            logger.info(`Push notification sent to ${response.successCount} users`);
          }
        }
      } catch (error) {
        logger.error("Error sending push notification:", error);
      }
    });

/**
 * 사용자 데이터 삭제 헬퍼 함수
 * @param {string} uid - 삭제할 사용자의 UID
 */
async function deleteUserData(uid) {
  const batch = admin.firestore().batch();

  // 사용자 게시글 삭제
  const posts = await admin.firestore()
      .collection("posts")
      .where("userId", "==", uid)
      .get();

  posts.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // 사용자 댓글 삭제
  const comments = await admin.firestore()
      .collection("comments")
      .where("userId", "==", uid)
      .get();

  comments.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // 사용자 소음 기록 삭제
  const noiseRecords = await admin.firestore()
      .collection("noise_records")
      .where("userId", "==", uid)
      .get();

  noiseRecords.forEach((doc) => {
    batch.delete(doc.ref);
  });

  // 사용자 프로필 삭제
  const userRef = admin.firestore().collection("users").doc(uid);
  batch.delete(userRef);

  await batch.commit();
}

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
