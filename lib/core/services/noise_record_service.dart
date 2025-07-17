import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/noise_record_model.dart';

/// 소음 녹음 데이터의 Firestore 관리 서비스
///
/// 주요 기능:
/// - CRUD 작업 (생성, 읽기, 업데이트, 삭제)
/// - 사용자별 녹음 목록 조회
/// - 공개/비공개 녹음 필터링
/// - 실시간 데이터 스트림 제공
class NoiseRecordService {
  static const String _collectionName = 'noise_records';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  /// 새 소음 녹음 레코드 생성
  ///
  /// [record]: 저장할 NoiseRecordModel (id는 무시됨)
  /// Returns: 생성된 문서의 ID
  Future<String> createRecord(NoiseRecordModel record) async {
    try {
      if (kDebugMode) {
        print('📝 소음 녹음 레코드 생성 중: ${record.fileName}');
      }

      final docRef = await _collection.add(record.toFirestore());

      if (kDebugMode) {
        print('✅ 소음 녹음 레코드 생성 완료: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 소음 녹음 레코드 생성 실패: $e');
      }
      throw Exception('녹음 데이터 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// ID로 특정 녹음 레코드 조회
  ///
  /// [recordId]: 조회할 문서 ID
  /// Returns: NoiseRecordModel 또는 null
  Future<NoiseRecordModel?> getRecord(String recordId) async {
    try {
      if (kDebugMode) {
        print('🔍 소음 녹음 레코드 조회 중: $recordId');
      }

      final doc = await _collection.doc(recordId).get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('⚠️ 녹음 레코드를 찾을 수 없습니다: $recordId');
        }
        return null;
      }

      final record = NoiseRecordModel.fromFirestore(doc);

      if (kDebugMode) {
        print('✅ 소음 녹음 레코드 조회 완료: ${record.fileName}');
      }

      return record;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 소음 녹음 레코드 조회 실패: $e');
      }
      throw Exception('녹음 데이터 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자별 녹음 목록 조회 (최신순)
  ///
  /// [userId]: 사용자 ID
  /// [limit]: 조회할 최대 개수 (기본값: 20)
  /// [includePrivate]: 비공개 녹음 포함 여부 (기본값: true)
  /// Returns: NoiseRecordModel 리스트
  Future<List<NoiseRecordModel>> getUserRecords(
    String userId, {
    int limit = 20,
    bool includePrivate = true,
  }) async {
    try {
      if (kDebugMode) {
        print('📋 사용자 녹음 목록 조회 중: $userId (limit: $limit)');
      }

      Query<Map<String, dynamic>> query = _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // 비공개 녹음 제외 옵션
      if (!includePrivate) {
        query = query.where('isPublic', isEqualTo: true);
      }

      final snapshot = await query.get();
      final records = snapshot.docs
          .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
          .toList();

      if (kDebugMode) {
        print('✅ 사용자 녹음 목록 조회 완료: ${records.length}개');
      }

      return records;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 사용자 녹음 목록 조회 실패: $e');
      }
      throw Exception('녹음 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 공개 녹음 목록 조회 (최신순)
  ///
  /// [limit]: 조회할 최대 개수 (기본값: 50)
  /// [tags]: 필터링할 태그 리스트 (빈 리스트면 모든 태그)
  /// Returns: 공개된 NoiseRecordModel 리스트
  Future<List<NoiseRecordModel>> getPublicRecords({
    int limit = 50,
    List<String> tags = const [],
  }) async {
    try {
      if (kDebugMode) {
        print('🌐 공개 녹음 목록 조회 중 (limit: $limit, tags: $tags)');
      }

      Query<Map<String, dynamic>> query = _collection
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // 태그 필터링
      if (tags.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: tags);
      }

      final snapshot = await query.get();
      final records = snapshot.docs
          .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
          .toList();

      if (kDebugMode) {
        print('✅ 공개 녹음 목록 조회 완료: ${records.length}개');
      }

      return records;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 공개 녹음 목록 조회 실패: $e');
      }
      throw Exception('공개 녹음 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 위치 근처의 녹음 목록 조회
  ///
  /// [latitude]: 중심점 위도
  /// [longitude]: 중심점 경도
  /// [radiusKm]: 반경 (킬로미터)
  /// [limit]: 조회할 최대 개수 (기본값: 30)
  /// Returns: 해당 지역의 NoiseRecordModel 리스트
  Future<List<NoiseRecordModel>> getRecordsNearLocation(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
    int limit = 30,
  }) async {
    try {
      if (kDebugMode) {
        print('📍 위치 기반 녹음 목록 조회 중: ($latitude, $longitude) 반경 ${radiusKm}km');
      }

      // Firestore에서는 지리적 쿼리를 위해 GeoPoint를 사용하거나
      // 간단한 범위 쿼리를 사용할 수 있습니다.
      // 여기서는 간단한 위도/경도 범위 쿼리를 사용합니다.

      final latRange = radiusKm / 111.0; // 대략적인 위도 1도 = 111km
      final lngRange = radiusKm / (111.0 * cos(latitude * pi / 180));

      final minLat = latitude - latRange;
      final maxLat = latitude + latRange;

      final snapshot = await _collection
          .where('isPublic', isEqualTo: true)
          .where('location.latitude', isGreaterThanOrEqualTo: minLat)
          .where('location.latitude', isLessThanOrEqualTo: maxLat)
          .orderBy('location.latitude')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // 경도 필터링은 클라이언트에서 수행 (Firestore 복합 쿼리 제한)
      final minLng = longitude - lngRange;
      final maxLng = longitude + lngRange;

      final records = snapshot.docs
          .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
          .where((record) {
            final lng = record.longitude;
            return lng != null && lng >= minLng && lng <= maxLng;
          })
          .toList();

      if (kDebugMode) {
        print('✅ 위치 기반 녹음 목록 조회 완료: ${records.length}개');
      }

      return records;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 위치 기반 녹음 목록 조회 실패: $e');
      }
      throw Exception('위치 기반 녹음 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 녹음 레코드 업데이트
  ///
  /// [recordId]: 업데이트할 문서 ID
  /// [updates]: 업데이트할 필드들
  Future<void> updateRecord(
    String recordId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (kDebugMode) {
        print('✏️ 소음 녹음 레코드 업데이트 중: $recordId');
      }

      await _collection.doc(recordId).update(updates);

      if (kDebugMode) {
        print('✅ 소음 녹음 레코드 업데이트 완료: $recordId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 소음 녹음 레코드 업데이트 실패: $e');
      }
      throw Exception('녹음 데이터 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 녹음 레코드 삭제
  ///
  /// [recordId]: 삭제할 문서 ID
  Future<void> deleteRecord(String recordId) async {
    try {
      if (kDebugMode) {
        print('🗑️ 소음 녹음 레코드 삭제 중: $recordId');
      }

      await _collection.doc(recordId).delete();

      if (kDebugMode) {
        print('✅ 소음 녹음 레코드 삭제 완료: $recordId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 소음 녹음 레코드 삭제 실패: $e');
      }
      throw Exception('녹음 데이터 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자의 녹음 목록 실시간 스트림
  ///
  /// [userId]: 사용자 ID
  /// [limit]: 조회할 최대 개수 (기본값: 20)
  /// Returns: NoiseRecordModel 리스트의 실시간 스트림
  Stream<List<NoiseRecordModel>> getUserRecordsStream(
    String userId, {
    int limit = 20,
  }) {
    try {
      if (kDebugMode) {
        print('🔄 사용자 녹음 목록 스트림 시작: $userId');
      }

      return _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
                .toList();
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ 사용자 녹음 목록 스트림 시작 실패: $e');
      }
      throw Exception('실시간 녹음 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 공개 녹음 목록 실시간 스트림
  ///
  /// [limit]: 조회할 최대 개수 (기본값: 50)
  /// Returns: 공개된 NoiseRecordModel 리스트의 실시간 스트림
  Stream<List<NoiseRecordModel>> getPublicRecordsStream({int limit = 50}) {
    try {
      if (kDebugMode) {
        print('🔄 공개 녹음 목록 스트림 시작');
      }

      return _collection
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
                .toList();
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ 공개 녹음 목록 스트림 시작 실패: $e');
      }
      throw Exception('실시간 공개 녹음 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 검색 기능 (제목, 설명, 태그 검색)
  ///
  /// [query]: 검색어
  /// [userId]: 특정 사용자로 제한 (null이면 모든 공개 녹음)
  /// [limit]: 조회할 최대 개수 (기본값: 30)
  /// Returns: 검색 결과 NoiseRecordModel 리스트
  Future<List<NoiseRecordModel>> searchRecords(
    String query, {
    String? userId,
    int limit = 30,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 녹음 검색 중: "$query"${userId != null ? " (사용자: $userId)" : ""}');
      }

      // Firestore의 텍스트 검색 제한으로 인해 클라이언트 필터링 사용
      Query<Map<String, dynamic>> firestoreQuery;

      if (userId != null) {
        firestoreQuery = _collection
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(limit * 2); // 여유분으로 더 많이 가져와서 필터링
      } else {
        firestoreQuery = _collection
            .where('isPublic', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .limit(limit * 2);
      }

      final snapshot = await firestoreQuery.get();
      final queryLower = query.toLowerCase();

      final filteredRecords = snapshot.docs
          .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
          .where((record) {
            // 제목, 설명, 태그에서 검색
            final titleMatch =
                record.customTitle?.toLowerCase().contains(queryLower) ?? false;
            final fileNameMatch = record.fileName.toLowerCase().contains(
              queryLower,
            );
            final descriptionMatch =
                record.description?.toLowerCase().contains(queryLower) ?? false;
            final tagsMatch = record.tags.any(
              (tag) => tag.toLowerCase().contains(queryLower),
            );

            return titleMatch || fileNameMatch || descriptionMatch || tagsMatch;
          })
          .take(limit)
          .toList();

      if (kDebugMode) {
        print('✅ 녹음 검색 완료: ${filteredRecords.length}개 결과');
      }

      return filteredRecords;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 녹음 검색 실패: $e');
      }
      throw Exception('녹음 검색 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 통계 조회
  ///
  /// [userId]: 사용자 ID
  /// Returns: 사용자의 녹음 통계 정보
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      if (kDebugMode) {
        print('📊 사용자 통계 조회 중: $userId');
      }

      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();

      final records = snapshot.docs
          .map((doc) => NoiseRecordModel.fromQuerySnapshot(doc))
          .toList();

      int totalRecords = records.length;
      int publicRecords = records.where((r) => r.isPublic).length;
      int privateRecords = totalRecords - publicRecords;

      int totalDuration = records.fold(
        0,
        (acc, r) => acc + r.durationInSeconds,
      );
      int totalFileSize = records.fold(0, (acc, r) => acc + r.fileSizeInBytes);

      final stats = {
        'totalRecords': totalRecords,
        'publicRecords': publicRecords,
        'privateRecords': privateRecords,
        'totalDurationSeconds': totalDuration,
        'totalFileSizeBytes': totalFileSize,
        'averageDurationSeconds': totalRecords > 0
            ? totalDuration / totalRecords
            : 0.0,
        'lastRecordedAt': records.isNotEmpty
            ? records.first.recordedAt.toIso8601String()
            : null,
      };

      if (kDebugMode) {
        print('✅ 사용자 통계 조회 완료: $totalRecords개 녹음');
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 사용자 통계 조회 실패: $e');
      }
      throw Exception('사용자 통계 조회 중 오류가 발생했습니다: $e');
    }
  }
}
