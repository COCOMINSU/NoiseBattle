import 'package:flutter/material.dart';
import '../viewmodels/noise_ranking_viewmodel.dart';
import '../../data/models/region_noise_model.dart';

class RankingStatsWidget extends StatelessWidget {
  final RankingModel ranking;
  final RankingChangeStats changeStats;
  final RankingSectionStats sectionStats;

  const RankingStatsWidget({
    Key? key,
    required this.ranking,
    required this.changeStats,
    required this.sectionStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '랭킹 통계',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '최종 업데이트: ${_formatDateTime(ranking.lastUpdated)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 전체 통계
            _buildOverallStats(context),
            const SizedBox(height: 16),

            // 순위 변동 통계
            if (changeStats.total > 0) ...[
              _buildChangeStats(context),
              const SizedBox(height: 16),
            ],

            // 구간별 평균
            _buildSectionStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            '총 항목',
            '${ranking.data.length}개',
            Icons.list_alt,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            '최고 소음지수',
            ranking.data.isNotEmpty
                ? ranking.data.first.noiseIndex.toStringAsFixed(1)
                : '0.0',
            Icons.trending_up,
            Colors.red,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            '평균 소음지수',
            _calculateAverageNoiseIndex().toStringAsFixed(1),
            Icons.show_chart,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildChangeStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '순위 변동',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChangeStatItem(
                context,
                '상승',
                changeStats.increased,
                changeStats.increasedPercentage,
                Colors.red,
                Icons.arrow_upward,
              ),
            ),
            Expanded(
              child: _buildChangeStatItem(
                context,
                '하락',
                changeStats.decreased,
                changeStats.decreasedPercentage,
                Colors.blue,
                Icons.arrow_downward,
              ),
            ),
            Expanded(
              child: _buildChangeStatItem(
                context,
                '유지',
                changeStats.stable,
                changeStats.stablePercentage,
                Colors.grey,
                Icons.remove,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '구간별 평균 소음지수',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSectionStatItem(
                context,
                'TOP 10',
                sectionStats.top10Avg,
                Colors.red,
              ),
            ),
            Expanded(
              child: _buildSectionStatItem(
                context,
                '11-50위',
                sectionStats.middleAvg,
                Colors.orange,
              ),
            ),
            Expanded(
              child: _buildSectionStatItem(
                context,
                '51위 이하',
                sectionStats.bottomAvg,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChangeStatItem(
    BuildContext context,
    String label,
    int count,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStatItem(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  double _calculateAverageNoiseIndex() {
    if (ranking.data.isEmpty) return 0.0;

    final total = ranking.data
        .map((item) => item.noiseIndex)
        .reduce((a, b) => a + b);

    return total / ranking.data.length;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
