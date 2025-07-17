import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/noise_ranking_viewmodel.dart';
import '../../widgets/ranking_item_widget.dart';
import '../../widgets/ranking_stats_widget.dart';

import '../../../data/models/region_noise_model.dart';

class NoiseRankingPage extends StatefulWidget {
  const NoiseRankingPage({super.key});

  @override
  State<NoiseRankingPage> createState() => _NoiseRankingPageState();
}

class _NoiseRankingPageState extends State<NoiseRankingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  final List<String> _periods = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoiseRankingViewModel>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final viewModel = context.read<NoiseRankingViewModel>();
    switch (_tabController.index) {
      case 0:
        viewModel.changeRankingType(RankingType.region);
        break;
      case 1:
        viewModel.changeRankingType(RankingType.apartment);
        break;
      case 2:
        viewModel.changeRankingType(RankingType.user);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음 랭킹'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            onPressed: () => setState(() => _showSearch = !_showSearch),
            tooltip: '검색',
          ),
          _buildPeriodSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NoiseRankingViewModel>().refresh(),
            tooltip: '새로고침',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: '지역별'),
            Tab(icon: Icon(Icons.apartment), text: '아파트별'),
            Tab(icon: Icon(Icons.person), text: '사용자별'),
          ],
        ),
      ),
      body: Consumer<NoiseRankingViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 검색창
              if (_showSearch) _buildSearchBar(viewModel),

              // 통계 요약
              _buildStatsHeader(viewModel),

              // 랭킹 목록
              Expanded(child: _buildRankingContent(viewModel)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Consumer<NoiseRankingViewModel>(
      builder: (context, viewModel, child) {
        return PopupMenuButton<String>(
          initialValue: viewModel.selectedPeriod,
          onSelected: viewModel.changePeriod,
          itemBuilder: (context) => _periods
              .map(
                (period) => PopupMenuItem(
                  value: period,
                  child: Text(viewModel.getPeriodDisplayName(period)),
                ),
              )
              .toList(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  viewModel.getPeriodDisplayName(viewModel.selectedPeriod),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(NoiseRankingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // 실시간 검색을 위해 setState 호출
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: '지역명 또는 주소로 검색',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildStatsHeader(NoiseRankingViewModel viewModel) {
    final ranking = viewModel.currentRanking;
    if (ranking == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: RankingStatsWidget(
        ranking: ranking,
        changeStats: viewModel.getRankingChangeStats(),
        sectionStats: viewModel.getRankingSectionStats(),
      ),
    );
  }

  Widget _buildRankingContent(NoiseRankingViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final ranking = viewModel.currentRanking;
    if (ranking == null || ranking.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '랭킹 데이터가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '아직 수집된 데이터가 충분하지 않습니다',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 검색 필터링
    final filteredItems = _searchController.text.isEmpty
        ? ranking.data
        : viewModel.searchRankingItems(_searchController.text);

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('검색 결과가 없습니다', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '"${_searchController.text}"에 대한 결과를 찾을 수 없습니다',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return RankingItemWidget(
            item: item,
            rankingType: viewModel.selectedRankingType,
            onTap: () => _showRankingItemDetail(item),
          );
        },
      ),
    );
  }

  void _showRankingItemDetail(RankingItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRankingItemDetailSheet(item),
    );
  }

  Widget _buildRankingItemDetailSheet(RankingItemModel item) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  item.metadata.address,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Divider(),

          // 상세 정보
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDetailRow('순위', '#${item.rank}'),
                _buildDetailRow('소음 지수', item.noiseIndex.toStringAsFixed(1)),
                _buildDetailRow(
                  '평균 데시벨',
                  '${item.metadata.avgDecibel.toStringAsFixed(1)}dB',
                ),
                _buildDetailRow('총 기록 수', '${item.totalRecords}건'),
                _buildDetailRow('총 신고 수', '${item.totalReports}건'),
                if (item.hasRankingChange)
                  _buildDetailRow(
                    '순위 변동',
                    '${item.rankingUp ? '▲' : '▼'} ${item.change.abs()}',
                    valueColor: item.rankingUp ? Colors.red : Colors.blue,
                  ),
                if (item.metadata.peakHours.isNotEmpty)
                  _buildDetailRow('피크 시간대', item.metadata.peakHours.join(', ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
