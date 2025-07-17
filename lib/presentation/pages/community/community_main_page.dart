import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'board_page.dart';
import '../../../data/models/post_model.dart';

class CommunityMainPage extends StatelessWidget {
  const CommunityMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(context),
            const SizedBox(height: 24),

            // 게시판 메뉴
            _buildBoardMenu(context),
            const SizedBox(height: 32),

            // 최근 인기 글
            _buildRecentPopularPosts(context),
            const SizedBox(height: 24),

            // 오늘의 베스트
            _buildTodaysBest(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '커뮤니티',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '소음 경험을 공유하고 해결책을 찾아보세요',
          style: TextStyle(fontSize: 16, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBoardMenu(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '게시판',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // 메인 게시판들 (2x2 그리드)
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildBoardCard(
              context,
              title: '소음 후기',
              description: '층간소음 경험담과\n해결 방법 공유',
              icon: Icons.volume_up,
              color: colors.primary,
              onTap: () => _navigateToBoardPage(
                context,
                BoardType.noiseReview,
                '소음 후기 게시판',
              ),
            ),
            _buildBoardCard(
              context,
              title: '우리 아파트',
              description: '같은 아파트\n주민들과 소통',
              icon: Icons.apartment,
              color: colors.accent,
              onTap: () => _navigateToBoardPage(
                context,
                BoardType.apartmentCommunity,
                '우리 아파트 모임',
              ),
            ),
            _buildBoardCard(
              context,
              title: '자유 게시판',
              description: '자유로운 주제로\n이야기해요',
              icon: Icons.chat_bubble_outline,
              color: const Color(0xFF8E9297),
              onTap: () =>
                  _navigateToBoardPage(context, BoardType.freeBoard, '자유 게시판'),
            ),
            _buildBoardCard(
              context,
              title: '베스트 모음',
              description: '인기 글과\n명예의 전당',
              icon: Icons.emoji_events,
              color: const Color(0xFFFFD700),
              onTap: () => _showBestPostsMenu(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoardCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPopularPosts(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 인기 글',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToBoardPage(
                context,
                BoardType.noiseReview,
                '소음 후기 게시판',
              ),
              child: const Text('더보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 인기 글 목록 (임시 데이터)
        ..._buildPopularPostsList(context),
      ],
    );
  }

  List<Widget> _buildPopularPostsList(BuildContext context) {
    final colors = context.colors;

    // 임시 데이터
    final dummyPosts = [
      {
        'title': '윗층 발소리가 너무 심해서 잠을 못 자겠어요',
        'content': '새벽 2시까지 쿵쿵거리는 소리가...',
        'likeCount': 24,
        'commentCount': 12,
        'timeAgo': '2시간 전',
        'hasNoiseRecord': true,
      },
      {
        'title': '층간소음 신고 후 관리사무소 대응 후기',
        'content': '관리사무소에 신고했더니 이렇게 해결됐어요',
        'likeCount': 18,
        'commentCount': 8,
        'timeAgo': '4시간 전',
        'hasNoiseRecord': false,
      },
      {
        'title': '소음측정기 추천해주세요',
        'content': '정확한 측정을 위해 어떤 기기가 좋을까요?',
        'likeCount': 15,
        'commentCount': 22,
        'timeAgo': '6시간 전',
        'hasNoiseRecord': false,
      },
    ];

    return dummyPosts
        .map((post) => _buildPostPreviewCard(context, post))
        .toList();
  }

  Widget _buildPostPreviewCard(
    BuildContext context,
    Map<String, dynamic> post,
  ) {
    final colors = context.colors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // TODO: 게시글 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post['hasNoiseRecord'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.graphic_eq,
                            size: 12,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '녹음',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post['content'],
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.favorite_border,
                    post['likeCount'].toString(),
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    context,
                    Icons.chat_bubble_outline,
                    post['commentCount'].toString(),
                  ),
                  const Spacer(),
                  Text(
                    post['timeAgo'],
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String count) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(fontSize: 12, color: colors.textTertiary)),
      ],
    );
  }

  Widget _buildTodaysBest(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '오늘의 베스트',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _showBestPostsMenu(context),
              child: const Text('더보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 베스트 글 1개 미리보기
        _buildBestPostCard(context),
      ],
    );
  }

  Widget _buildBestPostCard(BuildContext context) {
    final colors = context.colors;

    return Card(
      child: InkWell(
        onTap: () {
          // TODO: 베스트 글 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '베스트',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '소음 후기',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '층간소음 해결 성공담 - 이렇게 하니까 정말 조용해졌어요!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(context, Icons.favorite, '156'),
                  const SizedBox(width: 12),
                  _buildStatChip(context, Icons.chat_bubble, '89'),
                  const SizedBox(width: 12),
                  _buildStatChip(context, Icons.visibility, '1.2k'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBoardPage(
    BuildContext context,
    String boardType,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BoardPage(boardType: boardType, title: title),
      ),
    );
  }

  void _showBestPostsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '베스트 게시글',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('주간 베스트'),
              subtitle: const Text('지난 7일간 인기 글'),
              onTap: () {
                Navigator.pop(context);
                _navigateToBoardPage(context, BoardType.weeklyBest, '주간 베스트');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month),
              title: const Text('월간 베스트'),
              subtitle: const Text('지난 30일간 인기 글'),
              onTap: () {
                Navigator.pop(context);
                _navigateToBoardPage(context, BoardType.monthlyBest, '월간 베스트');
              },
            ),
          ],
        ),
      ),
    );
  }
}
