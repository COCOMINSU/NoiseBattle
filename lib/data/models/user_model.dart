import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String nickname;
  final String displayName;
  final String? photoURL;
  final bool isVerified;
  final bool isApartmentVerified;
  final ApartmentInfo? apartmentInfo;
  final SocialLogins socialLogins;
  final UserPreferences preferences;
  final UserStatistics statistics;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isBlocked;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.nickname,
    required this.displayName,
    this.photoURL,
    required this.isVerified,
    required this.isApartmentVerified,
    this.apartmentInfo,
    required this.socialLogins,
    required this.preferences,
    required this.statistics,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.isActive,
    required this.isBlocked,
    required this.role,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      nickname: data['nickname'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      isVerified: data['isVerified'] ?? false,
      isApartmentVerified: data['isApartmentVerified'] ?? false,
      apartmentInfo: data['apartmentInfo'] != null
          ? ApartmentInfo.fromMap(data['apartmentInfo'])
          : null,
      socialLogins: SocialLogins.fromMap(data['socialLogins'] ?? {}),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      statistics: UserStatistics.fromMap(data['statistics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
      isBlocked: data['isBlocked'] ?? false,
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'nickname': nickname,
      'displayName': displayName,
      'photoURL': photoURL,
      'isVerified': isVerified,
      'isApartmentVerified': isApartmentVerified,
      'apartmentInfo': apartmentInfo?.toMap(),
      'socialLogins': socialLogins.toMap(),
      'preferences': preferences.toMap(),
      'statistics': statistics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'role': role,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? nickname,
    String? displayName,
    String? photoURL,
    bool? isVerified,
    bool? isApartmentVerified,
    ApartmentInfo? apartmentInfo,
    SocialLogins? socialLogins,
    UserPreferences? preferences,
    UserStatistics? statistics,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isBlocked,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickname: nickname ?? this.nickname,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isVerified: isVerified ?? this.isVerified,
      isApartmentVerified: isApartmentVerified ?? this.isApartmentVerified,
      apartmentInfo: apartmentInfo ?? this.apartmentInfo,
      socialLogins: socialLogins ?? this.socialLogins,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      role: role ?? this.role,
    );
  }
}

class ApartmentInfo {
  final String name;
  final ApartmentAddress address;
  final String dong;
  final String ho;
  final DateTime? verifiedAt;
  final String verificationMethod;

  ApartmentInfo({
    required this.name,
    required this.address,
    required this.dong,
    required this.ho,
    this.verifiedAt,
    required this.verificationMethod,
  });

  factory ApartmentInfo.fromMap(Map<String, dynamic> map) {
    return ApartmentInfo(
      name: map['name'] ?? '',
      address: ApartmentAddress.fromMap(map['address'] ?? {}),
      dong: map['dong'] ?? '',
      ho: map['ho'] ?? '',
      verifiedAt: map['verifiedAt'] != null
          ? (map['verifiedAt'] as Timestamp).toDate()
          : null,
      verificationMethod: map['verificationMethod'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address.toMap(),
      'dong': dong,
      'ho': ho,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationMethod': verificationMethod,
    };
  }
}

class ApartmentAddress {
  final String sido;
  final String sigungu;
  final String eupmyeondong;
  final String detailAddress;
  final String postalCode;
  final Coordinates coordinates;

  ApartmentAddress({
    required this.sido,
    required this.sigungu,
    required this.eupmyeondong,
    required this.detailAddress,
    required this.postalCode,
    required this.coordinates,
  });

  factory ApartmentAddress.fromMap(Map<String, dynamic> map) {
    return ApartmentAddress(
      sido: map['sido'] ?? '',
      sigungu: map['sigungu'] ?? '',
      eupmyeondong: map['eupmyeondong'] ?? '',
      detailAddress: map['detailAddress'] ?? '',
      postalCode: map['postalCode'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sido': sido,
      'sigungu': sigungu,
      'eupmyeondong': eupmyeondong,
      'detailAddress': detailAddress,
      'postalCode': postalCode,
      'coordinates': coordinates.toMap(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class SocialLogins {
  final SocialLoginInfo? google;
  final SocialLoginInfo? kakao;
  final SocialLoginInfo? naver;

  SocialLogins({this.google, this.kakao, this.naver});

  factory SocialLogins.fromMap(Map<String, dynamic> map) {
    return SocialLogins(
      google: map['google'] != null
          ? SocialLoginInfo.fromMap(map['google'])
          : null,
      kakao: map['kakao'] != null
          ? SocialLoginInfo.fromMap(map['kakao'])
          : null,
      naver: map['naver'] != null
          ? SocialLoginInfo.fromMap(map['naver'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'google': google?.toMap(),
      'kakao': kakao?.toMap(),
      'naver': naver?.toMap(),
    };
  }
}

class SocialLoginInfo {
  final String id;
  final String email;

  SocialLoginInfo({required this.id, required this.email});

  factory SocialLoginInfo.fromMap(Map<String, dynamic> map) {
    return SocialLoginInfo(id: map['id'] ?? '', email: map['email'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email};
  }
}

class UserPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool locationSharing;

  UserPreferences({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.locationSharing,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      pushNotifications: map['pushNotifications'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      locationSharing: map['locationSharing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'locationSharing': locationSharing,
    };
  }
}

class UserStatistics {
  final int postCount;
  final int commentCount;
  final int likeCount;
  final int reportCount;

  UserStatistics({
    required this.postCount,
    required this.commentCount,
    required this.likeCount,
    required this.reportCount,
  });

  factory UserStatistics.fromMap(Map<String, dynamic> map) {
    return UserStatistics(
      postCount: map['postCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postCount': postCount,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'reportCount': reportCount,
    };
  }
}
