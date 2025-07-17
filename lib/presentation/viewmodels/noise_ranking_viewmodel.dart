import 'package:flutter/material.dart';
import '../../core/services/noise_map_service.dart';
import '../../data/models/region_noise_model.dart';

class NoiseRankingViewModel extends ChangeNotifier {
  final NoiseMapService _noiseMapService = NoiseMapService();

  // 랭킹 데이터
  RankingModel? _regionRanking;
  RankingModel? _apartmentRanking;
  RankingModel? _userRanking;

  // UI 상태
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'daily';
  RankingType _selectedRankingType = RankingType.region;

  // Getters
  RankingModel? get regionRanking => _regionRanking;
  RankingModel? get apartmentRanking => _apartmentRanking;
  RankingModel? get userRanking => _userRanking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;
  RankingType get selectedRankingType => _selectedRankingType;

  // 현재 선택된 랭킹 데이터
  RankingModel? get currentRanking {
    switch (_selectedRankingType) {
      case RankingType.region:
        return _regionRanking;
      case RankingType.apartment:
        return _apartmentRanking;
      case RankingType.user:
        return _userRanking;
    }
  }

  // 초기 데이터 로드
  Future<void> loadInitialData() async {
    await Future.wait([
      loadRegionRanking(),
      loadApartmentRanking(),
      loadUserRanking(),
    ]);
  }

  // 지역별 랭킹 로드
  Future<void> loadRegionRanking() async {
    try {
      _setLoading(true);
      _error = null;

      _regionRanking = await _noiseMapService.getRegionRanking(_selectedPeriod);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 아파트별 랭킹 로드
  Future<void> loadApartmentRanking() async {
    try {
      _apartmentRanking = await _noiseMapService.getApartmentRanking(
        _selectedPeriod,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('아파트 랭킹 로드 실패: $e');
    }
  }

  // 사용자별 랭킹 로드
  Future<void> loadUserRanking() async {
    try {
      _userRanking = await _noiseMapService.getUserRanking(_selectedPeriod);
      notifyListeners();
    } catch (e) {
      debugPrint('사용자 랭킹 로드 실패: $e');
    }
  }

  // 기간 변경
  Future<void> changePeriod(String period) async {
    if (_selectedPeriod == period) return;

    _selectedPeriod = period;
    notifyListeners();

    await loadInitialData();
  }

  // 랭킹 타입 변경
  void changeRankingType(RankingType type) {
    if (_selectedRankingType == type) return;

    _selectedRankingType = type;
    notifyListeners();
  }

  // 데이터 새로고침
  Future<void> refresh() async {
    await loadInitialData();
  }

  // 랭킹 아이템 검색
  List<RankingItemModel> searchRankingItems(String query) {
    final ranking = currentRanking;
    if (ranking == null || query.isEmpty) {
      return ranking?.data ?? [];
    }

    final lowerQuery = query.toLowerCase();
    return ranking.data.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.metadata.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // 순위 변동 통계
  RankingChangeStats getRankingChangeStats() {
    final ranking = currentRanking;
    if (ranking == null) return RankingChangeStats.empty();

    int increasedCount = 0;
    int decreasedCount = 0;
    int stableCount = 0;

    for (final item in ranking.data) {
      if (item.rankingUp) {
        increasedCount++;
      } else if (item.rankingDown) {
        decreasedCount++;
      } else {
        stableCount++;
      }
    }

    return RankingChangeStats(
      increased: increasedCount,
      decreased: decreasedCount,
      stable: stableCount,
    );
  }

  // 상위 N개 랭킹 아이템
  List<RankingItemModel> getTopRankingItems(int count) {
    final ranking = currentRanking;
    if (ranking == null) return [];

    return ranking.data.take(count).toList();
  }

  // 특정 아이템 찾기
  RankingItemModel? findRankingItemById(String id) {
    final ranking = currentRanking;
    if (ranking == null) return null;

    try {
      return ranking.data.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // 랭킹 범위별 통계
  RankingSectionStats getRankingSectionStats() {
    final ranking = currentRanking;
    if (ranking == null) return RankingSectionStats.empty();

    final top10 = ranking.data.take(10);
    final middle = ranking.data.skip(10).take(40);
    final bottom = ranking.data.skip(50);

    double avgTop10 = 0;
    double avgMiddle = 0;
    double avgBottom = 0;

    if (top10.isNotEmpty) {
      avgTop10 =
          top10.map((e) => e.noiseIndex).reduce((a, b) => a + b) / top10.length;
    }

    if (middle.isNotEmpty) {
      avgMiddle =
          middle.map((e) => e.noiseIndex).reduce((a, b) => a + b) /
          middle.length;
    }

    if (bottom.isNotEmpty) {
      avgBottom =
          bottom.map((e) => e.noiseIndex).reduce((a, b) => a + b) /
          bottom.length;
    }

    return RankingSectionStats(
      top10Avg: avgTop10,
      middleAvg: avgMiddle,
      bottomAvg: avgBottom,
    );
  }

  // 기간별 이름 매핑
  String getPeriodDisplayName(String period) {
    switch (period) {
      case 'daily':
        return '일간';
      case 'weekly':
        return '주간';
      case 'monthly':
        return '월간';
      case 'yearly':
        return '연간';
      default:
        return period;
    }
  }

  // 랭킹 타입별 이름 매핑
  String getRankingTypeDisplayName(RankingType type) {
    switch (type) {
      case RankingType.region:
        return '지역별';
      case RankingType.apartment:
        return '아파트별';
      case RankingType.user:
        return '사용자별';
    }
  }

  // 공통 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// 랭킹 타입 열거형
enum RankingType { region, apartment, user }

// 순위 변동 통계 클래스
class RankingChangeStats {
  final int increased;
  final int decreased;
  final int stable;

  RankingChangeStats({
    required this.increased,
    required this.decreased,
    required this.stable,
  });

  factory RankingChangeStats.empty() {
    return RankingChangeStats(increased: 0, decreased: 0, stable: 0);
  }

  int get total => increased + decreased + stable;

  double get increasedPercentage => total > 0 ? (increased / total) * 100 : 0;
  double get decreasedPercentage => total > 0 ? (decreased / total) * 100 : 0;
  double get stablePercentage => total > 0 ? (stable / total) * 100 : 0;
}

// 랭킹 구간별 통계 클래스
class RankingSectionStats {
  final double top10Avg;
  final double middleAvg;
  final double bottomAvg;

  RankingSectionStats({
    required this.top10Avg,
    required this.middleAvg,
    required this.bottomAvg,
  });

  factory RankingSectionStats.empty() {
    return RankingSectionStats(top10Avg: 0, middleAvg: 0, bottomAvg: 0);
  }
}
