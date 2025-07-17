import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/post_model.dart';
import '../../../core/services/post_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../viewmodels/theme_viewmodel.dart';

class BoardPage extends StatefulWidget {
  final String boardType;
  final String title;

  const BoardPage({super.key, required this.boardType, required this.title});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  late TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _getCategories().length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CategoryInfo> _getCategories() {
    switch (widget.boardType) {
      case BoardType.noiseReview:
        return [
          CategoryInfo('전체', null),
          CategoryInfo('스트레스/하소연', PostCategory.stress),
          CategoryInfo('질문/상담', PostCategory.question),
          CategoryInfo('해결 후기', PostCategory.solution),
          CategoryInfo('정보 공유', PostCategory.info),
          CategoryInfo('법적 대응', PostCategory.legal),
        ];
      case BoardType.apartmentCommunity:
        return [
          CategoryInfo('전체', null),
          CategoryInfo('층간소음 공론화', PostCategory.discussion),
          CategoryInfo('주민 대응 모임', PostCategory.meeting),
          CategoryInfo('우리 아파트 꿀팁', PostCategory.tips),
          CategoryInfo('일상/잡담', PostCategory.daily),
        ];
      case BoardType.freeBoard:
        return [
          CategoryInfo('전체', null),
          CategoryInfo('유머/짤방', PostCategory.humor),
          CategoryInfo('맛집/여행', PostCategory.food),
          CategoryInfo('취미/관심사', PostCategory.hobby),
          CategoryInfo('사는 이야기', PostCategory.life),
          CategoryInfo('아무거나 질문', PostCategory.qa),
        ];
      default:
        return [CategoryInfo('전체', null)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = _getCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: categories.length > 1
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: categories
                    .map((category) => Tab(text: category.name))
                    .toList(),
                onTap: (index) {
                  setState(() {
                    _selectedCategory = categories[index].value;
                  });
                },
              )
            : null,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<PostModel>>(
      stream: _postService.getPosts(
        boardType: widget.boardType,
        category: _selectedCategory,
        limit: 20,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '게시글을 불러오는 중 오류가 발생했습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getEmptyStateIcon(), size: 64, color: colors.textTertiary),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateMessage(),
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onWritePost,
            icon: const Icon(Icons.edit),
            label: const Text('첫 번째 글 작성하기'),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (widget.boardType) {
      case BoardType.noiseReview:
        return Icons.volume_up;
      case BoardType.apartmentCommunity:
        return Icons.apartment;
      case BoardType.freeBoard:
        return Icons.chat_bubble_outline;
      case BoardType.weeklyBest:
      case BoardType.monthlyBest:
        return Icons.emoji_events;
      default:
        return Icons.article;
    }
  }

  String _getEmptyStateMessage() {
    switch (widget.boardType) {
      case BoardType.noiseReview:
        return '아직 소음 후기가 없습니다.\n첫 번째 경험담을 공유해보세요!';
      case BoardType.apartmentCommunity:
        return '아직 우리 아파트 게시글이 없습니다.\n이웃들과 소통을 시작해보세요!';
      case BoardType.freeBoard:
        return '아직 자유 게시글이 없습니다.\n자유로운 주제로 이야기해보세요!';
      case BoardType.weeklyBest:
        return '이번 주 베스트 글이 아직 없습니다.\n좋은 글을 작성해서 베스트에 도전해보세요!';
      case BoardType.monthlyBest:
        return '이번 달 베스트 글이 아직 없습니다.\n좋은 글을 작성해서 베스트에 도전해보세요!';
      default:
        return '아직 게시글이 없습니다.';
    }
  }

  Widget _buildPostCard(PostModel post) {
    final colors = context.colors;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onPostTap(post),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더: 카테고리, 아파트 정보 등
              _buildPostHeader(post),
              const SizedBox(height: 8),

              // 제목
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 내용 미리보기
              Text(
                post.content,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 이미지/소음 녹음 표시
              if (post.imageUrls.isNotEmpty || post.noiseRecord != null)
                _buildPostAttachments(post),

              // 하단: 통계, 시간
              _buildPostFooter(post),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(PostModel post) {
    final colors = context.colors;

    return Row(
      children: [
        // 카테고리
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getCategoryDisplayName(post.category),
            style: TextStyle(
              fontSize: 12,
              color: colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // 아파트 정보 (있는 경우)
        if (post.location?.apartmentName != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apartment, size: 12, color: colors.accent),
                const SizedBox(width: 4),
                Text(
                  post.location!.apartmentName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(),

        // 작성 시간
        Text(
          _getTimeAgo(post.createdAt),
          style: TextStyle(fontSize: 12, color: colors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildPostAttachments(PostModel post) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 이미지
          if (post.imageUrls.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image, size: 12, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${post.imageUrls.length}',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ],
              ),
            ),

          // 소음 녹음
          if (post.noiseRecord != null) ...[
            if (post.imageUrls.isNotEmpty) const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.graphic_eq, size: 12, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${post.noiseRecord!.avgDecibel.toStringAsFixed(1)}dB',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostFooter(PostModel post) {
    final colors = context.colors;

    return Row(
      children: [
        _buildStatChip(
          Icons.favorite_border,
          post.metrics.likeCount.toString(),
          colors.textTertiary,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          Icons.chat_bubble_outline,
          post.metrics.commentCount.toString(),
          colors.textTertiary,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          Icons.visibility,
          _formatViewCount(post.metrics.viewCount),
          colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    // 베스트 게시판은 글쓰기 불가
    if (widget.boardType == BoardType.weeklyBest ||
        widget.boardType == BoardType.monthlyBest) {
      return null;
    }

    return FloatingActionButton(
      onPressed: _onWritePost,
      child: const Icon(Icons.edit),
    );
  }

  String _getCategoryDisplayName(String category) {
    const categoryNames = {
      PostCategory.stress: '스트레스',
      PostCategory.question: '질문',
      PostCategory.solution: '해결후기',
      PostCategory.info: '정보',
      PostCategory.legal: '법적대응',
      PostCategory.discussion: '공론화',
      PostCategory.meeting: '주민모임',
      PostCategory.tips: '꿀팁',
      PostCategory.daily: '일상',
      PostCategory.humor: '유머',
      PostCategory.food: '맛집',
      PostCategory.hobby: '취미',
      PostCategory.life: '일상',
      PostCategory.qa: '질문',
    };

    return categoryNames[category] ?? '기타';
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _onPostTap(PostModel post) {
    // TODO: 게시글 상세 페이지로 이동
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('게시글 상세: ${post.title}')));
  }

  void _onWritePost() {
    // TODO: 게시글 작성 페이지로 이동
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('게시글 작성 기능은 아직 구현 중입니다')));
  }
}

class CategoryInfo {
  final String name;
  final String? value;

  CategoryInfo(this.name, this.value);
}
