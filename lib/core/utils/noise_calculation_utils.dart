import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/region_noise_model.dart';

class NoiseCalculationUtils {
  // 소음 지수 계산 (0-100 스케일)
  static double calculateNoiseIndex({
    required int totalRecords,
    required double avgDecibel,
    required double maxDecibel,
    int daysSpan = 30,
  }) {
    // 기록 수 가중치 (최대 30점)
    final recordWeight = _calculateRecordWeight(totalRecords, daysSpan);

    // 평균 데시벨 가중치 (최대 40점)
    final avgDecibelWeight = _calculateAvgDecibelWeight(avgDecibel);

    // 최고 데시벨 가중치 (최대 30점)
    final maxDecibelWeight = _calculateMaxDecibelWeight(maxDecibel);

    final noiseIndex = recordWeight + avgDecibelWeight + maxDecibelWeight;
    return min(100.0, max(0.0, noiseIndex));
  }

  // 기록 수 가중치 계산
  static double _calculateRecordWeight(int totalRecords, int daysSpan) {
    // 일평균 기록 수 계산
    final avgRecordsPerDay = totalRecords / daysSpan;

    // 기준: 하루 3건 이상이면 만점 (30점)
    final weight = (avgRecordsPerDay / 3.0) * 30;
    return min(30.0, weight);
  }

  // 평균 데시벨 가중치 계산
  static double _calculateAvgDecibelWeight(double avgDecibel) {
    // 기준: 40dB 이하는 0점, 80dB 이상은 만점 (40점)
    if (avgDecibel <= 40) return 0.0;
    if (avgDecibel >= 80) return 40.0;

    return ((avgDecibel - 40) / 40) * 40;
  }

  // 최고 데시벨 가중치 계산
  static double _calculateMaxDecibelWeight(double maxDecibel) {
    // 기준: 60dB 이하는 0점, 120dB 이상은 만점 (30점)
    if (maxDecibel <= 60) return 0.0;
    if (maxDecibel >= 120) return 30.0;

    return ((maxDecibel - 60) / 60) * 30;
  }

  // 소음 심각도 등급 계산
  static NoiseLevel calculateNoiseLevel(double noiseIndex) {
    if (noiseIndex >= 80) return NoiseLevel.critical;
    if (noiseIndex >= 60) return NoiseLevel.high;
    if (noiseIndex >= 40) return NoiseLevel.moderate;
    if (noiseIndex >= 20) return NoiseLevel.low;
    return NoiseLevel.minimal;
  }

  // 순위 변동 계산
  static int calculateRankingChange(
    List<RankingItemModel> previousRanking,
    List<RankingItemModel> currentRanking,
    String itemId,
  ) {
    final previousIndex = previousRanking.indexWhere(
      (item) => item.id == itemId,
    );
    final currentIndex = currentRanking.indexWhere((item) => item.id == itemId);

    if (previousIndex == -1 || currentIndex == -1) return 0;

    // 순위는 1부터 시작하므로 +1
    final previousRank = previousIndex + 1;
    final currentRank = currentIndex + 1;

    return previousRank - currentRank; // 양수면 상승, 음수면 하락
  }

  // 시간대별 패턴 분석
  static Map<String, dynamic> analyzeTimePatterns(
    Map<String, int> hourlyDistribution,
  ) {
    if (hourlyDistribution.isEmpty) {
      return {
        'peakHours': <String>[],
        'quietHours': <String>[],
        'totalRecords': 0,
        'peakIntensity': 0.0,
      };
    }

    final sortedHours = hourlyDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalRecords = hourlyDistribution.values.reduce((a, b) => a + b);
    final averageRecords = totalRecords / 24;

    // 피크 시간대 (평균의 150% 이상)
    final peakThreshold = averageRecords * 1.5;
    final peakHours = sortedHours
        .where((entry) => entry.value >= peakThreshold)
        .map((entry) => '${entry.key}시')
        .take(6)
        .toList();

    // 조용한 시간대 (평균의 50% 이하)
    final quietThreshold = averageRecords * 0.5;
    final quietHours = sortedHours
        .where((entry) => entry.value <= quietThreshold)
        .map((entry) => '${entry.key}시')
        .take(6)
        .toList();

    // 피크 강도 (최고값과 평균값의 비율)
    final maxRecords = sortedHours.first.value;
    final peakIntensity = maxRecords / averageRecords;

    return {
      'peakHours': peakHours,
      'quietHours': quietHours,
      'totalRecords': totalRecords,
      'peakIntensity': peakIntensity,
    };
  }

