import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noise_recording_viewmodel.dart';
import '../../widgets/recording_list_widget.dart';

/// 녹음 목록 전체 화면
///
/// 사용자의 녹음 파일 목록을 전체 화면으로 표시하는 페이지
class RecordingListPage extends StatelessWidget {
  const RecordingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoiseRecordingViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('내 녹음 목록'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // 녹음 목록 새로고침
                final viewModel = context.read<NoiseRecordingViewModel>();
                // TODO: 새로고침 메서드가 있다면 호출
              },
              tooltip: '새로고침',
            ),
          ],
        ),
        body: Consumer<NoiseRecordingViewModel>(
          builder: (context, viewModel, child) {
            return RecordingListWidget(scrollController: ScrollController());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 새 녹음하기 - 이전 페이지로 돌아가기
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.mic),
          tooltip: '새 녹음하기',
        ),
      ),
    );
  }
}
