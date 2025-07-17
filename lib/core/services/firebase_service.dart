import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Firebase 초기화
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Firestore 설정
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // 사용자 문서 생성
  Future<void> createUserDocument(User user) async {
    final userDoc = firestore.collection('users').doc(user.uid);

    if (!(await userDoc.get()).exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'role': 'user',
        'preferences': {
          'notifications': true,
          'darkMode': false,
          'language': 'ko',
        },
      });
    } else {
      await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(uid).update(data);
  }

  // 사용자 정보 가져오기
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await firestore.collection('users').doc(uid).get();
  }

  // 로그아웃
  Future<void> signOut() async {
    await auth.signOut();
  }
}