  // 주간 트렌드 분석
  static Map<String, dynamic> analyzeWeeklyTrend(
    List<double> dailyAverages, // 최근 7일간의 일평균 데시벨
  ) {
    if (dailyAverages.length < 7) {
      return {
        'trend': 'insufficient_data',
        'changePercent': 0.0,
        'isIncreasing': false,
        'isDecreasing': false,
      };
    }

    final firstHalf = dailyAverages.take(3).toList();
    final secondHalf = dailyAverages.skip(4).take(3).toList();

    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    final changePercent = ((secondAvg - firstAvg) / firstAvg) * 100;

    String trend;
    if (changePercent.abs() < 5) {
      trend = 'stable';
    } else if (changePercent > 0) {
      trend = 'increasing';
    } else {
      trend = 'decreasing';
    }

    return {
      'trend': trend,
      'changePercent': changePercent,
      'isIncreasing': changePercent > 5,
      'isDecreasing': changePercent < -5,
      'firstHalfAvg': firstAvg,
      'secondHalfAvg': secondAvg,
    };
  }

  // 지역 유사도 계산 (같은 특성을 가진 지역 찾기)
  static double calculateRegionSimilarity(
    RegionNoiseModel region1,
    RegionNoiseModel region2,
  ) {
    // 평균 데시벨 유사도 (가중치 40%)
    final decibelSimilarity =
        1 - (region1.avgDecibel - region2.avgDecibel).abs() / 100;

    // 기록 수 유사도 (가중치 30%)
    final maxRecords = max(region1.totalRecords, region2.totalRecords);
    final minRecords = min(region1.totalRecords, region2.totalRecords);
    final recordSimilarity = maxRecords > 0 ? minRecords / maxRecords : 1.0;

    // 시간 패턴 유사도 (가중치 30%)
    final timePatternSimilarity = _calculateTimePatternSimilarity(
      region1.hourlyDistribution,
      region2.hourlyDistribution,
    );

    return (decibelSimilarity * 0.4) +
        (recordSimilarity * 0.3) +
        (timePatternSimilarity * 0.3);
  }

  // 시간 패턴 유사도 계산
  static double _calculateTimePatternSimilarity(
    Map<String, int> pattern1,
    Map<String, int> pattern2,
  ) {
    if (pattern1.isEmpty || pattern2.isEmpty) return 0.0;

    double similarity = 0.0;
    int commonHours = 0;

    for (int hour = 0; hour < 24; hour++) {
      final count1 = pattern1[hour.toString()] ?? 0;
      final count2 = pattern2[hour.toString()] ?? 0;

      if (count1 > 0 || count2 > 0) {
        final maxCount = max(count1, count2);
        final minCount = min(count1, count2);
        similarity += minCount / maxCount;
        commonHours++;
      }
    }

    return commonHours > 0 ? similarity / commonHours : 0.0;
  }

  // 계절별 조정 팩터 계산
  static double getSeasonalAdjustmentFactor(DateTime date) {
    final month = date.month;

    // 겨울(12-2월): 창문을 닫는 경우가 많아 소음이 적게 측정될 수 있음
    if (month == 12 || month <= 2) return 1.1;

    // 여름(6-8월): 창문을 여는 경우가 많아 소음이 많이 측정될 수 있음
    if (month >= 6 && month <= 8) return 0.95;

    // 봄/가을: 보통
    return 1.0;
  }

  // 시간대별 가중치 계산
  static double getTimeAdjustmentFactor(DateTime dateTime) {
    final hour = dateTime.hour;

    // 심야 시간대 (22시-06시): 높은 가중치 (소음이 더 민감함)
    if (hour >= 22 || hour <= 6) return 1.3;

    // 오전 시간대 (07시-09시): 보통 가중치
    if (hour >= 7 && hour <= 9) return 1.0;

    // 주간 시간대 (10시-18시): 낮은 가중치
    if (hour >= 10 && hour <= 18) return 0.8;

    // 저녁 시간대 (19시-21시): 보통 가중치
    return 1.0;
  }

