import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../viewmodels/noise_map_viewmodel.dart';
import '../../widgets/noise_map_legend_widget.dart';
import '../../widgets/noise_map_filter_widget.dart';

class NoiseMapPage extends StatefulWidget {
  const NoiseMapPage({super.key});

  @override
  State<NoiseMapPage> createState() => _NoiseMapPageState();
}

class _NoiseMapPageState extends State<NoiseMapPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  bool _showLegend = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoiseMapViewModel>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음지도'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: '필터',
          ),
          IconButton(
            icon: const Icon(Icons.legend_toggle),
            onPressed: () => setState(() => _showLegend = !_showLegend),
            tooltip: '범례',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () =>
                context.read<NoiseMapViewModel>().moveToCurrentLocation(),
            tooltip: '현재 위치',
          ),
        ],
      ),
      body: Consumer<NoiseMapViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // 지도
              _buildMap(viewModel),

              // 검색창
              _buildSearchBar(viewModel),

              // 필터 패널
              if (_showFilters) _buildFilterPanel(viewModel),

              // 범례
              if (_showLegend) _buildLegend(viewModel),

              // 통계 요약 카드
              _buildStatsCard(viewModel),

              // 로딩 인디케이터
              if (viewModel.isLoading) _buildLoadingOverlay(),

              // 에러 메시지
              if (viewModel.error != null)
                _buildErrorSnackBar(viewModel.error!),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildMap(NoiseMapViewModel viewModel) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        viewModel.setMapController(controller);
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.5665, 126.9780), // 서울시청 좌표
        zoom: 11.0,
      ),
      markers: viewModel.markers,
      polygons: viewModel.polygons,
      onCameraMove: viewModel.onCameraMove,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      compassEnabled: true,
      buildingsEnabled: true,
      trafficEnabled: false,
      indoorViewEnabled: false,
      mapType: MapType.normal,
    );
  }

  Widget _buildSearchBar(NoiseMapViewModel viewModel) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: viewModel.searchRegions,
          decoration: InputDecoration(
            hintText: '지역 검색 (예: 강남구, 역삼동)',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.searchRegions('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel(NoiseMapViewModel viewModel) {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: NoiseMapFilterWidget(viewModel: viewModel),
      ),
    );
  }

  Widget _buildLegend(NoiseMapViewModel viewModel) {
    return Positioned(
      bottom: 16,
      left: 16,
      child: NoiseMapLegendWidget(legendItems: viewModel.getLegendItems()),
    );
  }

  Widget _buildStatsCard(NoiseMapViewModel viewModel) {
    final stats = viewModel.statsSummary;
    if (stats == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 통계',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatRow('총 지역', '${stats.totalRegions}개'),
            _buildStatRow('총 기록', '${stats.totalRecords}건'),
            _buildStatRow('평균 소음', '${stats.avgDecibel.toStringAsFixed(1)}dB'),
            _buildStatRow('최고 소음', '${stats.maxDecibel.toStringAsFixed(1)}dB'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorSnackBar(String error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '재시도',
            textColor: Colors.white,
            onPressed: () {
              context.read<NoiseMapViewModel>().loadInitialData();
            },
          ),
        ),
      );
    });

    return const SizedBox.shrink();
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "refresh",
          mini: true,
          onPressed: () => context.read<NoiseMapViewModel>().loadInitialData(),
          tooltip: '새로고침',
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "center",
          mini: true,
          onPressed: () =>
              context.read<NoiseMapViewModel>().moveToCurrentLocation(),
          tooltip: '중심으로',
          child: const Icon(Icons.center_focus_strong),
        ),
      ],
    );
  }
}
