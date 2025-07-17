import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noise_recording_viewmodel.dart';
import '../../widgets/file_name_input_dialog.dart';
import '../../widgets/location_info_widget.dart';
import '../../widgets/upload_progress_widget.dart';
import '../../widgets/recording_list_widget.dart';

/// 소음 녹음 및 파일 관리 화면
///
/// 주요 기능:
/// - 실시간 소음 측정 + 오디오 녹음
/// - 사용자 정의 파일명으로 저장
/// - GPS 위치 정보 자동 수집 및 표시
/// - Firebase Storage 업로드 진행률 표시
/// - 개인 녹음 목록 관리
/// - 종합적인 에러 처리 및 사용자 피드백
class NoiseRecordingPage extends StatefulWidget {
  const NoiseRecordingPage({super.key});

  @override
  State<NoiseRecordingPage> createState() => _NoiseRecordingPageState();
}

class _NoiseRecordingPageState extends State<NoiseRecordingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // 펄스 애니메이션 (녹음 중일 때)
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
      create: (context) => NoiseRecordingViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('소음 녹음'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () => _showRecordingList(context),
              tooltip: '녹음 목록',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
              tooltip: '녹음 안내',
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
                  // 메인 콘텐츠 영역
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // 메인 측정 영역 (dB 값 표시)
                          _buildMeasurementArea(context, viewModel),

                          const SizedBox(height: 20),

                          // 위치 정보 영역
                          LocationInfoWidget(viewModel: viewModel),

                          const SizedBox(height: 20),

                          // 업로드 진행률 (업로드 중일 때만 표시)
                          if (viewModel.isUploading)
                            UploadProgressWidget(viewModel: viewModel),

                          const SizedBox(height: 20),

                          // 통계 정보 (측정 데이터가 있을 때만 표시)
                          if (viewModel.hasMeasurements)
                            _buildStatistics(context, viewModel),
                        ],
                      ),
                    ),
                  ),

                  // 하단 제어 영역
                  _buildBottomControls(context, viewModel),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 녹음 상태 표시
            if (viewModel.isRecording)
              _buildRecordingStatus(context, viewModel),

            const SizedBox(height: 20),

            // 데시벨 표시
            _buildDecibelDisplay(context, viewModel),

            const SizedBox(height: 20),

            // 소음 레벨 설명
            Text(
              viewModel.currentNoiseDescription,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Color(viewModel.currentNoiseColor),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            // 시각적 인디케이터
            _buildVisualIndicator(context, viewModel),

            const SizedBox(height: 20),

            // 에러 메시지들
            _buildErrorMessages(context, viewModel),
          ],
        ),
      ),
    );
  }

  /// 녹음 상태 표시
  Widget _buildRecordingStatus(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Container(
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
            '녹음 중 • ${viewModel.formattedDuration}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  /// 시각적 인디케이터 (웨이브 효과)
  Widget _buildVisualIndicator(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 60,
          width: double.infinity,
          child: CustomPaint(
            painter: WavePainter(
              animationValue: _waveAnimation.value,
              amplitude: viewModel.currentDecibel / 100.0,
              color: Color(viewModel.currentNoiseColor),
              isActive: viewModel.isRecording,
            ),
          ),
        );
      },
    );
  }

  /// 에러 메시지들
  Widget _buildErrorMessages(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    final errors = <String>[];

    if (viewModel.error != null) {
      errors.add(viewModel.error!);
    }
    if (viewModel.locationError != null) {
      errors.add('위치: ${viewModel.locationError!}');
    }
    if (viewModel.uploadError != null) {
      errors.add('업로드: ${viewModel.uploadError!}');
    }

    if (errors.isEmpty) return const SizedBox.shrink();

    return Column(
      children: errors
          .map(
            (error) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      if (error == viewModel.error) {
                        viewModel.clearError();
                      }
                      if (error.startsWith('위치:')) {
                        viewModel.clearLocationError();
                      }
                      if (error.startsWith('업로드:')) {
                        viewModel.clearUploadError();
                      }
                    },
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// 통계 정보
  Widget _buildStatistics(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, size: 20),
                const SizedBox(width: 8),
                Text(
                  '측정 통계',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '최대',
                  '${viewModel.maxDecibel.toStringAsFixed(1)} dB',
                ),
                _buildStatItem(
                  context,
                  '평균',
                  '${viewModel.avgDecibel.toStringAsFixed(1)} dB',
                ),
                _buildStatItem(
                  context,
                  '최소',
                  '${viewModel.minDecibel.toStringAsFixed(1)} dB',
                ),
                _buildStatItem(context, '측정', '${viewModel.measurementCount}회'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// 하단 제어 영역
  Widget _buildBottomControls(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 위치 새로고침 버튼
          IconButton(
            onPressed: viewModel.isRecording
                ? null
                : () => viewModel.refreshLocation(),
            icon: viewModel.isLocationLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.location_on),
            tooltip: '위치 새로고침',
          ),

          const SizedBox(width: 16),

          // 메인 제어 버튼
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: viewModel.isRecording
                        ? () => _stopRecording(context, viewModel)
                        : () => _startRecording(context, viewModel),
                    icon: Icon(
                      viewModel.isRecording
                          ? Icons.stop
                          : Icons.fiber_manual_record,
                    ),
                    label: Text(viewModel.isRecording ? '녹음 중지' : '녹음 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: viewModel.isRecording
                          ? Colors.red
                          : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ),

          const SizedBox(width: 16),

          // 초기화 버튼
          IconButton(
            onPressed: viewModel.isRecording
                ? null
                : () => viewModel.resetMeasurements(),
            icon: const Icon(Icons.refresh),
            tooltip: '측정값 초기화',
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
      await viewModel.startRecording();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('녹음이 시작되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('녹음 시작 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 녹음 중지
  Future<void> _stopRecording(
    BuildContext context,
    NoiseRecordingViewModel viewModel,
  ) async {
    try {
      // 파일명 입력 다이얼로그 먼저 표시
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

          // 이제 녹음을 중지하고 저장
          await viewModel.stopRecording();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('녹음이 저장되었습니다'),
                backgroundColor: Colors.green,
              ),
            );

            // 녹음 목록 화면으로 이동
            _showRecordingList(context);
          }
        } else {
          // 사용자가 취소한 경우 - 녹음 중지만 하고 저장하지 않음
          // TODO: 임시 녹음 파일 삭제 로직 필요
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('녹음이 취소되었습니다'),
                backgroundColor: Colors.grey,
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
    // GPS 좌표와 주소 정보를 비교하여 아파트 위치 검증
    // 실제 구현에서는 주소 파싱 및 좌표 비교 로직이 필요
    // 현재는 간단한 예시로 구현

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

  /// 녹음 목록 표시
  void _showRecordingList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            RecordingListWidget(scrollController: scrollController),
      ),
    );
  }

  /// 정보 다이얼로그 표시
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('소음 녹음 안내'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• 소음 측정과 동시에 오디오 파일이 녹음됩니다'),
              SizedBox(height: 8),
              Text('• 파일명을 지정하여 개인 저장소에 저장됩니다'),
              SizedBox(height: 8),
              Text('• GPS 위치 정보가 자동으로 수집됩니다'),
              SizedBox(height: 8),
              Text('• 공개 설정 시 다른 사용자도 볼 수 있습니다'),
              SizedBox(height: 8),
              Text('• 마이크와 위치 권한이 필요합니다'),
              SizedBox(height: 16),
              Text('주의사항', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• 정확한 측정을 위해 기기를 소음원 근처에 두세요'),
              SizedBox(height: 4),
              Text('• 법적 분쟁에 활용할 수 있는 증거자료로 활용하세요'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 웨이브 애니메이션을 그리는 커스텀 페인터
class WavePainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final Color color;
  final bool isActive;

  WavePainter({
    required this.animationValue,
    required this.amplitude,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveHeight = size.height * 0.3 * amplitude.clamp(0.1, 1.0);
    final waveLength = size.width / 4;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          size.height / 2 +
          waveHeight *
              math.sin((x / waveLength + animationValue) * 2 * math.pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.isActive != isActive;
  }
}
