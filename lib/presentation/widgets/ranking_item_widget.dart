import 'package:flutter/material.dart';
import '../viewmodels/noise_ranking_viewmodel.dart';
import '../../data/models/region_noise_model.dart';

class RankingItemWidget extends StatelessWidget {
  final RankingItemModel item;
  final RankingType rankingType;
  final VoidCallback? onTap;

  const RankingItemWidget({
    Key? key,
    required this.item,
    required this.rankingType,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 순위 표시
              _buildRankBadge(context),
              const SizedBox(width: 16),

              // 메인 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.metadata.address,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          '소음지수',
                          item.noiseIndex.toStringAsFixed(1),
                          _getNoiseIndexColor(item.noiseIndex),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          '기록수',
                          '${item.totalRecords}건',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 순위 변동 표시
              if (item.hasRankingChange) _buildRankingChange(context),

              // 화살표
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (item.rank <= 3) {
      // 상위 3위는 특별한 색상
      switch (item.rank) {
        case 1:
          backgroundColor = Colors.amber; // 금메달
          break;
        case 2:
          backgroundColor = Colors.grey[400]!; // 은메달
          break;
        case 3:
          backgroundColor = Colors.brown[400]!; // 동메달
          break;
        default:
          backgroundColor = Theme.of(context).primaryColor;
      }
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.black87;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '${item.rank}',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingChange(BuildContext context) {
    final isUp = item.rankingUp;
    final color = isUp ? Colors.red : Colors.blue;
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '${item.change.abs()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNoiseIndexColor(double noiseIndex) {
    if (noiseIndex >= 80) {
      return Colors.red;
    } else if (noiseIndex >= 60) {
      return Colors.orange;
    } else if (noiseIndex >= 40) {
      return Colors.yellow[700]!;
    } else {
      return Colors.green;
    }
  }
}
