import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/noise_recording_viewmodel.dart';
import '../../data/models/noise_record_model.dart';

/// 녹음 목록 표시 위젯
///
/// 사용자의 개인 녹음 목록을 표시하고 관리하는 위젯
class RecordingListWidget extends StatefulWidget {
  final ScrollController scrollController;

  const RecordingListWidget({super.key, required this.scrollController});

  @override
  State<RecordingListWidget> createState() => _RecordingListWidgetState();
}

class _RecordingListWidgetState extends State<RecordingListWidget> {
  String _searchQuery = '';
  List<NoiseRecordModel> _filteredRecords = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<NoiseRecordingViewModel>(
      builder: (context, viewModel, child) {
        // 검색 필터링
        if (_searchQuery.isEmpty) {
          _filteredRecords = viewModel.userRecords;
        } else {
          _filteredRecords = viewModel.userRecords.where((record) {
            final query = _searchQuery.toLowerCase();
            return record.fileName.toLowerCase().contains(query) ||
                (record.customTitle?.toLowerCase().contains(query) ?? false) ||
                (record.description?.toLowerCase().contains(query) ?? false);
          }).toList();
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '내 녹음 목록',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '${viewModel.userRecords.length}개',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 검색 바
                    TextField(
                      decoration: InputDecoration(
                        hintText: '파일명, 제목, 설명으로 검색...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // 목록
              Expanded(
                child: viewModel.isLoadingRecords
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecords.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = _filteredRecords[index];
                          return _buildRecordItem(context, record, viewModel);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.audio_file : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? '아직 녹음된 파일이 없습니다' : '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? '첫 번째 소음 녹음을 시작해보세요!' : '다른 키워드로 검색해보세요',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(
    BuildContext context,
    NoiseRecordModel record,
    NoiseRecordingViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRecordDetails(context, record),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (제목/파일명 + 메뉴)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.displayTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (record.customTitle != null)
                          Text(
                            record.fileName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          _confirmDelete(context, record, viewModel);
                          break;
                        case 'details':
                          _showRecordDetails(context, record);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20),
                            SizedBox(width: 8),
                            Text('상세 정보'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('삭제', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 정보 행들
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    record.formattedDuration,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.file_copy, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    record.formattedFileSize,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(
                    record.isPublic ? Icons.public : Icons.lock,
                    size: 16,
                    color: record.isPublic ? Colors.green : Colors.grey[600],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 측정 통계
              Row(
                children: [
                  Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '평균 ${record.averageDecibel.toStringAsFixed(1)}dB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '최대 ${record.maxDecibel.toStringAsFixed(1)}dB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 위치 정보 (있을 때만)
              if (record.address != null)
                Row(
                  children: [
                    Icon(Icons.place, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.address!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // 날짜
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(record.recordedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetails(BuildContext context, NoiseRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.displayTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('파일명', record.fileName),
              if (record.customTitle != null)
                _buildDetailRow('제목', record.customTitle!),
              if (record.description != null)
                _buildDetailRow('설명', record.description!),
              _buildDetailRow('녹음 시간', record.formattedDuration),
              _buildDetailRow('파일 크기', record.formattedFileSize),
              _buildDetailRow(
                '평균 데시벨',
                '${record.averageDecibel.toStringAsFixed(1)} dB',
              ),
              _buildDetailRow(
                '최대 데시벨',
                '${record.maxDecibel.toStringAsFixed(1)} dB',
              ),
              _buildDetailRow(
                '최소 데시벨',
                '${record.minDecibel.toStringAsFixed(1)} dB',
              ),
              if (record.latitude != null && record.longitude != null)
                _buildDetailRow(
                  'GPS 좌표',
                  '${record.latitude!.toStringAsFixed(6)}, ${record.longitude!.toStringAsFixed(6)}',
                ),
              if (record.address != null)
                _buildDetailRow('주소', record.address!),
              _buildDetailRow('공개 설정', record.isPublic ? '공개' : '비공개'),
              _buildDetailRow('녹음 날짜', _formatFullDate(record.recordedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    NoiseRecordModel record,
    NoiseRecordingViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('녹음 삭제'),
        content: Text(
          '정말로 "${record.displayTitle}" 녹음을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await viewModel.deleteRecord(record.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('녹음이 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
