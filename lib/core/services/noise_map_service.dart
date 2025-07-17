import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/region_noise_model.dart';

class NoiseMapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 모든 지역별 소음 통계 데이터 가져오기
  Stream<List<RegionNoiseModel>> getRegionNoiseStats({
    int? minRecords,
    double? minAvgDecibel,
  }) {
    Query query = _firestore.collection('region_noise_stats');

    if (minRecords != null) {
      query = query.where('totalRecords', isGreaterThanOrEqualTo: minRecords);
    }

    if (minAvgDecibel != null) {
      query = query.where('avgDecibel', isGreaterThanOrEqualTo: minAvgDecibel);
    }

    return query
        .orderBy('avgDecibel', descending: true)
        .limit(500) // 최대 500개 지역
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RegionNoiseModel.fromFirestore(doc))
              .toList(),
        );
  }

  // 특정 지역의 소음 통계 가져오기
  Future<RegionNoiseModel?> getRegionNoiseStatsByKey(String regionKey) async {
    try {
      final doc = await _firestore
          .collection('region_noise_stats')
          .doc(regionKey)
          .get();

      if (doc.exists) {
        return RegionNoiseModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('지역 소음 통계 가져오기 실패: $e');
    }
  }

  // 시/도별 소음 통계 가져오기
  Future<List<RegionNoiseModel>> getRegionNoiseStatsBySido(String sido) async {
    try {
      final snapshot = await _firestore
          .collection('region_noise_stats')
          .where('sido', isEqualTo: sido)
          .orderBy('avgDecibel', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => RegionNoiseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('시/도별 소음 통계 가져오기 실패: $e');
    }
  }

  // 시/군/구별 소음 통계 가져오기
  Future<List<RegionNoiseModel>> getRegionNoiseStatsBySigungu(
    String sido,
    String sigungu,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('region_noise_stats')
          .where('sido', isEqualTo: sido)
          .where('sigungu', isEqualTo: sigungu)
          .orderBy('avgDecibel', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => RegionNoiseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('시/군/구별 소음 통계 가져오기 실패: $e');
    }
  }

  // 랭킹 데이터 가져오기
  Future<RankingModel?> getRankingData(String type, String period) async {
    try {
      final docId = '$type-$period';
      final doc = await _firestore.collection('rankings').doc(docId).get();

      if (doc.exists) {
        return RankingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('랭킹 데이터 가져오기 실패: $e');
    }
  }

  // 지역별 랭킹 데이터 가져오기
  Future<RankingModel?> getRegionRanking(String period) async {
    return getRankingData('region', period);
  }

  // 아파트별 랭킹 데이터 가져오기
  Future<RankingModel?> getApartmentRanking(String period) async {
    return getRankingData('apartment', period);
  }

  // 사용자별 랭킹 데이터 가져오기
  Future<RankingModel?> getUserRanking(String period) async {
    return getRankingData('user', period);
  }

  // 지역별 소음 검색
  Future<List<RegionNoiseModel>> searchRegionsByName(String searchTerm) async {
    try {
      // 여러 필드에서 검색
      final searches = await Future.wait([
        // 시/도 검색
        _firestore
            .collection('region_noise_stats')
            .where('sido', isGreaterThanOrEqualTo: searchTerm)
            .where('sido', isLessThanOrEqualTo: '$searchTerm\uf8ff')
            .limit(20)
            .get(),
        // 시/군/구 검색
        _firestore
            .collection('region_noise_stats')
            .where('sigungu', isGreaterThanOrEqualTo: searchTerm)
            .where('sigungu', isLessThanOrEqualTo: '$searchTerm\uf8ff')
            .limit(20)
            .get(),
        // 읍/면/동 검색
        _firestore
            .collection('region_noise_stats')
            .where('eupmyeondong', isGreaterThanOrEqualTo: searchTerm)
            .where('eupmyeondong', isLessThanOrEqualTo: '$searchTerm\uf8ff')
            .limit(20)
            .get(),
      ]);

      final Set<String> addedRegionKeys = {};
      final List<RegionNoiseModel> results = [];

      for (final search in searches) {
        for (final doc in search.docs) {
          final region = RegionNoiseModel.fromFirestore(doc);
          if (!addedRegionKeys.contains(region.regionKey)) {
            addedRegionKeys.add(region.regionKey);
            results.add(region);
          }
        }
      }

      // 평균 데시벨 순으로 정렬
      results.sort((a, b) => b.avgDecibel.compareTo(a.avgDecibel));

      return results;
    } catch (e) {
      throw Exception('지역 검색 실패: $e');
    }
  }

  // 소음 심각도별 지역 필터링
  Future<List<RegionNoiseModel>> getRegionsBySeverity({
    int minSeverity = 0,
    int maxSeverity = 100,
    int limit = 100,
  }) async {
    try {
      // 일단 모든 데이터를 가져와서 클라이언트에서 필터링
      // (Firestore에서는 computed field에 대한 쿼리가 제한적)
      final snapshot = await _firestore
          .collection('region_noise_stats')
          .orderBy('avgDecibel', descending: true)
          .limit(500)
          .get();

      final regions = snapshot.docs
          .map((doc) => RegionNoiseModel.fromFirestore(doc))
          .where((region) {
            final severity = region.noiseSeverity;
            return severity >= minSeverity && severity <= maxSeverity;
          })
          .take(limit)
          .toList();

      return regions;
    } catch (e) {
      throw Exception('심각도별 지역 필터링 실패: $e');
    }
  }

  // 최근 업데이트된 지역 순으로 가져오기
  Future<List<RegionNoiseModel>> getRecentlyUpdatedRegions({
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('region_noise_stats')
          .orderBy('lastUpdated', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RegionNoiseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('최근 업데이트 지역 가져오기 실패: $e');
    }
  }

  // 특정 좌표 주변 지역 찾기 (간단한 bounding box 검색)
  Future<List<RegionNoiseModel>> getNearbyRegions({
    required double centerLat,
    required double centerLng,
    double radiusKm = 10.0,
  }) async {
    try {
      // 실제로는 지오해시나 더 정확한 지리적 검색이 필요하지만
      // 현재는 모든 데이터를 가져와서 클라이언트에서 필터링
      final snapshot = await _firestore
          .collection('region_noise_stats')
          .limit(500)
          .get();

      final regions = snapshot.docs
          .map((doc) => RegionNoiseModel.fromFirestore(doc))
          .toList();

      // 여기서는 단순히 이름으로 필터링하는 예시
      // 실제로는 좌표 기반 거리 계산이 필요
      return regions;
    } catch (e) {
      throw Exception('주변 지역 검색 실패: $e');
    }
  }

  // 소음 통계 요약 정보 가져오기
  Future<NoiseStatsSummary> getNoiseStatsSummary() async {
    try {
      final snapshot = await _firestore.collection('region_noise_stats').get();

      if (snapshot.docs.isEmpty) {
        return NoiseStatsSummary.empty();
      }

      double totalDecibel = 0;
      double maxDecibel = 0;
      double minDecibel = double.infinity;
      int totalRecords = 0;
      int regionCount = snapshot.docs.length;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final avgDecibel = (data['avgDecibel'] ?? 0.0).toDouble();
        final maxDb = (data['maxDecibel'] ?? 0.0).toDouble();
        final records = (data['totalRecords'] ?? 0) as int;

        totalDecibel += avgDecibel;
        totalRecords += records;
        maxDecibel = maxDecibel > maxDb ? maxDecibel : maxDb;
        minDecibel = minDecibel < avgDecibel ? minDecibel : avgDecibel;
      }

      return NoiseStatsSummary(
        totalRegions: regionCount,
        totalRecords: totalRecords,
        avgDecibel: totalDecibel / regionCount,
        maxDecibel: maxDecibel,
        minDecibel: minDecibel == double.infinity ? 0 : minDecibel,
      );
    } catch (e) {
      throw Exception('소음 통계 요약 가져오기 실패: $e');
    }
  }
}

// 소음 통계 요약 클래스
class NoiseStatsSummary {
  final int totalRegions;
  final int totalRecords;
  final double avgDecibel;
  final double maxDecibel;
  final double minDecibel;

  NoiseStatsSummary({
    required this.totalRegions,
    required this.totalRecords,
    required this.avgDecibel,
    required this.maxDecibel,
    required this.minDecibel,
  });

  factory NoiseStatsSummary.empty() {
    return NoiseStatsSummary(
      totalRegions: 0,
      totalRecords: 0,
      avgDecibel: 0,
      maxDecibel: 0,
      minDecibel: 0,
    );
  }
}
