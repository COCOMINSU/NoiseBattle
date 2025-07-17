import 'package:flutter/material.dart';
import '../viewmodels/noise_recording_viewmodel.dart';

/// 업로드 진행률 표시 위젯
///
/// 파일 업로드 진행률과 상태를 표시하는 위젯
class UploadProgressWidget extends StatelessWidget {
  final NoiseRecordingViewModel viewModel;

  const UploadProgressWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (!viewModel.isUploading) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  viewModel.uploadProgress >= 1.0
                      ? Icons.cloud_done
                      : Icons.cloud_upload,
                  size: 20,
                  color: viewModel.uploadProgress >= 1.0
                      ? Colors.green
                      : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.uploadProgress >= 1.0 ? '업로드 완료' : '업로드 중',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: viewModel.uploadProgress >= 1.0
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(viewModel.uploadProgress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: viewModel.uploadProgress >= 1.0
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 진행률 바
            LinearProgressIndicator(
              value: viewModel.uploadProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                viewModel.uploadProgress >= 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 6,
            ),

            const SizedBox(height: 8),

            // 상태 메시지
            if (viewModel.uploadStatus != null)
              Row(
                children: [
                  if (viewModel.uploadProgress < 1.0) ...[
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      viewModel.uploadStatus!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: viewModel.uploadProgress >= 1.0
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

            // 업로드 에러 표시
            if (viewModel.uploadError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.uploadError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: viewModel.clearUploadError,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
