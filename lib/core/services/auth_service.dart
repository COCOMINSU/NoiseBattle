import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

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
      final now = DateTime.now();
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        nickname: user.displayName ?? '',
        displayName: user.displayName ?? '',
        photoURL: user.photoURL,
        isVerified: false,
        isApartmentVerified: false,
        apartmentInfo: null,
        socialLogins: SocialLogins(
          google: SocialLoginInfo(id: user.uid, email: user.email ?? ''),
        ),
        preferences: UserPreferences(
          pushNotifications: true,
          emailNotifications: true,
          locationSharing: false,
        ),
        statistics: UserStatistics(
          postCount: 0,
          commentCount: 0,
          likeCount: 0,
          reportCount: 0,
        ),
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
        isActive: true,
        isBlocked: false,
        role: 'user',
      );

      await userDoc.set(newUser.toFirestore());
    } else {
      // 기존 사용자인 경우 lastLoginAt만 업데이트
      await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
    }
  }

  // 사용자 프로필 정보 가져오기
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception('사용자 프로필 조회 실패: $e');
    }
  }

  // 사용자 프로필 업데이트
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('사용자 프로필 업데이트 실패: $e');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }

  // 현재 사용자가 로그인되어 있는지 확인
  bool get isLoggedIn => currentUser != null;

  // 사용자 UID 가져오기
  String? get uid => currentUser?.uid;

  // 사용자 이메일 가져오기
  String? get email => currentUser?.email;

  // 사용자 이름 가져오기
  String? get displayName => currentUser?.displayName;

  // 사용자 프로필 사진 URL 가져오기
  String? get photoURL => currentUser?.photoURL;

  // 사용자 정보 가져오기
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('사용자 정보 가져오기 실패: $e');
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('사용자 정보 업데이트 실패: $e');
    }
  }
}
