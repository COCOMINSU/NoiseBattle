import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/noise_recording_service.dart';
import '../../core/services/noise_record_service.dart';
import '../../data/models/noise_record_model.dart';

/// 소음 녹음 및 파일 관리 화면의 상태를 관리하는 확장된 ViewModel
///
/// 주요 기능:
/// - 기존 NoiseViewModel의 모든 기능
/// - 동시 오디오 녹음 및 파일 저장
/// - 사용자 정의 파일명 관리
/// - 위치 정보 표시 및 관리
/// - 업로드 진행률 추적
/// - 녹음 목록 관리 및 검색
/// - 종합적인 에러 처리
class NoiseRecordingViewModel extends ChangeNotifier {
  // 서비스 인스턴스들
  final NoiseRecordingService _recordingService = NoiseRecordingService();
  final NoiseRecordService _recordService = NoiseRecordService();

  // 구독 관리
  StreamSubscription<NoiseReading>? _noiseSubscription;
  StreamSubscription<String>? _errorSubscription;

  // 실시간 소음 측정 상태
  double _currentDecibel = 0.0;
  double _maxDecibel = 0.0;
  double _minDecibel = 100.0;
  double _avgDecibel = 0.0;
  final List<double> _measurements = [];
  int _measurementCount = 0;

  // 1초 간격 측정을 위한 변수들
  final List<double> _tempReadings = []; // 임시 측정값 저장
  DateTime? _lastProcessedTime; // 마지막 처리 시간

  // 녹음 세션 상태
  bool _isRecording = false;
  bool _isLoading = false;
  DateTime? _sessionStartTime;

  // 파일 관리 상태
  String _fileName = '';
  String? _customTitle;
  String? _description;
  List<String> _tags = [];
  bool _isPublic = false;

  // 위치 정보 상태
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLocationLoading = false;

  // 업로드 상태
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadStatus;

  // 녹음 목록 관리
  List<NoiseRecordModel> _userRecords = [];
  bool _isLoadingRecords = false;
  StreamSubscription<List<NoiseRecordModel>>? _recordsStreamSubscription;

  // 에러 상태
  String? _error;
  String? _locationError;
  String? _uploadError;

  // Public getters - 소음 측정 관련
  double get currentDecibel => _currentDecibel;
  double get maxDecibel => _maxDecibel;
  double get minDecibel => _minDecibel == 100.0 ? 0.0 : _minDecibel;
  double get avgDecibel => _avgDecibel;
  int get measurementCount => _measurementCount;
  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  DateTime? get sessionStartTime => _sessionStartTime;

  // Public getters - 파일 관리 관련
  String get fileName => _fileName;
  String? get customTitle => _customTitle;
  String? get description => _description;
  List<String> get tags => List.unmodifiable(_tags);
  bool get isPublic => _isPublic;

  // Public getters - 위치 정보 관련
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLocationLoading => _isLocationLoading;
  bool get hasLocation => _currentPosition != null;

  // Public getters - 업로드 관련
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get uploadStatus => _uploadStatus;

  // Public getters - 녹음 목록 관련
  List<NoiseRecordModel> get userRecords => List.unmodifiable(_userRecords);
  bool get isLoadingRecords => _isLoadingRecords;

  // Public getters - 에러 관련
  String? get error => _error;
  String? get locationError => _locationError;
  String? get uploadError => _uploadError;
  bool get hasAnyError =>
      _error != null || _locationError != null || _uploadError != null;

