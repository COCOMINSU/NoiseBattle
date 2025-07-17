import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

/// 소음 측정을 관리하는 서비스 클래스
///
/// 주요 기능:
/// - 마이크 권한 요청 및 관리
/// - 소음 측정 시작/중지
/// - 실시간 소음 데이터 스트림 제공
/// - 측정 에러 처리
class NoiseService {
  // Private 멤버 변수들
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  // 소음 데이터 스트림 컨트롤러
  final StreamController<NoiseReading> _noiseController =
      StreamController<NoiseReading>.broadcast();

  // 에러 스트림 컨트롤러
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // 측정 상태
  bool _isRecording = false;

  // Public getters
  /// 소음 데이터 스트림
  Stream<NoiseReading> get noiseStream => _noiseController.stream;

  /// 에러 스트림
  Stream<String> get errorStream => _errorController.stream;

  /// 현재 측정 중인지 여부
  bool get isRecording => _isRecording;

  /// 마이크 권한 요청
  ///
  /// Returns: 권한이 허용되었는지 여부
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();

      if (kDebugMode) {
        print('🎤 마이크 권한 상태: $status');
      }

      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 마이크 권한 요청 실패: $e');
      }
      _errorController.add('마이크 권한 요청 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  /// 마이크 권한 상태 확인
  ///
  /// Returns: 현재 권한 상태
  Future<PermissionStatus> checkPermission() async {
    return await Permission.microphone.status;
  }

  /// 소음 측정 시작
  ///
  /// Throws: Exception if permission denied or measurement fails
  Future<void> startRecording() async {
    if (_isRecording) {
      if (kDebugMode) {
        print('⚠️ 이미 측정 중입니다.');
      }
      return;
    }

    try {
      // 권한 확인
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.');
      }

      // NoiseMeter 초기화
      _noiseMeter = NoiseMeter();

      // 소음 측정 구독 시작
      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading noiseReading) {
          if (kDebugMode) {
            print(
              '🔊 소음 측정값: ${noiseReading.meanDecibel.toStringAsFixed(1)} dB',
            );
          }
          _noiseController.add(noiseReading);
        },
        onError: (error) {
          if (kDebugMode) {
            print('❌ 소음 측정 스트림 에러: $error');
          }
          _errorController.add('소음 측정 중 오류가 발생했습니다: $error');
          stopRecording();
        },
      );

      _isRecording = true;

      if (kDebugMode) {
        print('✅ 소음 측정 시작됨');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 소음 측정 시작 실패: $e');
      }
      throw Exception('소음 측정을 시작할 수 없습니다: $e');
    }
  }

  /// 소음 측정 중지
  Future<void> stopRecording() async {
    if (!_isRecording) {
      if (kDebugMode) {
        print('⚠️ 측정 중이 아닙니다.');
      }
      return;
    }

    try {
      // 구독 해제
      await _noiseSubscription?.cancel();
      _noiseSubscription = null;

      // NoiseMeter 정리
      _noiseMeter = null;

      _isRecording = false;

      if (kDebugMode) {
        print('⏹️ 소음 측정 중지됨');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 소음 측정 중지 실패: $e');
      }
      _errorController.add('소음 측정 중지 중 오류가 발생했습니다: $e');
    }
  }

  /// 서비스 리소스 정리
  ///
  /// 앱 종료 또는 서비스 해제 시 호출
  void dispose() {
    if (kDebugMode) {
      print('🗑️ NoiseService 리소스 정리 중...');
    }

    stopRecording();
    _noiseController.close();
    _errorController.close();
  }

  /// 소음 레벨에 따른 설명 텍스트 반환
  ///
  /// [decibel]: 데시벨 값
  /// Returns: 소음 레벨 설명
  static String getNoiseDescription(double decibel) {
    if (decibel < 30) {
      return '매우 조용함';
    } else if (decibel < 40) {
      return '조용함';
    } else if (decibel < 50) {
      return '보통';
    } else if (decibel < 60) {
      return '약간 시끄러움';
    } else if (decibel < 70) {
      return '시끄러움';
    } else if (decibel < 80) {
      return '매우 시끄러움';
    } else {
      return '극도로 시끄러움';
    }
  }

  /// 소음 레벨에 따른 색상 코드 반환
  ///
  /// [decibel]: 데시벨 값
  /// Returns: 색상을 나타내는 정수 값
  static int getNoiseColor(double decibel) {
    if (decibel < 40) {
      return 0xFF4CAF50; // 초록색
    } else if (decibel < 60) {
      return 0xFFFFEB3B; // 노란색
    } else if (decibel < 80) {
      return 0xFFFF9800; // 주황색
    } else {
      return 0xFFF44336; // 빨간색
    }
  }
}
