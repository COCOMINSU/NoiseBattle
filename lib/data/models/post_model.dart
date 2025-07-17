import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final String boardType;
  final List<String> tags;
  final List<String> imageUrls;
  final NoiseRecordData? noiseRecord;
  final LocationData? location;
  final String visibility; // public, apartment, private
  final String? apartmentId;
  final PostMetrics metrics;
  final PostEngagement engagement;
  final PostModeration moderation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final bool isLocked;
  final bool isPinned;
  final bool isFeatured;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.boardType,
    this.tags = const [],
    this.imageUrls = const [],
    this.noiseRecord,
    this.location,
    this.visibility = 'public',
    this.apartmentId,
    required this.metrics,
    required this.engagement,
    required this.moderation,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
    this.isLocked = false,
    this.isPinned = false,
    this.isFeatured = false,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      boardType: data['boardType'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      noiseRecord: data['noiseRecord'] != null
          ? NoiseRecordData.fromMap(data['noiseRecord'])
          : null,
      location: data['location'] != null
          ? LocationData.fromMap(data['location'])
          : null,
      visibility: data['visibility'] ?? 'public',
      apartmentId: data['apartmentId'],
      metrics: PostMetrics.fromMap(data['metrics'] ?? {}),
      engagement: PostEngagement.fromMap(data['engagement'] ?? {}),
      moderation: PostModeration.fromMap(data['moderation'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      isDeleted: data['isDeleted'] ?? false,
      isLocked: data['isLocked'] ?? false,
      isPinned: data['isPinned'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'boardType': boardType,
      'tags': tags,
      'imageUrls': imageUrls,
      'noiseRecord': noiseRecord?.toMap(),
      'location': location?.toMap(),
      'visibility': visibility,
      'apartmentId': apartmentId,
      'metrics': metrics.toMap(),
      'engagement': engagement.toMap(),
      'moderation': moderation.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'isDeleted': isDeleted,
      'isLocked': isLocked,
      'isPinned': isPinned,
      'isFeatured': isFeatured,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    String? boardType,
    List<String>? tags,
    List<String>? imageUrls,
    NoiseRecordData? noiseRecord,
    LocationData? location,
    String? visibility,
    String? apartmentId,
    PostMetrics? metrics,
    PostEngagement? engagement,
    PostModeration? moderation,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    bool? isLocked,
    bool? isPinned,
    bool? isFeatured,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      boardType: boardType ?? this.boardType,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      noiseRecord: noiseRecord ?? this.noiseRecord,
      location: location ?? this.location,
      visibility: visibility ?? this.visibility,
      apartmentId: apartmentId ?? this.apartmentId,
      metrics: metrics ?? this.metrics,
      engagement: engagement ?? this.engagement,
      moderation: moderation ?? this.moderation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isLocked: isLocked ?? this.isLocked,
      isPinned: isPinned ?? this.isPinned,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

// 소음 측정 데이터
class NoiseRecordData {
  final String recordId;
  final double maxDecibel;
  final double avgDecibel;
  final double minDecibel;
  final int duration; // 측정 시간 (초)
  final String? audioFileUrl;
  final DateTime recordedAt;
  final RecordLocationData? location;
  final DeviceInfo deviceInfo;

  NoiseRecordData({
    required this.recordId,
    required this.maxDecibel,
    required this.avgDecibel,
    required this.minDecibel,
    required this.duration,
    this.audioFileUrl,
    required this.recordedAt,
    this.location,
    required this.deviceInfo,
  });

  factory NoiseRecordData.fromMap(Map<String, dynamic> map) {
    return NoiseRecordData(
      recordId: map['recordId'] ?? '',
      maxDecibel: (map['maxDecibel'] ?? 0.0).toDouble(),
      avgDecibel: (map['avgDecibel'] ?? 0.0).toDouble(),
      minDecibel: (map['minDecibel'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? 0,
      audioFileUrl: map['audioFileUrl'],
      recordedAt: (map['recordedAt'] as Timestamp).toDate(),
      location: map['location'] != null
          ? RecordLocationData.fromMap(map['location'])
          : null,
      deviceInfo: DeviceInfo.fromMap(map['deviceInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'maxDecibel': maxDecibel,
      'avgDecibel': avgDecibel,
      'minDecibel': minDecibel,
      'duration': duration,
      'audioFileUrl': audioFileUrl,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'location': location?.toMap(),
      'deviceInfo': deviceInfo.toMap(),
    };
  }
}

// 녹음 위치 데이터
class RecordLocationData {
  final CoordinatesData coordinates;
  final AddressData address;
  final double accuracy; // GPS 정확도 (미터)

  RecordLocationData({
    required this.coordinates,
    required this.address,
    required this.accuracy,
  });

  factory RecordLocationData.fromMap(Map<String, dynamic> map) {
    return RecordLocationData(
      coordinates: CoordinatesData.fromMap(map['coordinates'] ?? {}),
      address: AddressData.fromMap(map['address'] ?? {}),
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coordinates': coordinates.toMap(),
      'address': address.toMap(),
      'accuracy': accuracy,
    };
  }
}

// 좌표 데이터
class CoordinatesData {
  final double latitude;
  final double longitude;

  CoordinatesData({required this.latitude, required this.longitude});

  factory CoordinatesData.fromMap(Map<String, dynamic> map) {
    return CoordinatesData(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

// 주소 데이터
class AddressData {
  final String sido; // 시/도
  final String sigungu; // 시/군/구
  final String eupmyeondong; // 읍/면/동
  final String detailAddress; // 상세주소

  AddressData({
    required this.sido,
    required this.sigungu,
    required this.eupmyeondong,
    required this.detailAddress,
  });

  factory AddressData.fromMap(Map<String, dynamic> map) {
    return AddressData(
      sido: map['sido'] ?? '',
      sigungu: map['sigungu'] ?? '',
      eupmyeondong: map['eupmyeondong'] ?? '',
      detailAddress: map['detailAddress'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sido': sido,
      'sigungu': sigungu,
      'eupmyeondong': eupmyeondong,
      'detailAddress': detailAddress,
    };
  }

  String get fullAddress => '$sido $sigungu $eupmyeondong';
}

// 기기 정보
class DeviceInfo {
  final String model;
  final String os;
  final String osVersion;
  final String appVersion;
  final String microphoneType;
  final double calibrationOffset; // 교정 오프셋 (dB)

  DeviceInfo({
    required this.model,
    required this.os,
    required this.osVersion,
    required this.appVersion,
    required this.microphoneType,
    required this.calibrationOffset,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      model: map['model'] ?? '',
      os: map['os'] ?? '',
      osVersion: map['osVersion'] ?? '',
      appVersion: map['appVersion'] ?? '',
      microphoneType: map['microphoneType'] ?? '',
      calibrationOffset: (map['calibrationOffset'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'os': os,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'microphoneType': microphoneType,
      'calibrationOffset': calibrationOffset,
    };
  }
}

// 게시글 위치 데이터
class LocationData {
  final String sido;
  final String sigungu;
  final String eupmyeondong;
  final String? apartmentName;
  final CoordinatesData? coordinates;

  LocationData({
    required this.sido,
    required this.sigungu,
    required this.eupmyeondong,
    this.apartmentName,
    this.coordinates,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      sido: map['sido'] ?? '',
      sigungu: map['sigungu'] ?? '',
      eupmyeondong: map['eupmyeondong'] ?? '',
      apartmentName: map['apartmentName'],
      coordinates: map['coordinates'] != null
          ? CoordinatesData.fromMap(map['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sido': sido,
      'sigungu': sigungu,
      'eupmyeondong': eupmyeondong,
      'apartmentName': apartmentName,
      'coordinates': coordinates?.toMap(),
    };
  }

  String get fullAddress => '$sido $sigungu $eupmyeondong';
}

// 게시글 지표
class PostMetrics {
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final int shareCount;
  final int reportCount;

  PostMetrics({
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.shareCount = 0,
    this.reportCount = 0,
  });

  factory PostMetrics.fromMap(Map<String, dynamic> map) {
    return PostMetrics(
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'reportCount': reportCount,
    };
  }

  PostMetrics copyWith({
    int? likeCount,
    int? commentCount,
    int? viewCount,
    int? shareCount,
    int? reportCount,
  }) {
    return PostMetrics(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

// 게시글 참여도
class PostEngagement {
  final double score; // 참여도 점수
  final DateTime? lastEngagementAt;
  final double trendingScore; // 트렌딩 점수

  PostEngagement({
    this.score = 0.0,
    this.lastEngagementAt,
    this.trendingScore = 0.0,
  });

  factory PostEngagement.fromMap(Map<String, dynamic> map) {
    return PostEngagement(
      score: (map['score'] ?? 0.0).toDouble(),
      lastEngagementAt: map['lastEngagementAt'] != null
          ? (map['lastEngagementAt'] as Timestamp).toDate()
          : null,
      trendingScore: (map['trendingScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'lastEngagementAt': lastEngagementAt != null
          ? Timestamp.fromDate(lastEngagementAt!)
          : null,
      'trendingScore': trendingScore,
    };
  }
}

// 게시글 관리
class PostModeration {
  final bool isApproved;
  final bool isReported;
  final List<String> reportReasons;
  final DateTime? moderatedAt;
  final String? moderatorId;

  PostModeration({
    this.isApproved = true,
    this.isReported = false,
    this.reportReasons = const [],
    this.moderatedAt,
    this.moderatorId,
  });

  factory PostModeration.fromMap(Map<String, dynamic> map) {
    return PostModeration(
      isApproved: map['isApproved'] ?? true,
      isReported: map['isReported'] ?? false,
      reportReasons: List<String>.from(map['reportReasons'] ?? []),
      moderatedAt: map['moderatedAt'] != null
          ? (map['moderatedAt'] as Timestamp).toDate()
          : null,
      moderatorId: map['moderatorId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isApproved': isApproved,
      'isReported': isReported,
      'reportReasons': reportReasons,
      'moderatedAt': moderatedAt != null
          ? Timestamp.fromDate(moderatedAt!)
          : null,
      'moderatorId': moderatorId,
    };
  }
}

// 게시글 작성을 위한 DTO
class CreatePostDto {
  final String userId;
  final String title;
  final String content;
  final String category;
  final String boardType;
  final List<String> tags;
  final List<String> imageUrls;
  final NoiseRecordData? noiseRecord;
  final LocationData? location;
  final String visibility;
  final String? apartmentId;

  CreatePostDto({
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.boardType,
    this.tags = const [],
    this.imageUrls = const [],
    this.noiseRecord,
    this.location,
    this.visibility = 'public',
    this.apartmentId,
  });

  PostModel toPostModel({required String id}) {
    final now = DateTime.now();
    return PostModel(
      id: id,
      userId: userId,
      title: title,
      content: content,
      category: category,
      boardType: boardType,
      tags: tags,
      imageUrls: imageUrls,
      noiseRecord: noiseRecord,
      location: location,
      visibility: visibility,
      apartmentId: apartmentId,
      metrics: PostMetrics(),
      engagement: PostEngagement(),
      moderation: PostModeration(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

// 게시글 수정을 위한 DTO
class UpdatePostDto {
  final String? title;
  final String? content;
  final String? category;
  final List<String>? tags;
  final List<String>? imageUrls;
  final String? visibility;

  UpdatePostDto({
    this.title,
    this.content,
    this.category,
    this.tags,
    this.imageUrls,
    this.visibility,
  });

  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (content != null) map['content'] = content;
    if (category != null) map['category'] = category;
    if (tags != null) map['tags'] = tags;
    if (imageUrls != null) map['imageUrls'] = imageUrls;
    if (visibility != null) map['visibility'] = visibility;
    map['updatedAt'] = FieldValue.serverTimestamp();
    return map;
  }
}

// 게시판 타입 상수
class BoardType {
  static const String noiseReview = 'noise_review'; // 소음 후기 게시판
  static const String apartmentCommunity = 'apartment_community'; // 우리 아파트 모임
  static const String freeBoard = 'free_board'; // 자유 게시판
  static const String weeklyBest = 'weekly_best'; // 주간 베스트
  static const String monthlyBest = 'monthly_best'; // 월간 베스트
}

// 카테고리 상수
class PostCategory {
  // 소음 후기 게시판 카테고리
  static const String stress = 'stress'; // 스트레스/하소연
  static const String question = 'question'; // 질문/상담
  static const String solution = 'solution'; // 해결 후기/노하우
  static const String info = 'info'; // 정보 공유
  static const String legal = 'legal'; // 법적 대응/절차

  // 우리 아파트 모임 카테고리
  static const String discussion = 'discussion'; // 층간소음 공론화
  static const String meeting = 'meeting'; // 주민 대응 모임
  static const String tips = 'tips'; // 우리 아파트 꿀팁
  static const String daily = 'daily'; // 일상/잡담

  // 자유 게시판 카테고리
  static const String humor = 'humor'; // 유머/짤방
  static const String food = 'food'; // 맛집/여행
  static const String hobby = 'hobby'; // 취미/관심사
  static const String life = 'life'; // 사는 이야기
  static const String qa = 'qa'; // 아무거나 질문
}

// 가시성 상수
class PostVisibility {
  static const String public = 'public'; // 전체 공개
  static const String apartment = 'apartment'; // 아파트 주민만
  static const String private = 'private'; // 비공개
}