  // 모의 데이터 생성 (테스트용)
  static List<RegionNoiseModel> generateMockRegionData() {
    final random = Random();
    final regions = <RegionNoiseModel>[];
    final now = DateTime.now();

    final mockRegions = [
      {'sido': '서울특별시', 'sigungu': '강남구', 'eupmyeondong': '역삼동'},
      {'sido': '서울특별시', 'sigungu': '서초구', 'eupmyeondong': '서초동'},
      {'sido': '서울특별시', 'sigungu': '송파구', 'eupmyeondong': '잠실동'},
      {'sido': '서울특별시', 'sigungu': '마포구', 'eupmyeondong': '홍대동'},
      {'sido': '부산광역시', 'sigungu': '해운대구', 'eupmyeondong': '우동'},
      {'sido': '대구광역시', 'sigungu': '중구', 'eupmyeondong': '동성로'},
      {'sido': '인천광역시', 'sigungu': '연수구', 'eupmyeondong': '송도동'},
      {'sido': '광주광역시', 'sigungu': '서구', 'eupmyeondong': '치평동'},
      {'sido': '대전광역시', 'sigungu': '유성구', 'eupmyeondong': '봉명동'},
      {'sido': '울산광역시', 'sigungu': '남구', 'eupmyeondong': '삼산동'},
    ];

    for (int i = 0; i < mockRegions.length; i++) {
      final regionData = mockRegions[i];
      final totalRecords = 50 + random.nextInt(200);
      final avgDecibel = 45.0 + random.nextDouble() * 35; // 45-80dB
      final maxDecibel = avgDecibel + 5 + random.nextDouble() * 15;

      // 시간대별 분포 생성
      final hourlyDistribution = <String, int>{};
      for (int hour = 0; hour < 24; hour++) {
        // 심야/새벽 시간대는 적게, 주간 시간대는 많게
        int baseCount = 2;
        if (hour >= 8 && hour <= 22) baseCount = 5;
        if (hour >= 19 && hour <= 21) baseCount = 8; // 저녁 시간대 피크

        hourlyDistribution[hour.toString()] = baseCount + random.nextInt(10);
      }

      final regionKey =
          "${regionData['sido']}_${regionData['sigungu']}_${regionData['eupmyeondong']}";

      regions.add(
        RegionNoiseModel(
          regionKey: regionKey,
          sido: regionData['sido']!,
          sigungu: regionData['sigungu']!,
          eupmyeondong: regionData['eupmyeondong']!,
          totalRecords: totalRecords,
          avgDecibel: avgDecibel,
          maxDecibel: maxDecibel,
          totalDecibel: avgDecibel * totalRecords,
          hourlyDistribution: hourlyDistribution,
          weeklyTrend: WeeklyTrendModel(
            currentWeek: avgDecibel,
            previousWeek: avgDecibel + (random.nextDouble() - 0.5) * 10,
            changePercent: (random.nextDouble() - 0.5) * 20,
          ),
          topNoiseTypes: [
            NoiseTypeModel(
              type: 'footstep',
              count: 20,
              avgDecibel: avgDecibel - 5,
            ),
            NoiseTypeModel(
              type: 'music',
              count: 15,
              avgDecibel: avgDecibel + 2,
            ),
            NoiseTypeModel(
              type: 'conversation',
              count: 10,
              avgDecibel: avgDecibel - 8,
            ),
          ],
          lastUpdated: now.subtract(Duration(minutes: random.nextInt(60))),
          createdAt: now.subtract(Duration(days: 30)),
        ),
      );
    }

    return regions;
  }
}

// 소음 레벨 열거형
enum NoiseLevel {
  minimal, // 0-19: 최소
  low, // 20-39: 낮음
  moderate, // 40-59: 보통
  high, // 60-79: 높음
  critical, // 80-100: 심각
}

extension NoiseLevelExtension on NoiseLevel {
  String get displayName {
    switch (this) {
      case NoiseLevel.minimal:
        return '최소';
      case NoiseLevel.low:
        return '낮음';
      case NoiseLevel.moderate:
        return '보통';
      case NoiseLevel.high:
        return '높음';
      case NoiseLevel.critical:
        return '심각';
    }
  }

  Color get color {
    switch (this) {
      case NoiseLevel.minimal:
        return const Color(0xFF4CAF50); // Green
      case NoiseLevel.low:
        return const Color(0xFF8BC34A); // Light Green
      case NoiseLevel.moderate:
        return const Color(0xFFFFEB3B); // Yellow
      case NoiseLevel.high:
        return const Color(0xFFFF9800); // Orange
      case NoiseLevel.critical:
        return const Color(0xFFF44336); // Red
    }
  }
}