  // 계산된 속성들
  int get sessionDurationSeconds {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  String get currentNoiseDescription =>
      NoiseRecordingService.getNoiseDescription(_currentDecibel);

  int get currentNoiseColor =>
      NoiseRecordingService.getNoiseColor(_currentDecibel);

  bool get hasMeasurements => _measurements.isNotEmpty;

  String get formattedDuration {
    final duration = Duration(seconds: sessionDurationSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// ViewModel 초기화
  NoiseRecordingViewModel() {
    _initializeStreams();
    _loadUserRecords();
  }

  /// 스트림 초기화
  void _initializeStreams() {
    // 소음 데이터 스트림 구독
    _noiseSubscription = _recordingService.noiseStream.listen(
      _onNoiseReading,
      onError: _onNoiseError,
    );

    // 에러 스트림 구독
    _errorSubscription = _recordingService.errorStream.listen(_onServiceError);
  }

  /// 소음 데이터 수신 핸들러 (1초 간격으로 처리)
  void _onNoiseReading(NoiseReading reading) {
    // 현재 측정값을 임시 저장
    _tempReadings.add(reading.meanDecibel);

    // UI용 실시간 값 업데이트 (즉시 반영)
    _currentDecibel = reading.meanDecibel;

    // 1초마다 한 번씩만 처리
    final now = DateTime.now();
    if (_lastProcessedTime == null ||
        now.difference(_lastProcessedTime!).inMilliseconds >= 1000) {
      // 임시 측정값들의 평균 계산
      if (_tempReadings.isNotEmpty) {
        final avgReading =
            _tempReadings.reduce((a, b) => a + b) / _tempReadings.length;

        // 통계에 추가
        _measurementCount++;
        _measurements.add(avgReading);
        _updateStatistics();

        // 임시 측정값 초기화
        _tempReadings.clear();

        if (kDebugMode) {
          debugPrint(
            '📊 1초 측정 $_measurementCount회 - 평균: ${avgReading.toStringAsFixed(1)}dB (샘플 ${_tempReadings.length}개)',
          );
        }
      }

      _lastProcessedTime = now;
    }

    // UI 업데이트 (실시간)
    notifyListeners();
  }

  /// 소음 스트림 에러 핸들러
  void _onNoiseError(dynamic error) {
    _error = '소음 측정 중 오류가 발생했습니다: $error';
    _isRecording = false;
    notifyListeners();
  }

  /// 서비스 에러 핸들러
  void _onServiceError(String error) {
    _error = error;
    _isRecording = false;
    notifyListeners();
  }

  /// 통계 업데이트
  void _updateStatistics() {
    if (_measurements.isEmpty) return;

    if (_currentDecibel > _maxDecibel) {
      _maxDecibel = _currentDecibel;
    }

    if (_currentDecibel < _minDecibel) {
      _minDecibel = _currentDecibel;
    }

    final sum = _measurements.fold<double>(0.0, (sum, value) => sum + value);
    _avgDecibel = sum / _measurements.length;
  }

  /// 파일명 설정
  void setFileName(String fileName) {
    _fileName = fileName.trim();
    notifyListeners();
  }

  /// 사용자 지정 제목 설정
  void setCustomTitle(String? title) {
    _customTitle = title?.trim();
    notifyListeners();
  }

  /// 설명 설정
  void setDescription(String? description) {
    _description = description?.trim();
    notifyListeners();
  }

  /// 태그 추가
  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      _tags.add(trimmedTag);
      notifyListeners();
    }
  }

  /// 태그 제거
  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  /// 태그 목록 설정
  void setTags(List<String> tags) {
    _tags = tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    notifyListeners();
  }

  /// 공개/비공개 설정
  void setIsPublic(bool isPublic) {
    _isPublic = isPublic;
    notifyListeners();
  }

  /// 현재 위치 정보 새로고침
  Future<void> refreshLocation() async {
    _isLocationLoading = true;
    _locationError = null;
    notifyListeners();

    try {
      // NoiseRecordingService의 refreshLocation 메서드 사용 (카카오 API 포함)
      await _recordingService.refreshLocation();

      // 서비스에서 위치 정보 가져오기
      _currentPosition = _recordingService.currentPosition;
      _currentAddress = _recordingService.currentAddress;

      if (kDebugMode) {
        print(
          '📍 위치 새로고침 완료: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}',
        );
      }
    } catch (e) {
      _locationError = e.toString();
      if (kDebugMode) {
        print('❌ 위치 새로고침 실패: $e');
      }
    } finally {
      _isLocationLoading = false;
      notifyListeners();
    }
  }

  /// 좌표를 주소로 변환
  Future<void> _getAddressFromCoordinates() async {
    if (_currentPosition == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 대한민국 주소 체계: 시/도 + 시/군/구 + 읍/면/동 + 상세주소
        final addressParts = <String>[];

        // 1. 시/도 (administrativeArea)
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // 2. 시/군/구 (locality)
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // 3. 읍/면/동 (subLocality)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        // 4. 상세 주소 (thoroughfare, subThoroughfare)
        final detailAddress = <String>[];
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          detailAddress.add(place.thoroughfare!);
        }
        if (place.subThoroughfare != null &&
            place.subThoroughfare!.isNotEmpty) {
          detailAddress.add(place.subThoroughfare!);
        }
        if (detailAddress.isNotEmpty) {
          addressParts.add(detailAddress.join(' '));
        }

        _currentAddress = addressParts.join(' ');

        if (kDebugMode) {
          print('🏠 주소 변환 완료: $_currentAddress');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 주소 변환 실패: $e');
      }
      // 주소 변환 실패는 치명적이지 않으므로 계속 진행
    }
  }

