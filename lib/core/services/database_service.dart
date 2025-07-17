import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

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

  // 사용자 프로필 업데이트
  Future<void> updateUserProfile({
    required String uid,
    String? nickname,
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nickname != null) updates['nickname'] = nickname;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoURL != null) updates['photoURL'] = photoURL;

      if (updates.isNotEmpty) {
        await updateUser(uid, updates);
      }
    } catch (e) {
      throw Exception('프로필 업데이트 실패: $e');
    }
  }

  // 사용자 설정 업데이트
  Future<void> updateUserPreferences({
    required String uid,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? locationSharing,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (pushNotifications != null) {
        updates['preferences.pushNotifications'] = pushNotifications;
      }
      if (emailNotifications != null) {
        updates['preferences.emailNotifications'] = emailNotifications;
      }
      if (locationSharing != null) {
        updates['preferences.locationSharing'] = locationSharing;
      }

      if (updates.isNotEmpty) {
        await updateUser(uid, updates);
      }
    } catch (e) {
      throw Exception('사용자 설정 업데이트 실패: $e');
    }
  }

  // 아파트 정보 업데이트
  Future<void> updateApartmentInfo({
    required String uid,
    required String apartmentName,
    required String sido,
    required String sigungu,
    required String eupmyeondong,
    required String detailAddress,
    required String postalCode,
    required double latitude,
    required double longitude,
    required String dong,
    required String ho,
    required String verificationMethod,
  }) async {
    try {
      final apartmentInfo = {
        'name': apartmentName,
        'address': {
          'sido': sido,
          'sigungu': sigungu,
          'eupmyeondong': eupmyeondong,
          'detailAddress': detailAddress,
          'postalCode': postalCode,
          'coordinates': {'latitude': latitude, 'longitude': longitude},
        },
        'dong': dong,
        'ho': ho,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verificationMethod': verificationMethod,
      };

      await updateUser(uid, {
        'apartmentInfo': apartmentInfo,
        'isApartmentVerified': true,
      });
    } catch (e) {
      throw Exception('아파트 정보 업데이트 실패: $e');
    }
  }

  // 사용자 통계 업데이트
  Future<void> updateUserStatistics({
    required String uid,
    int? postCount,
    int? commentCount,
    int? likeCount,
    int? reportCount,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (postCount != null) {
        updates['statistics.postCount'] = postCount;
      }
      if (commentCount != null) {
        updates['statistics.commentCount'] = commentCount;
      }
      if (likeCount != null) {
        updates['statistics.likeCount'] = likeCount;
      }
      if (reportCount != null) {
        updates['statistics.reportCount'] = reportCount;
      }

      if (updates.isNotEmpty) {
        await updateUser(uid, updates);
      }
    } catch (e) {
      throw Exception('사용자 통계 업데이트 실패: $e');
    }
  }

  // 사용자 통계 증가
  Future<void> incrementUserStatistics({
    required String uid,
    bool incrementPost = false,
    bool incrementComment = false,
    bool incrementLike = false,
    bool incrementReport = false,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (incrementPost) {
        updates['statistics.postCount'] = FieldValue.increment(1);
      }
      if (incrementComment) {
        updates['statistics.commentCount'] = FieldValue.increment(1);
      }
      if (incrementLike) {
        updates['statistics.likeCount'] = FieldValue.increment(1);
      }
      if (incrementReport) {
        updates['statistics.reportCount'] = FieldValue.increment(1);
      }

      if (updates.isNotEmpty) {
        await updateUser(uid, updates);
      }
    } catch (e) {
      throw Exception('사용자 통계 증가 실패: $e');
    }
  }

  // 사용자 본인인증 상태 업데이트
  Future<void> updateUserVerification({
    required String uid,
    required bool isVerified,
  }) async {
    try {
      await updateUser(uid, {'isVerified': isVerified});
    } catch (e) {
      throw Exception('본인인증 상태 업데이트 실패: $e');
    }
  }

  // 사용자 활성/비활성 상태 업데이트
  Future<void> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    try {
      await updateUser(uid, {'isActive': isActive});
    } catch (e) {
      throw Exception('사용자 활성 상태 업데이트 실패: $e');
    }
  }

  // 사용자 차단 상태 업데이트
  Future<void> updateUserBlockStatus({
    required String uid,
    required bool isBlocked,
  }) async {
    try {
      await updateUser(uid, {'isBlocked': isBlocked});
    } catch (e) {
      throw Exception('사용자 차단 상태 업데이트 실패: $e');
    }
  }

  // 지역별 사용자 목록 조회
  Future<List<UserModel>> getUsersByRegion({
    required String sido,
    required String sigungu,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('apartmentInfo.address.sido', isEqualTo: sido)
          .where('apartmentInfo.address.sigungu', isEqualTo: sigungu)
          .where('isApartmentVerified', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('지역별 사용자 조회 실패: $e');
    }
  }

  // 같은 아파트 사용자 목록 조회
  Future<List<UserModel>> getUsersBySameApartment({
    required String apartmentName,
    required String sido,
    required String sigungu,
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('apartmentInfo.name', isEqualTo: apartmentName)
          .where('apartmentInfo.address.sido', isEqualTo: sido)
          .where('apartmentInfo.address.sigungu', isEqualTo: sigungu)
          .where('isApartmentVerified', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('같은 아파트 사용자 조회 실패: $e');
    }
  }
}
