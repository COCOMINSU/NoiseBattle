import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

/// 소음 측정 및 녹음을 관리하는 확장된 서비스 클래스
///
/// 주요 기능:
/// - 기존 NoiseService의 모든 기능
/// - 동시 오디오 녹음 및 실시간 소음 측정
/// - GPS 위치 정보 수집 및 주소 변환
/// - Firebase Storage에 오디오 파일 업로드
/// - 사용자 지정 파일명으로 저장
class NoiseRecordingService {
  // 실시간 소음 측정 관련
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  final StreamController<NoiseReading> _noiseController =
      StreamController<NoiseReading>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // 오디오 녹음 관련
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;

  // 상태 관리
  bool _isRecording = false;
  DateTime? _recordingStartTime;

  // 위치 정보
  Position? _currentPosition;
  String? _currentAddress;

  // Public getters
  Stream<NoiseReading> get noiseStream => _noiseController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  /// 모든 필요한 권한 요청
  ///
  /// Returns: 모든 권한이 허용되었는지 여부
  Future<bool> requestAllPermissions() async {
    try {
      // 마이크 권한
      final micStatus = await Permission.microphone.request();

      // 위치 권한
      final locationStatus = await Permission.location.request();

      // 스토리지 권한 (Android)
      final storageStatus = Platform.isAndroid
          ? await Permission.storage.request()
          : PermissionStatus.granted;

      if (kDebugMode) {
        print('🎤 마이크 권한: $micStatus');
        print('📍 위치 권한: $locationStatus');
        print('💾 스토리지 권한: $storageStatus');
      }

      return micStatus.isGranted &&
          locationStatus.isGranted &&
          storageStatus.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 권한 요청 실패: $e');
      }
      _errorController.add('권한 요청 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  /// 녹음 시작 (실시간 측정 + 오디오 녹음 + 위치 수집)
  ///
  /// [fileName]: 저장할 파일명 (확장자 제외)
  Future<void> startRecording(String fileName) async {
    if (_isRecording) {
      if (kDebugMode) {
        print('⚠️ 이미 녹음 중입니다.');
      }
      return;
    }

    try {
      // 1. 권한 확인
      final hasPermissions = await requestAllPermissions();
      if (!hasPermissions) {
        throw Exception('필요한 권한이 없습니다. 설정에서 권한을 허용해주세요.');
      }

      // 2. 위치 정보 수집
      await _getCurrentLocation();

      // 3. 오디오 녹음 파일 경로 설정
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/${fileName}_$timestamp.m4a';

      // 4. 오디오 녹음 시작
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      // 5. 실시간 소음 측정 시작
      _noiseMeter = NoiseMeter();
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
      _recordingStartTime = DateTime.now();

      if (kDebugMode) {
        print('✅ 녹음 및 측정 시작됨');
        print('📁 파일 경로: $_currentRecordingPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 녹음 시작 실패: $e');
      }
      throw Exception('녹음을 시작할 수 없습니다: $e');
    }
  }

  /// 녹음 중지 및 파일 업로드
  ///
  /// Returns: 녹음 결과 데이터 (파일 URL, 메타데이터 등)
  Future<Map<String, dynamic>> stopRecording() async {
    if (!_isRecording) {
      if (kDebugMode) {
        print('⚠️ 녹음 중이 아닙니다.');
      }
      return {};
    }

    try {
      // 1. 오디오 녹음 중지
      final recordedFilePath = await _audioRecorder.stop();

      // 2. 실시간 측정 중지
      await _noiseSubscription?.cancel();
      _noiseSubscription = null;
      _noiseMeter = null;

      final duration = DateTime.now().difference(_recordingStartTime!);

      // 3. 파일이 제대로 생성되었는지 확인
      if (recordedFilePath == null || !File(recordedFilePath).existsSync()) {
        throw Exception('녹음 파일이 생성되지 않았습니다.');
      }

      // 4. Firebase Storage에 업로드
      final downloadUrl = await _uploadToFirebaseStorage(recordedFilePath);

      // 5. 결과 데이터 구성
      final recordData = {
        'audioFileUrl': downloadUrl,
        'localFilePath': recordedFilePath,
        'fileName': recordedFilePath.split('/').last.split('.').first,
        'duration': duration.inSeconds,
        'recordedAt': _recordingStartTime!.toIso8601String(),
        'location': {
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'address': _currentAddress,
          'accuracy': _currentPosition?.accuracy,
        },
        'fileSize': await File(recordedFilePath).length(),
      };

      // 6. 상태 초기화
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;

      if (kDebugMode) {
        print('✅ 녹음 완료 및 업로드 성공');
        print('🌐 다운로드 URL: $downloadUrl');
      }

      return recordData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 녹음 중지 실패: $e');
      }
      throw Exception('녹음 중지 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 위치 정보 수집
  Future<void> _getCurrentLocation() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('⚠️ 위치 서비스가 비활성화되어 있습니다.');
        }
        return;
      }

      // 현재 위치 가져오기
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print(
          '📍 위치 수집 완료: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}',
        );
      }

      // 역지오코딩으로 주소 변환
      await _convertToAddress();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 위치 수집 실패: $e');
      }
      // 위치 수집 실패는 치명적이지 않으므로 계속 진행
    }
  }

  /// 좌표를 주소로 변환
  Future<void> _convertToAddress() async {
    if (_currentPosition == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _currentAddress = [
          place.administrativeArea,
          place.locality,
          place.subLocality,
          place.street,
        ].where((e) => e != null && e.isNotEmpty).join(' ');

        if (kDebugMode) {
          print('🏠 주소 변환 완료: $_currentAddress');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 주소 변환 실패: $e');
      }
    }
  }

  /// Firebase Storage에 오디오 파일 업로드
  ///
  /// [filePath]: 업로드할 로컬 파일 경로
  /// Returns: 다운로드 URL
  Future<String> _uploadToFirebaseStorage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final ref = FirebaseStorage.instance
          .ref()
          .child('noise_records')
          .child(fileName);

      // 파일 메타데이터 설정
      final metadata = SettableMetadata(
        contentType: 'audio/mp4',
        customMetadata: {
          'recordedAt': _recordingStartTime?.toIso8601String() ?? '',
          'latitude': _currentPosition?.latitude.toString() ?? '',
          'longitude': _currentPosition?.longitude.toString() ?? '',
          'address': _currentAddress ?? '',
        },
      );

      // 업로드 실행
      final uploadTask = ref.putFile(file, metadata);

      // 업로드 진행 상황 모니터링 (선택사항)
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        final progress =
            taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        if (kDebugMode) {
          print('📤 업로드 진행률: ${(progress * 100).toStringAsFixed(1)}%');
        }
      });

      // 업로드 완료 대기
      await uploadTask;

      // 다운로드 URL 반환
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Storage 업로드 실패: $e');
      }
      throw Exception('파일 업로드 중 오류가 발생했습니다: $e');
    }
  }

  /// 서비스 리소스 정리
  void dispose() {
    if (kDebugMode) {
      print('🗑️ NoiseRecordingService 리소스 정리 중...');
    }

    if (_isRecording) {
      stopRecording().catchError((e) {
        if (kDebugMode) {
          print('❌ dispose 중 녹음 중지 실패: $e');
        }
        return <String, dynamic>{}; // Empty map as fallback
      });
    }

    _audioRecorder.dispose();
    _noiseController.close();
    _errorController.close();
  }

  /// 소음 레벨에 따른 설명 텍스트 반환 (기존 NoiseService와 동일)
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

  /// 소음 레벨에 따른 색상 코드 반환 (기존 NoiseService와 동일)
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
