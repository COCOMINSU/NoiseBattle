import 'package:flutter/material.dart';
import '../viewmodels/noise_recording_viewmodel.dart';

/// 위치 정보 표시 위젯
///
/// GPS 좌표와 주소 정보를 카드 형태로 표시
class LocationInfoWidget extends StatelessWidget {
  final NoiseRecordingViewModel viewModel;

  const LocationInfoWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  viewModel.hasLocation
                      ? Icons.location_on
                      : Icons.location_off,
                  size: 20,
                  color: viewModel.hasLocation ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '위치 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (viewModel.isLocationLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (viewModel.hasLocation) ...[
              // GPS 좌표
              Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${viewModel.currentPosition!.latitude.toStringAsFixed(6)}, ${viewModel.currentPosition!.longitude.toStringAsFixed(6)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 주소 정보
              if (viewModel.currentAddress != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.currentAddress!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '주소 정보 없음',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // 위치 정확도
              Row(
                children: [
                  const Icon(Icons.my_location, size: 16, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    '정확도: ${viewModel.currentPosition!.accuracy.toStringAsFixed(1)}m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ] else ...[
              // 위치 정보가 없을 때
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '위치 정보 없음',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '아래 버튼을 눌러 현재 위치를 가져오세요',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 위치 에러 표시
            if (viewModel.locationError != null) ...[
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
                        viewModel.locationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
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
