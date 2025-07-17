import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import '../../core/services/noise_service.dart';

/// 소음 측정 화면의 상태를 관리하는 ViewModel
///
/// 주요 기능:
/// - 소음 측정 시작/중지 제어
/// - 실시간 소음 데이터 상태 관리
/// - 측정 통계 계산 (최대/최소/평균)
/// - 에러 상태 관리
class NoiseViewModel extends ChangeNotifier {
  // 소음 측정 서비스 인스턴스
  final NoiseService _noiseService = NoiseService();

  // 구독 관리
  StreamSubscription<NoiseReading>? _noiseSubscription;
  StreamSubscription<String>? _errorSubscription;

  // 현재 측정값
  double _currentDecibel = 0.0;

  // 통계값
  double _maxDecibel = 0.0;
  double _minDecibel = 100.0;
  double _avgDecibel = 0.0;

  // 측정 데이터 리스트 (평균 계산용)
  final List<double> _measurements = [];

  // 상태 관리
  bool _isRecording = false;
  bool _isLoading = false;
  String? _error;

  // 측정 세션 정보
  DateTime? _sessionStartTime;
  int _measurementCount = 0;

  // Public getters
  /// 현재 데시벨 값
  double get currentDecibel => _currentDecibel;

  /// 최대 데시벨 값
  double get maxDecibel => _maxDecibel;

  /// 최소 데시벨 값
  double get minDecibel => _minDecibel == 100.0 ? 0.0 : _minDecibel;

  /// 평균 데시벨 값
  double get avgDecibel => _avgDecibel;

  /// 현재 측정 중인지 여부
  bool get isRecording => _isRecording;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? get error => _error;

  /// 측정 횟수
  int get measurementCount => _measurementCount;

  /// 측정 세션 시작 시간
  DateTime? get sessionStartTime => _sessionStartTime;

  /// 측정 시간 (초)
  int get sessionDurationSeconds {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  /// 현재 데시벨에 대한 설명
  String get currentNoiseDescription =>
      NoiseService.getNoiseDescription(_currentDecibel);

  /// 현재 데시벨에 대한 색상
  int get currentNoiseColor => NoiseService.getNoiseColor(_currentDecibel);

  /// 측정값이 있는지 여부
  bool get hasMeasurements => _measurements.isNotEmpty;

  /// ViewModel 초기화
  NoiseViewModel() {
    _initializeStreams();
  }

  /// 스트림 초기화
  void _initializeStreams() {
    // 소음 데이터 스트림 구독
    _noiseSubscription = _noiseService.noiseStream.listen(
      _onNoiseReading,
      onError: _onNoiseError,
    );

    // 에러 스트림 구독
    _errorSubscription = _noiseService.errorStream.listen(_onServiceError);
  }

  /// 소음 데이터 수신 핸들러
  void _onNoiseReading(NoiseReading reading) {
    _currentDecibel = reading.meanDecibel;
    _measurementCount++;

    // 측정값 리스트에 추가
    _measurements.add(_currentDecibel);

    // 통계 업데이트
    _updateStatistics();

    // UI 업데이트
    notifyListeners();

    if (kDebugMode) {
      print(
        '📊 통계 업데이트 - 현재: ${_currentDecibel.toStringAsFixed(1)}dB, '
        '최대: ${_maxDecibel.toStringAsFixed(1)}dB, '
        '평균: ${_avgDecibel.toStringAsFixed(1)}dB',
      );
    }
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

    // 최대값 업데이트
    if (_currentDecibel > _maxDecibel) {
      _maxDecibel = _currentDecibel;
    }

    // 최소값 업데이트
    if (_currentDecibel < _minDecibel) {
      _minDecibel = _currentDecibel;
    }

    // 평균값 계산
    final sum = _measurements.fold<double>(0.0, (sum, value) => sum + value);
    _avgDecibel = sum / _measurements.length;
  }

  /// 소음 측정 시작
  Future<void> startRecording() async {
    if (_isRecording || _isLoading) return;

    try {
      _setLoading(true);
      _clearError();

      // 측정 시작
      await _noiseService.startRecording();

      // 상태 업데이트
      _isRecording = true;
      _sessionStartTime = DateTime.now();
      _resetStatistics();

      if (kDebugMode) {
        print('🎙️ 소음 측정 시작 - $_sessionStartTime');
      }
    } catch (e) {
      _error = e.toString();
      _isRecording = false;

      if (kDebugMode) {
        print('❌ 소음 측정 시작 실패: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 소음 측정 중지
  Future<void> stopRecording() async {
    if (!_isRecording || _isLoading) return;

    try {
      _setLoading(true);

      // 측정 중지
      await _noiseService.stopRecording();

      // 상태 업데이트
      _isRecording = false;

      if (kDebugMode) {
        print('⏹️ 소음 측정 중지 - 총 $_measurementCount개 측정값 수집');
        print(
          '📈 최종 통계: 최대 ${_maxDecibel.toStringAsFixed(1)}dB, '
          '최소 ${minDecibel.toStringAsFixed(1)}dB, '
          '평균 ${_avgDecibel.toStringAsFixed(1)}dB',
        );
      }
    } catch (e) {
      _error = e.toString();

      if (kDebugMode) {
        print('❌ 소음 측정 중지 실패: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 측정 데이터 초기화
  void resetMeasurements() {
    _resetStatistics();
    notifyListeners();

    if (kDebugMode) {
      print('🔄 측정 데이터 초기화됨');
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    _clearError();
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
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 클리어 (내부 메서드)
  void _clearError() {
    _error = null;
  }

  /// 측정 세션 요약 정보 가져오기
  Map<String, dynamic> getSessionSummary() {
    return {
      'maxDecibel': _maxDecibel,
      'minDecibel': minDecibel,
      'avgDecibel': _avgDecibel,
      'measurementCount': _measurementCount,
      'durationSeconds': sessionDurationSeconds,
      'sessionStartTime': _sessionStartTime,
      'measurements': List<double>.from(_measurements),
    };
  }

  /// 리소스 정리
  @override
  void dispose() {
    if (kDebugMode) {
      print('🗑️ NoiseViewModel 리소스 정리 중...');
    }

    // 구독 해제
    _noiseSubscription?.cancel();
    _errorSubscription?.cancel();

    // 서비스 정리
    _noiseService.dispose();

    super.dispose();
  }
}