  /// 녹음 시작
  Future<void> startRecording() async {
    if (_isRecording || _isLoading) return;

    // 파일명 검증
    if (_fileName.isEmpty) {
      _error = '파일명을 입력해주세요.';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _clearAllErrors();

      // 녹음 시작
      await _recordingService.startRecording(_fileName);

      // 상태 업데이트
      _isRecording = true;
      _sessionStartTime = DateTime.now();
      _resetStatistics();

      // 위치 정보 동기화
      _currentPosition = _recordingService.currentPosition;
      _currentAddress = _recordingService.currentAddress;

      if (kDebugMode) {
        print('🎙️ 녹음 시작: $_fileName');
      }
    } catch (e) {
      _error = e.toString();
      _isRecording = false;
      if (kDebugMode) {
        print('❌ 녹음 시작 실패: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 녹음 중지 및 저장
  Future<void> stopRecording() async {
    if (!_isRecording || _isLoading) return;

    try {
      _setLoading(true);
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = '녹음 중지 중...';
      notifyListeners();

      // 녹음 중지 및 업로드
      final recordingData = await _recordingService.stopRecording();

      if (recordingData.isEmpty) {
        throw Exception('녹음 데이터가 생성되지 않았습니다.');
      }

      _uploadStatus = 'Firestore에 저장 중...';
      _uploadProgress = 0.5;
      notifyListeners();

      // Firestore에 저장할 NoiseRecordModel 생성
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 측정 통계를 recordingData에 추가
      final enhancedData = Map<String, dynamic>.from(recordingData);
      enhancedData['measurements'] = {
        'duration': enhancedData['duration'],
        'fileSize': enhancedData['fileSize'],
        'averageDecibel': _avgDecibel,
        'maxDecibel': _maxDecibel,
        'minDecibel': minDecibel,
        'measurementCount': _measurementCount,
      };

      final record = NoiseRecordModel.fromRecordingData(
        userId: currentUser.uid,
        fileName: _fileName,
        recordingData: enhancedData,
        customTitle: _customTitle,
        description: _description,
        tags: _tags,
        isPublic: _isPublic,
      );

      _uploadStatus = '데이터베이스에 저장 중...';
      _uploadProgress = 0.8;
      notifyListeners();

      // Firestore에 저장
      await _recordService.createRecord(record);

      _uploadProgress = 1.0;
      _uploadStatus = '저장 완료!';

      // 상태 초기화
      _isRecording = false;
      _clearFileInputs();

      // 녹음 목록 새로고침
      await _loadUserRecords();

      if (kDebugMode) {
        print('✅ 녹음 저장 완료: $_fileName');
      }
    } catch (e) {
      _uploadError = e.toString();
      _isRecording = false;
      if (kDebugMode) {
        print('❌ 녹음 저장 실패: $e');
      }
    } finally {
      _setLoading(false);
      _isUploading = false;
      _uploadProgress = 0.0;
      _uploadStatus = null;
    }
  }

  /// 사용자 녹음 목록 로드
  Future<void> _loadUserRecords() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      _isLoadingRecords = true;
      notifyListeners();

      // 실시간 스트림으로 녹음 목록 구독
      _recordsStreamSubscription?.cancel();
      _recordsStreamSubscription = _recordService
          .getUserRecordsStream(currentUser.uid, limit: 50)
          .listen(
            (records) {
              _userRecords = records;
              _isLoadingRecords = false;
              notifyListeners();
            },
            onError: (error) {
              _error = '녹음 목록 로드 실패: $error';
              _isLoadingRecords = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _error = '녹음 목록 로드 실패: $e';
      _isLoadingRecords = false;
      notifyListeners();
    }
  }

  /// 특정 녹음 삭제
  Future<void> deleteRecord(String recordId) async {
    try {
      _setLoading(true);
      await _recordService.deleteRecord(recordId);

      if (kDebugMode) {
        print('🗑️ 녹음 삭제 완료: $recordId');
      }
    } catch (e) {
      _error = '녹음 삭제 실패: $e';
      if (kDebugMode) {
        print('❌ 녹음 삭제 실패: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 녹음 검색
  Future<List<NoiseRecordModel>> searchRecords(String query) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    try {
      return await _recordService.searchRecords(query, userId: currentUser.uid);
    } catch (e) {
      _error = '검색 실패: $e';
      notifyListeners();
      return [];
    }
  }

  /// 사용자 통계 가져오기
  Future<Map<String, dynamic>?> getUserStats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      return await _recordService.getUserStats(currentUser.uid);
    } catch (e) {
      _error = '통계 로드 실패: $e';
      notifyListeners();
      return null;
    }
  }

  /// 파일 입력 초기화
  void _clearFileInputs() {
    _fileName = '';
    _customTitle = null;
    _description = null;
    _tags.clear();
    _isPublic = false;
  }

  /// 측정 데이터 초기화
  void resetMeasurements() {
    _resetStatistics();
    notifyListeners();
  }

  /// 통계 초기화 (내부 메서드)
  void _resetStatistics() {
    _currentDecibel = 0.0;
    _maxDecibel = 0.0;
    _minDecibel = 100.0;
    _avgDecibel = 0.0;
    _measurementCount = 0;
    _measurements.clear();

    // 1초 간격 측정 변수들 초기화
    _tempReadings.clear();
    _lastProcessedTime = null;
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 모든 에러 클리어
  void _clearAllErrors() {
    _error = null;
    _locationError = null;
    _uploadError = null;
  }

  /// 특정 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  void clearUploadError() {
    _uploadError = null;
    notifyListeners();
  }

  /// 세션 요약 정보
  Map<String, dynamic> getSessionSummary() {
    return {
      'maxDecibel': _maxDecibel,
      'minDecibel': minDecibel,
      'avgDecibel': _avgDecibel,
      'measurementCount': _measurementCount,
      'durationSeconds': sessionDurationSeconds,
      'sessionStartTime': _sessionStartTime,
      'measurements': List<double>.from(_measurements),
      'fileName': _fileName,
      'customTitle': _customTitle,
      'description': _description,
      'tags': List<String>.from(_tags),
      'isPublic': _isPublic,
      'location': {'position': _currentPosition, 'address': _currentAddress},
    };
  }

  /// 리소스 정리
  @override
  void dispose() {
    if (kDebugMode) {
      print('🗑️ NoiseRecordingViewModel 리소스 정리 중...');
    }

    // 구독 해제
    _noiseSubscription?.cancel();
    _errorSubscription?.cancel();
    _recordsStreamSubscription?.cancel();

    // 서비스 정리
    _recordingService.dispose();

    super.dispose();
  }
}
