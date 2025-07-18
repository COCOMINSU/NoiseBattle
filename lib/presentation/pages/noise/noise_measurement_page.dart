import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noise_recording_viewmodel.dart';
import '../../widgets/file_name_input_dialog.dart';
import 'recording_list_page.dart';
import 'package:flutter/foundation.dart'; // kDebugMode 추가
import 'package:permission_handler/permission_handler.dart'; // openAppSettings 추가

/// 소음 측정 화면
///
/// 주요 기능:
/// - 실시간 데시벨 표시
/// - 시각적 소음 레벨 인디케이터
/// - 녹음 시작/중지 제어
/// - 측정 통계 표시
/// - 법적 고지사항
class NoiseMeasurementPage extends StatefulWidget {
  const NoiseMeasurementPage({super.key});

  @override
  State<NoiseMeasurementPage> createState() => _NoiseMeasurementPageState();
}

class _NoiseMeasurementPageState extends State<NoiseMeasurementPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // 펄스 애니메이션 (측정 중일 때)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 웨이브 애니메이션
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0 * math.pi,
    ).animate(_waveController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = NoiseRecordingViewModel();
        // 페이지 진입 시 바로 위치 정보 가져오기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.refreshLocation();
        });
        return viewModel;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('소음 측정'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showInfoDialog,
              tooltip: '측정 안내',
            ),
          ],
        ),
        body: Consumer<NoiseRecordingViewModel>(
          builder: (context, viewModel, child) {
            // 애니메이션 제어
            if (viewModel.isRecording) {
              _pulseController.repeat(reverse: true);
              _waveController.repeat();
            } else {
              _pulseController.stop();
              _waveController.stop();
            }

            return SafeArea(
              child: Column(
                children: [
                  // 메인 콘텐츠 영역 (스크롤 가능)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // 상단 여백 (측정 영역을 화면 중앙으로 이동)
                          const SizedBox(height: 40),

                          // 메인 측정 영역
                          _buildMeasurementArea(context, viewModel),

                          const SizedBox(height: 10),
                          // 통계 정보
                          if (viewModel.hasMeasurements)
                            _buildStatistics(context, viewModel),

                          const SizedBox(height: 20),

                          // 법적 고지
                          _buildLegalNotice(context),

                          // 하단 여백 (버튼과 겹치지 않도록)
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // 하단 고정 버튼 영역
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: _buildControlButton(context, viewModel),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 메인 측정 영역 구성
  Widget _buildMeasurementArea(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // GPS 위치 정보
          _buildLocationInfo(context, viewModel),

          const SizedBox(height: 20),

          // 데시벨 표시
          _buildDecibelDisplay(context, viewModel),

          const SizedBox(height: 24),

          // 소음 레벨 설명
          Text(
            viewModel.currentNoiseDescription,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Color(viewModel.currentNoiseColor),
              fontWeight: FontWeight.w600,
            ),
          ),

          // 녹음 중 표시
          if (viewModel.isRecording) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '녹음중 • ${viewModel.formattedDuration}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10), //
          // 시각적 인디케이터
          _buildVisualIndicator(context, viewModel),

          const SizedBox(height: 10), //
          // 에러 메시지
          if (viewModel.error != null) _buildErrorMessage(context, viewModel),
        ],
      ),
    );
  }

  /// 데시벨 숫자 표시
  Widget _buildDecibelDisplay(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: viewModel.isRecording ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(viewModel.currentNoiseColor).withOpacity(0.1),
              border: Border.all(
                color: Color(viewModel.currentNoiseColor),
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.currentDecibel.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Color(viewModel.currentNoiseColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'dB',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Color(viewModel.currentNoiseColor),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// GPS 위치 정보 표시
  Widget _buildLocationInfo(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    final address = viewModel.currentAddress;

    if (address == null || address.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              '위치 정보 없음',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 주소에서 시, 구, 동 추출
    final addressParts = _parseAddress(address);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            addressParts,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 주소에서 시, 구, 동 추출 (한국 주소 체계 완전 지원)
  String _parseAddress(String fullAddress) {
    // 주소를 공백으로 분리
    final parts = fullAddress.split(' ');

    // 주소 구성 요소 찾기
    String? sido, sigungu, dong;

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];

      // 1단계: 특별시/광역시/도/특별자치도 찾기
      if (sido == null && _isSido(part)) {
        sido = part;
      }
      // 2단계: 시/군/구/자치구 찾기
      else if (sigungu == null && _isSigungu(part)) {
        sigungu = part;
      }
      // 3단계: 읍/면/동/가 찾기 (동이 우선)
      else if (dong == null && _isDong(part)) {
        dong = part;
      }
    }

    // 동이 없으면 읍/면 찾기
    if (dong == null) {
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (_isEupMyeon(part)) {
          dong = part;
          break;
        }
      }
    }

    // 결과 조합
    final result = <String>[];
    if (sido != null) result.add(sido);
    if (sigungu != null) result.add(sigungu);
    if (dong != null) result.add(dong);

    return result.isEmpty ? fullAddress : result.join(' ');
  }

  /// 시/도 판별
  bool _isSido(String part) {
    return part.endsWith('시') ||
        part.endsWith('도') ||
        part.endsWith('특별시') ||
        part.endsWith('광역시') ||
        part.endsWith('특별자치도') ||
        part.endsWith('특별자치시');
  }

  /// 시/군/구 판별
  bool _isSigungu(String part) {
    return part.endsWith('구') ||
        part.endsWith('군') ||
        part.endsWith('시') ||
        part.endsWith('자치구');
  }

  /// 동 판별
  bool _isDong(String part) {
    return part.endsWith('동') || part.endsWith('가');
  }

  /// 읍/면 판별
  bool _isEupMyeon(String part) {
    return part.endsWith('읍') || part.endsWith('면');
  }

  /// 시각적 인디케이터 (웨이브 형태)
  Widget _buildVisualIndicator(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return SizedBox(
      height: 60,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 60),
            painter: WavePainter(
              animationValue: _waveAnimation.value,
              amplitude: viewModel.currentDecibel / 100.0,
              color: Color(viewModel.currentNoiseColor),
              isRecording: viewModel.isRecording,
            ),
          );
        },
      ),
    );
  }

  /// 제어 버튼
  Widget _buildControlButton(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Row(
      children: [
        // 측정 시작/중지 버튼
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading
                ? null
                : (viewModel.isRecording
                      ? () => _stopRecording(context, viewModel)
                      : () => _startRecording(context, viewModel)),
            icon: viewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(viewModel.isRecording ? Icons.stop : Icons.mic),
            label: Text(
              viewModel.isLoading
                  ? '처리 중...'
                  : (viewModel.isRecording ? '녹음을 마치고 저장하기' : '녹음 시작'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: viewModel.isRecording
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        if (viewModel.hasMeasurements && !viewModel.isRecording) ...[
          const SizedBox(width: 12),
          // 초기화 버튼
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: viewModel.resetMeasurements,
              icon: const Icon(Icons.refresh),
              label: const Text('초기화'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 통계 정보 표시
  Widget _buildStatistics(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '측정 통계',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '최대',
                '${viewModel.maxDecibel.toStringAsFixed(1)} dB',
                Colors.red,
              ),
              _buildStatItem(
                context,
                '평균',
                '${viewModel.avgDecibel.toStringAsFixed(1)} dB',
                Colors.blue,
              ),
              _buildStatItem(
                context,
                '최소',
                '${viewModel.minDecibel.toStringAsFixed(1)} dB',
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '측정 횟수: ${viewModel.measurementCount}회 '
            '(${viewModel.sessionDurationSeconds}초)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 에러 메시지
  Widget _buildErrorMessage(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: viewModel.clearError,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// 법적 고지
  Widget _buildLegalNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '※ 측정값은 법적 효력이 없는 참고용 데이터입니다.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 녹음 시작
  Future<void> _startRecording(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) async {
    try {
      // 파일명 없이 녹음 시작 (임시 파일명 사용)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      viewModel.setFileName('noise_$timestamp');

      await viewModel.startRecording();
    } catch (e) {
      if (context.mounted) {
        // 권한 관련 에러인 경우 설정 안내
        if (e.toString().contains('권한')) {
          _showPermissionDialog(context, e.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('녹음 시작 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 권한 안내 다이얼로그
  void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('권한 필요'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              '소음 측정을 위해 다음 권한이 필요합니다:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 🎤 마이크: 소음 측정을 위해 필요'),
            const Text('• 📍 위치: 측정 위치 기록을 위해 필요'),
            const Text('• 💾 오디오: 녹음 파일 저장을 위해 권장'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '설정에서 권한을 허용하시겠습니까?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // 앱 설정으로 이동
              await _openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 앱 설정 페이지로 이동
  Future<void> _openAppSettings() async {
    try {
      // permission_handler 패키지의 openAppSettings 사용
      await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('앱 설정 열기 실패: $e');
      }
    }
  }

  /// 녹음 중지 및 저장
  Future<void> _stopRecording(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) async {
    try {
      // 즉시 녹음 중지
      await viewModel.stopRecording();

      // 파일명 입력 다이얼로그 표시
      if (context.mounted) {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => FileNameInputDialog(
            initialFileName: '',
            currentLocation: viewModel.currentPosition,
          ),
        );

        if (result != null) {
          // 파일명과 설정 적용
          viewModel.setFileName(result['fileName']);
          if (result['title'] != null) {
            viewModel.setCustomTitle(result['title']);
          }
          viewModel.setIsPublic(result['isPublic'] ?? false);

          // 아파트인증 체크 시 GPS 확인
          if (result['isApartmentVerified'] == true) {
            final isLocationValid = await _validateApartmentLocation(viewModel);
            if (!isLocationValid) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('아파트 주소와 GPS 위치가 일치하지 않아 저장할 수 없습니다'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          }

          // 저장 완료 처리
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('녹음이 저장되었습니다'),
                backgroundColor: Colors.green,
              ),
            );

            // 녹음 목록 화면으로 이동
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RecordingListPage(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('녹음 처리 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 아파트 위치 검증
  Future<bool> _validateApartmentLocation(
    NoiseRecordingViewModel viewModel,
  ) async {
    if (viewModel.currentPosition != null && viewModel.currentAddress != null) {
      final address = viewModel.currentAddress!.toLowerCase();
      // 아파트 관련 키워드 확인
      final isApartment =
          address.contains('아파트') ||
          address.contains('apt') ||
          address.contains('단지') ||
          address.contains('동');

      // GPS 정확도 확인 (100m 이내)
      final hasGoodAccuracy = viewModel.currentPosition!.accuracy <= 100;

      return isApartment && hasGoodAccuracy;
    }

    return false;
  }

  /// 정보 다이얼로그 표시
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('소음 측정 안내'),
        content: const SingleChildScrollView(
          child: Text(
            '• 스마트폰 마이크를 이용한 참고용 측정입니다.\n'
            '• 정확한 측정을 위해 조용한 환경에서 측정하세요.\n'
            '• 스마트폰을 소음원 방향으로 향하게 하세요.\n'
            '• 측정 중에는 스마트폰을 움직이지 마세요.\n'
            '• 법적 분쟁 시에는 공인 측정기관을 이용하세요.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 웨이브 페인터 (시각적 효과)
class WavePainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final Color color;
  final bool isRecording;

  WavePainter({
    required this.animationValue,
    required this.amplitude,
    required this.color,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isRecording) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;

    // 웨이브 그리기
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final waveY =
          centerY +
          math.sin((normalizedX * 4 * math.pi) + animationValue) *
              amplitude *
              20;

      if (x == 0) {
        path.moveTo(x, waveY);
      } else {
        path.lineTo(x, waveY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
