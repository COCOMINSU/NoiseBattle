import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noise_viewmodel.dart';

/// 소음 측정 화면
///
/// 주요 기능:
/// - 실시간 데시벨 표시
/// - 시각적 소음 레벨 인디케이터
/// - 측정 시작/중지 제어
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
      create: (context) => NoiseViewModel(),
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
        body: Consumer<NoiseViewModel>(
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 메인 측정 영역
                    Expanded(
                      flex: 3,
                      child: _buildMeasurementArea(context, viewModel),
                    ),

                    const SizedBox(height: 20),

                    // 제어 버튼
                    _buildControlButton(context, viewModel),

                    const SizedBox(height: 20),

                    // 통계 정보
                    if (viewModel.hasMeasurements)
                      Expanded(
                        flex: 1,
                        child: _buildStatistics(context, viewModel),
                      ),

                    // 법적 고지
                    _buildLegalNotice(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 메인 측정 영역 구성
  Widget _buildMeasurementArea(BuildContext context, NoiseViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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

          // 에러 메시지
          if (viewModel.error != null) _buildErrorMessage(context, viewModel),
        ],
      ),
    );
  }

  /// 데시벨 숫자 표시
  Widget _buildDecibelDisplay(BuildContext context, NoiseViewModel viewModel) {
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

  /// 시각적 인디케이터 (웨이브 형태)
  Widget _buildVisualIndicator(BuildContext context, NoiseViewModel viewModel) {
    return SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 100),
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
  Widget _buildControlButton(BuildContext context, NoiseViewModel viewModel) {
    return Row(
      children: [
        // 측정 시작/중지 버튼
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading
                ? null
                : (viewModel.isRecording
                      ? viewModel.stopRecording
                      : viewModel.startRecording),
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
                  : (viewModel.isRecording ? '측정 중지' : '측정 시작'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: viewModel.isRecording
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
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
  Widget _buildStatistics(BuildContext context, NoiseViewModel viewModel) {
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
  Widget _buildErrorMessage(BuildContext context, NoiseViewModel viewModel) {
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
