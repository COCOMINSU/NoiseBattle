import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:record/record.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'kakao_address_service.dart';

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

      // 스토리지 권한 (Android API 레벨별 처리)
      PermissionStatus storageStatus = PermissionStatus.granted;

      if (Platform.isAndroid) {
        // Android 13+ (API 33+)에서는 오디오 파일 권한 사용
        if (await _getAndroidApiLevel() >= 33) {
          // Android 13+: 미디어별 세분화된 권한
          final audioStatus = await Permission.audio.request();
          storageStatus = audioStatus;

          if (kDebugMode) {
            print('📱 Android 13+ 오디오 권한: $audioStatus');
          }
        } else {
          // Android 12 이하: 기존 스토리지 권한
          storageStatus = await Permission.storage.request();

          if (kDebugMode) {
            print('📱 Android 12 이하 스토리지 권한: $storageStatus');
          }
        }

        // 권한이 거부되면 앱 설정으로 안내
        if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
          if (kDebugMode) {
            print('⚠️ 스토리지 권한이 거부됨. 앱 설정에서 권한을 허용해주세요.');
          }

          if (storageStatus.isPermanentlyDenied) {
            _errorController.add(
              '스토리지 권한이 영구적으로 거부되었습니다. 설정 > 앱 > 소음과 전쟁 > 권한에서 오디오 권한을 허용해주세요.',
            );
          } else {
            _errorController.add('오디오 파일 저장을 위해 스토리지 권한이 필요합니다.');
          }
        }
      }

      if (kDebugMode) {
        print('🎤 마이크 권한: $micStatus');
        print('📍 위치 권한: $locationStatus');
        print('💾 스토리지 권한: $storageStatus');
      }

      // 필수 권한: 마이크, 위치 (스토리지는 선택적)
      final essentialGranted = micStatus.isGranted && locationStatus.isGranted;
      final storageGranted = storageStatus.isGranted || storageStatus.isLimited;

      if (kDebugMode) {
        print('🔍 권한 검사 결과:');
        print('  - 마이크: ${micStatus.isGranted ? '✅ 허용됨' : '❌ 거부됨'} (필수)');
        print('  - 위치: ${locationStatus.isGranted ? '✅ 허용됨' : '❌ 거부됨'} (필수)');
        print('  - 스토리지: ${storageGranted ? '✅ 허용됨' : '⚠️ 제한됨'} (권장)');
      }

      if (!essentialGranted) {
        if (!micStatus.isGranted) {
          _errorController.add('소음 측정을 위해 마이크 권한이 필요합니다.');
        }
        if (!locationStatus.isGranted) {
          _errorController.add('위치 정보 수집을 위해 위치 권한이 필요합니다.');
        }
      }

      // 스토리지 권한이 없어도 내부 저장소 사용으로 진행 가능
      if (!storageGranted && kDebugMode) {
        print('ℹ️ 스토리지 권한 없음. 내부 저장소 사용으로 진행.');
      }

      return essentialGranted; // 마이크와 위치 권한만 필수
    } catch (e) {
      if (kDebugMode) {
        print('❌ 권한 요청 실패: $e');
      }
      _errorController.add('권한 요청 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  /// Android API 레벨 확인 (임시 구현)
  Future<int> _getAndroidApiLevel() async {
    if (Platform.isAndroid) {
      // 실제 구현에서는 device_info_plus 패키지를 사용하는 것이 좋습니다
      // 여기서는 간단히 Android 13+ 가정 (대부분의 최신 기기)
      return 33; // Android 13
    }
    return 0;
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

  /// 위치 정보만 새로고침 (녹음 없이)
  Future<void> refreshLocation() async {
    if (kDebugMode) {
      print('🔄 위치 정보 새로고침 시작...');
    }
    await _getCurrentLocation();
    if (kDebugMode) {
      print('🔄 위치 정보 새로고침 완료');
    }
  }

  /// 좌표를 대한민국 지번주소로 변환
  Future<void> _convertToAddress() async {
    if (_currentPosition == null) return;

    try {
      // 1. 카카오 API로 지번주소 시도 (가장 정확함)
      if (kDebugMode) {
        print('🗺️ 카카오 API 호출 시도...');
        print('🗺️ 카카오 API 키 설정 상태: ${KakaoAddressService.isApiKeyConfigured}');
        print(
          '🗺️ 카카오 API 키 길이: ${KakaoAddressService.isApiKeyConfigured ? '설정됨' : '설정되지 않음'}',
        );
      }

      // 카카오 API 강제 호출 (API 키 설정 여부와 관계없이)
      if (kDebugMode) {
        print('🗺️ 카카오 API 강제 호출 시도...');
      }

      final kakaoAddress = await KakaoAddressService.getJibunAddress(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (kakaoAddress != null && kakaoAddress.isNotEmpty) {
        _currentAddress = kakaoAddress;
        if (kDebugMode) {
          print('🏠 카카오 API 지번주소: $_currentAddress');
        }
        return;
      } else {
        if (kDebugMode) {
          print('❌ 카카오 API 호출 실패 또는 빈 결과');
        }
      }

      // 2. 카카오 API가 실패한 경우 geocoding 패키지 사용 (백업)
      if (kDebugMode) {
        print('⚠️ 카카오 API 실패, geocoding 패키지 사용');
      }

      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        localeIdentifier: 'ko_KR', // 한국어 로케일 설정
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 대한민국 지번주소 체계: 시/도 + 시/군/구 + 읍/면/동
        final addressParts = <String>[];

        // 1. 시/도 (administrativeArea)
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // 2. 시/군/구 (locality) - 지번주소에서는 "천안시 서북구" 형태로 올 수 있음
        if (place.locality != null && place.locality!.isNotEmpty) {
          final locality = place.locality!;

          // "천안시 서북구" 형태인지 확인하고 분리
          if (locality.contains('시') && locality.contains('구')) {
            // "천안시 서북구" -> "천안시" + "서북구"로 분리
            final parts = locality.split(' ');
            if (parts.length >= 2) {
              // 첫 번째 부분 (시/군)
              if (parts[0].contains('시') || parts[0].contains('군')) {
                addressParts.add(parts[0]);
              }
              // 두 번째 부분 (구)
              if (parts[1].contains('구')) {
                addressParts.add(parts[1]);
              }
            } else {
              // 분리할 수 없는 경우 그대로 사용
              addressParts.add(locality);
            }
          } else {
            // 단순 시/군/구인 경우
            addressParts.add(locality);
          }
        }

        // 3. 읍/면/동 (지번주소에서 가장 중요한 부분)
        String? subLocality = place.subLocality;

        // 지번주소에서는 name 필드에 "불당동" 같은 정보가 더 정확하게 들어있음
        if ((subLocality == null || subLocality.isEmpty) &&
            place.name != null &&
            place.name!.isNotEmpty) {
          final name = place.name!;

          // "불당동" 같은 형태에서 추출 (지번주소 형태)
          final match = RegExp(r'([가-힣]+(?:동|읍|면))').firstMatch(name);
          if (match != null) {
            subLocality = match.group(1);
          }

          // name에 동/읍/면이 포함되어 있지만 정규식으로 추출되지 않은 경우
          if (subLocality == null &&
              (name.contains('동') ||
                  name.contains('읍') ||
                  name.contains('면'))) {
            // 공백으로 분리해서 확인
            final nameParts = name.split(' ');
            for (final part in nameParts) {
              if (part.contains('동') ||
                  part.contains('읍') ||
                  part.contains('면')) {
                subLocality = part;
                break;
              }
            }
          }
        }

        // subLocality가 여전히 없으면 thoroughfare에서 추출 시도 (도로명주소에서)
        if ((subLocality == null || subLocality.isEmpty) &&
            place.thoroughfare != null &&
            place.thoroughfare!.isNotEmpty) {
          final thoroughfare = place.thoroughfare!;
          final match = RegExp(r'([가-힣]+(?:동|읍|면))').firstMatch(thoroughfare);
          if (match != null) {
            subLocality = match.group(1);
          }
        }

        if (subLocality != null && subLocality.isNotEmpty) {
          addressParts.add(subLocality);
        }

        // 4. 지번주소에서는 상세주소(도로명, 건물번호) 제외
        // 지번주소 형태: "충청남도 천안시 서북구 불당동"
        // 도로명주소 형태: "충청남도 천안시 서북구 불당동 불당로 123"
        //
        // 현재는 지번주소 형태로 표시하므로 상세주소는 제외
        // 필요시 아래 주석을 해제하여 도로명주소 형태로 변경 가능
        /*
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
        */

        _currentAddress = addressParts.join(' ');

        if (kDebugMode) {
          print('🏠 주소 변환 완료: $_currentAddress');
          print('📍 상세 주소 정보:');
          print('  - 시/도: ${place.administrativeArea}');
          print('  - 시/군/구: ${place.locality}');
          print('  - 읍/면/동: ${place.subLocality}');
          print('  - 도로명: ${place.thoroughfare}');
          print('  - 건물번호: ${place.subThoroughfare}');
          print('  - 우편번호: ${place.postalCode}');
          print('  - 전체 주소: ${place.toString()}');
          print('  - 이름: ${place.name}');
          print('  - ISO 국가 코드: ${place.isoCountryCode}');
          print('  - 국가: ${place.country}');
          print('  - 지명: ${place.locality}');
          print('  - 하위지역: ${place.subLocality}');
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

      // 현재 사용자 ID 가져오기
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('noise_records')
          .child(currentUser.uid)
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
