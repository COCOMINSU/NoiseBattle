# 모듈 1: 실시간 소음 측정 모듈 개발 계획

이 모듈은 스마트폰 마이크를 이용해 주변 소음 수준을 측정하고, 이를 사용자에게 시각적으로 보여주는 기능을 담당합니다.

## 1. 기술 원리 (어떻게 소리를 측정할까?)
1.  **마이크 입력:** 스마트폰의 마이크는 주변의 소리(음파, 공기의 압력 변화)를 아날로그 전기 신호로 변환합니다.
2.  **디지털 변환:** 이 아날로그 신호는 스마트폰 내부에서 아주 짧은 시간 간격으로 샘플링되어 디지털 데이터(숫자의 연속)로 바뀝니다.
3.  **진폭(Amplitude) 계산:** 변환된 디지털 데이터의 각 숫자 값은 해당 순간의 소리 크기(진폭)를 나타냅니다.
4.  **데시벨(Decibel) 변환:** 진폭 값은 사람이 실제 느끼는 소리의 크기와 비례하지 않습니다. 사람은 소리를 로그(log) 스케일로 인지하기 때문에, 측정된 진폭 값을 데시벨($dB$)이라는 단위로 변환해야 합니다. 이 변환 과정은 보통 라이브러리가 대신 처리해 줍니다.
    - **중요:** 스마트폰 마이크는 전문적인 소음 측정 장비가 아니므로, 측정값은 법적 효력이 없는 **상대적인 참고값**이라는 점을 반드시 앱 내에 명시해야 합니다.

## 2. 구현 알고리즘 (어떤 순서로 만들까?)
1.  **권한 요청:** 앱 시작 시 사용자에게 '마이크 접근 권한'을 요청하고 승인받습니다.
2.  **소음 측정기 초기화:** 소음 측정 라이브러리를 초기화하고, 데이터 스트림(Stream)을 구독(listen)할 준비를 합니다.
3.  **측정 시작:** 사용자가 '측정' 버튼을 누르면, 데이터 스트림 구독을 시작합니다.
4.  **데이터 처리 및 UI 업데이트:** 데이터가 들어올 때마다, 해당 데이터를 $dB$ 값으로 변환하고, 화면의 UI를 업데이트하여 실시간으로 보여줍니다.
5.  **측정 중지:** 사용자가 '중지' 버튼을 누르면, 데이터 스트림 구독을 취소하여 마이크 사용을 중지하고 배터리 소모를 막습니다.

## 3. 추천 라이브러리 및 핵심 코드 예시 (Flutter)
- **라이브러리 추가 (`pubspec.yaml`):**
    ```yaml
    dependencies:
      noise_meter: ^3.0.0 # 최신 버전 확인
      permission_handler: ^10.0.0 # 권한 관리를 위한 라이브러리
    ```

- **핵심 코드 예시 (`noise_meter_widget.dart`):**
    ```dart
    import 'dart:async';
    import 'package:flutter/material.dart';
    import 'package:noise_meter/noise_meter.dart';
    import 'package:permission_handler/permission_handler.dart';

    class NoiseMeterWidget extends StatefulWidget {
      @override
      _NoiseMeterWidgetState createState() => _NoiseMeterWidgetState();
    }

    class _NoiseMeterWidgetState extends State<NoiseMeterWidget> {
      NoiseReading? _latestReading;
      StreamSubscription<NoiseReading>? _noiseSubscription;
      NoiseMeter? _noiseMeter;
      bool _isRecording = false;

      @override
      void initState() {
        super.initState();
        _noiseMeter = NoiseMeter(onError);
      }

      @override
      void dispose() {
        _noiseSubscription?.cancel();
        super.dispose();
      }

      void onData(NoiseReading noiseReading) {
        setState(() {
          _latestReading = noiseReading;
        });
      }

      void onError(Object error) {
        print(error.toString());
        stop();
      }

      Future<void> start() async {
        var status = await Permission.microphone.request();
        if (status.isGranted) {
          setState(() => _isRecording = true);
          _noiseSubscription = _noiseMeter?.noise.listen(onData);
        }
      }

      void stop() {
        _noiseSubscription?.cancel();
        setState(() => _isRecording = false);
      }

      @override
      Widget build(BuildContext context) {
        final dbValue = _latestReading?.meanDecibel.toStringAsFixed(2) ?? '0.00';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('현재 소음: $dbValue dB', style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? stop : start,
              child: Text(_isRecording ? '측정 중지' : '측정 시작'),
            ),
          ],
        );
      }
    }
    ```