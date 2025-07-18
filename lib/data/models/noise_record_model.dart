import 'package:cloud_firestore/cloud_firestore.dart';

/// 소음 녹음 데이터 모델
///
/// Firestore 'noise_records' 컬렉션의 문서 구조를 정의합니다.
/// 사용자의 소음 녹음 세션에 대한 모든 메타데이터를 포함합니다.
class NoiseRecordModel {
  final String id; // Firestore 문서 ID
  final String userId; // 녹음한 사용자 ID
  final String fileName; // 사용자 지정 파일명
  final String? customTitle; // 녹음에 대한 사용자 제목
  final String? description; // 녹음에 대한 설명
  final Map<String, dynamic> measurements; // 측정 데이터 (최대/최소/평균 dB 등)
  final Map<String, dynamic> location; // 위치 정보 (GPS, 주소)
  final Map<String, dynamic> deviceInfo; // 기기 정보
  final String? audioFileUrl; // Firebase Storage 다운로드 URL
  final DateTime recordedAt; // 녹음 시작 시간
  final DateTime createdAt; // Firestore 생성 시간
  final bool isPublic; // 공개/비공개 설정
  final List<String> tags; // 태그 (카테고리, 키워드)

  const NoiseRecordModel({
    required this.id,
    required this.userId,
    required this.fileName,
    this.customTitle,
    this.description,
    required this.measurements,
    required this.location,
    required this.deviceInfo,
    this.audioFileUrl,
    required this.recordedAt,
    required this.createdAt,
    this.isPublic = false,
    this.tags = const [],
  });

  /// Firestore DocumentSnapshot에서 NoiseRecordModel 생성
  factory NoiseRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoiseRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? '',
      customTitle: data['customTitle'],
      description: data['description'],
      measurements: Map<String, dynamic>.from(data['measurements'] ?? {}),
      location: Map<String, dynamic>.from(data['location'] ?? {}),
      deviceInfo: Map<String, dynamic>.from(data['deviceInfo'] ?? {}),
      audioFileUrl: data['audioFileUrl'],
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  /// QueryDocumentSnapshot에서 NoiseRecordModel 생성 (쿼리 결과용)
  factory NoiseRecordModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoiseRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? '',
      customTitle: data['customTitle'],
      description: data['description'],
      measurements: Map<String, dynamic>.from(data['measurements'] ?? {}),
      location: Map<String, dynamic>.from(data['location'] ?? {}),
      deviceInfo: Map<String, dynamic>.from(data['deviceInfo'] ?? {}),
      audioFileUrl: data['audioFileUrl'],
      recordedAt: (data['recordedAt'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  /// NoiseRecordingService의 결과 데이터에서 NoiseRecordModel 생성
  factory NoiseRecordModel.fromRecordingData({
    required String userId,
    required String fileName,
    required Map<String, dynamic> recordingData,
    String? customTitle,
    String? description,
    List<String> tags = const [],
    bool isPublic = false,
  }) {
    // measurements 데이터 처리
    final measurementsData =
        recordingData['measurements'] as Map<String, dynamic>? ?? {};

    return NoiseRecordModel(
      id: '', // Firestore에서 자동 생성됨
      userId: userId,
      fileName: fileName,
      customTitle: customTitle,
      description: description,
      measurements: {
        'duration': recordingData['duration'] ?? 0,
        'fileSize': recordingData['fileSize'] ?? 0,
        'averageDecibel': measurementsData['averageDecibel'] ?? 0.0,
        'maxDecibel': measurementsData['maxDecibel'] ?? 0.0,
        'minDecibel': measurementsData['minDecibel'] ?? 0.0,
        'measurementCount': measurementsData['measurementCount'] ?? 0,
      },
      location: recordingData['location'] ?? {},
      deviceInfo: {
        'platform': 'Android', // 현재 Android만 지원
        'model': 'Unknown',
        'osVersion': 'Unknown',
      },
      audioFileUrl: recordingData['audioFileUrl'],
      recordedAt: DateTime.parse(recordingData['recordedAt']),
      createdAt: DateTime.now(),
      isPublic: isPublic,
      tags: tags,
    );
  }

  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fileName': fileName,
      'customTitle': customTitle,
      'description': description,
      'measurements': measurements,
      'location': location,
      'deviceInfo': deviceInfo,
      'audioFileUrl': audioFileUrl,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'tags': tags,
    };
  }

  /// JSON 직렬화용 Map 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'customTitle': customTitle,
      'description': description,
      'measurements': measurements,
      'location': location,
      'deviceInfo': deviceInfo,
      'audioFileUrl': audioFileUrl,
      'recordedAt': recordedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isPublic': isPublic,
      'tags': tags,
    };
  }

  /// 모델 복사 (일부 필드 변경)
  NoiseRecordModel copyWith({
    String? id,
    String? userId,
    String? fileName,
    String? customTitle,
    String? description,
    Map<String, dynamic>? measurements,
    Map<String, dynamic>? location,
    Map<String, dynamic>? deviceInfo,
    String? audioFileUrl,
    DateTime? recordedAt,
    DateTime? createdAt,
    bool? isPublic,
    List<String>? tags,
  }) {
    return NoiseRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      customTitle: customTitle ?? this.customTitle,
      description: description ?? this.description,
      measurements: measurements ?? this.measurements,
      location: location ?? this.location,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      audioFileUrl: audioFileUrl ?? this.audioFileUrl,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
    );
  }

  /// 편의 getter들

  /// 녹음 시간 (초)
  int get durationInSeconds => measurements['duration'] ?? 0;

  /// 파일 크기 (바이트)
  int get fileSizeInBytes => measurements['fileSize'] ?? 0;

  /// 평균 데시벨
  double get averageDecibel =>
      (measurements['averageDecibel'] ?? 0.0).toDouble();

  /// 최대 데시벨
  double get maxDecibel => (measurements['maxDecibel'] ?? 0.0).toDouble();

  /// 최소 데시벨
  double get minDecibel => (measurements['minDecibel'] ?? 0.0).toDouble();

  /// 위도
  double? get latitude => location['latitude']?.toDouble();

  /// 경도
  double? get longitude => location['longitude']?.toDouble();

  /// 주소
  String? get address => location['address'];

  /// 위치 정확도
  double? get locationAccuracy => location['accuracy']?.toDouble();

  /// 포맷된 녹음 시간 문자열
  String get formattedDuration {
    final duration = Duration(seconds: durationInSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 포맷된 파일 크기 문자열
  String get formattedFileSize {
    final size = fileSizeInBytes;
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 표시용 제목 (customTitle이 있으면 사용, 없으면 fileName)
  String get displayTitle =>
      customTitle?.isNotEmpty == true ? customTitle! : fileName;

  @override
  String toString() {
    return 'NoiseRecordModel(id: $id, fileName: $fileName, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoiseRecordModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
