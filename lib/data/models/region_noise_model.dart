import 'package:cloud_firestore/cloud_firestore.dart';

class RegionNoiseModel {
  final String regionKey;
  final String sido;
  final String sigungu;
  final String eupmyeondong;
  final int totalRecords;
  final double avgDecibel;
  final double maxDecibel;
  final double totalDecibel;
  final Map<String, int> hourlyDistribution;
  final WeeklyTrendModel weeklyTrend;
  final List<NoiseTypeModel> topNoiseTypes;
  final DateTime lastUpdated;
  final DateTime createdAt;

  RegionNoiseModel({
    required this.regionKey,
    required this.sido,
    required this.sigungu,
    required this.eupmyeondong,
    required this.totalRecords,
    required this.avgDecibel,
    required this.maxDecibel,
    required this.totalDecibel,
    required this.hourlyDistribution,
    required this.weeklyTrend,
    required this.topNoiseTypes,
    required this.lastUpdated,
    required this.createdAt,
  });

  factory RegionNoiseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RegionNoiseModel(
      regionKey: data['regionKey'] ?? '',
      sido: data['sido'] ?? '',
      sigungu: data['sigungu'] ?? '',
      eupmyeondong: data['eupmyeondong'] ?? '',
      totalRecords: data['totalRecords'] ?? 0,
      avgDecibel: (data['avgDecibel'] ?? 0.0).toDouble(),
      maxDecibel: (data['maxDecibel'] ?? 0.0).toDouble(),
      totalDecibel: (data['totalDecibel'] ?? 0.0).toDouble(),
      hourlyDistribution: Map<String, int>.from(
        data['hourlyDistribution'] ?? {},
      ),
      weeklyTrend: WeeklyTrendModel.fromMap(data['weeklyTrend'] ?? {}),
      topNoiseTypes: (data['topNoiseTypes'] as List<dynamic>? ?? [])
          .map((item) => NoiseTypeModel.fromMap(item))
          .toList(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'regionKey': regionKey,
      'sido': sido,
      'sigungu': sigungu,
      'eupmyeondong': eupmyeondong,
      'totalRecords': totalRecords,
      'avgDecibel': avgDecibel,
      'maxDecibel': maxDecibel,
      'totalDecibel': totalDecibel,
      'hourlyDistribution': hourlyDistribution,
      'weeklyTrend': weeklyTrend.toMap(),
      'topNoiseTypes': topNoiseTypes.map((item) => item.toMap()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 소음 심각도 계산 (0-100)
  int get noiseSeverity {
    if (totalRecords == 0) return 0;

    // 기록 수, 평균 데시벨, 최고 데시벨을 종합하여 심각도 계산
    final recordWeight = (totalRecords / 100).clamp(0.0, 1.0) * 30;
    final avgWeight = (avgDecibel / 80).clamp(0.0, 1.0) * 40;
    final maxWeight = (maxDecibel / 120).clamp(0.0, 1.0) * 30;

    return (recordWeight + avgWeight + maxWeight).round();
  }

  // 지역 전체 주소
  String get fullAddress => '$sido $sigungu $eupmyeondong';

  // 간단한 주소 (시/군/구 + 읍/면/동)
  String get shortAddress => '$sigungu $eupmyeondong';
}

class WeeklyTrendModel {
  final double currentWeek;
  final double previousWeek;
  final double changePercent;

  WeeklyTrendModel({
    required this.currentWeek,
    required this.previousWeek,
    required this.changePercent,
  });

  factory WeeklyTrendModel.fromMap(Map<String, dynamic> map) {
    return WeeklyTrendModel(
      currentWeek: (map['currentWeek'] ?? 0.0).toDouble(),
      previousWeek: (map['previousWeek'] ?? 0.0).toDouble(),
      changePercent: (map['changePercent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentWeek': currentWeek,
      'previousWeek': previousWeek,
      'changePercent': changePercent,
    };
  }

  bool get isIncreasing => changePercent > 0;
  bool get isDecreasing => changePercent < 0;
  bool get isStable => changePercent == 0;
}

class NoiseTypeModel {
  final String type;
  final int count;
  final double avgDecibel;

  NoiseTypeModel({
    required this.type,
    required this.count,
    required this.avgDecibel,
  });

  factory NoiseTypeModel.fromMap(Map<String, dynamic> map) {
    return NoiseTypeModel(
      type: map['type'] ?? '',
      count: map['count'] ?? 0,
      avgDecibel: (map['avgDecibel'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'count': count, 'avgDecibel': avgDecibel};
  }

  String get displayName {
    switch (type) {
      case 'footstep':
        return '발걸음 소리';
      case 'music':
        return '음악/TV';
      case 'conversation':
        return '대화';
      case 'construction':
        return '공사 소음';
      case 'traffic':
        return '교통 소음';
      case 'appliance':
        return '생활 가전';
      default:
        return '기타';
    }
  }
}

// 랭킹 데이터 모델
class RankingModel {
  final String type; // region, apartment, user
  final String period; // daily, weekly, monthly, yearly
  final DateTime lastUpdated;
  final List<RankingItemModel> data;

  RankingModel({
    required this.type,
    required this.period,
    required this.lastUpdated,
    required this.data,
  });

  factory RankingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RankingModel(
      type: data['type'] ?? '',
      period: data['period'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      data: (data['data'] as List<dynamic>? ?? [])
          .map((item) => RankingItemModel.fromMap(item))
          .toList(),
    );
  }
}

class RankingItemModel {
  final int rank;
  final String id;
  final String name;
  final double score;
  final double noiseIndex;
  final int totalReports;
  final int totalRecords;
  final int change;
  final RankingMetadataModel metadata;

  RankingItemModel({
    required this.rank,
    required this.id,
    required this.name,
    required this.score,
    required this.noiseIndex,
    required this.totalReports,
    required this.totalRecords,
    required this.change,
    required this.metadata,
  });

  factory RankingItemModel.fromMap(Map<String, dynamic> map) {
    return RankingItemModel(
      rank: map['rank'] ?? 0,
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      noiseIndex: (map['noiseIndex'] ?? 0.0).toDouble(),
      totalReports: map['totalReports'] ?? 0,
      totalRecords: map['totalRecords'] ?? 0,
      change: map['change'] ?? 0,
      metadata: RankingMetadataModel.fromMap(map['metadata'] ?? {}),
    );
  }

  bool get hasRankingChange => change != 0;
  bool get rankingUp => change > 0;
  bool get rankingDown => change < 0;
}

class RankingMetadataModel {
  final String address;
  final double? latitude;
  final double? longitude;
  final double avgDecibel;
  final List<String> peakHours;

  RankingMetadataModel({
    required this.address,
    this.latitude,
    this.longitude,
    required this.avgDecibel,
    required this.peakHours,
  });

  factory RankingMetadataModel.fromMap(Map<String, dynamic> map) {
    final coordinates = map['coordinates'] as Map<String, dynamic>?;

    return RankingMetadataModel(
      address: map['address'] ?? '',
      latitude: coordinates?['latitude']?.toDouble(),
      longitude: coordinates?['longitude']?.toDouble(),
      avgDecibel: (map['avgDecibel'] ?? 0.0).toDouble(),
      peakHours: List<String>.from(map['peakHours'] ?? []),
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}
