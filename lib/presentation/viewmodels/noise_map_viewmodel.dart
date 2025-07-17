import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/services/noise_map_service.dart';
import '../../data/models/region_noise_model.dart';

class NoiseMapViewModel extends ChangeNotifier {
  final NoiseMapService _noiseMapService = NoiseMapService();

  // 지도 관련 상태
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};

  // 데이터 상태
  List<RegionNoiseModel> _regionNoiseData = [];
  NoiseStatsSummary? _statsSummary;

  // UI 상태
  bool _isLoading = false;
  String? _error;
  final String _selectedPeriod = 'daily';
  int _minSeverity = 0;
  int _maxSeverity = 100;
  String _searchQuery = '';

  // 필터 및 표시 옵션
  bool _showMarkers = true;
  bool _showHeatmap = false;
  bool _showOnlyHighNoise = false;
  double _minDecibelFilter = 40.0;

  // Getters
  Set<Marker> get markers => _markers;
  Set<Polygon> get polygons => _polygons;
  List<RegionNoiseModel> get regionNoiseData => _regionNoiseData;
  NoiseStatsSummary? get statsSummary => _statsSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;
  int get minSeverity => _minSeverity;
  int get maxSeverity => _maxSeverity;
  String get searchQuery => _searchQuery;
  bool get showMarkers => _showMarkers;
  bool get showHeatmap => _showHeatmap;
  bool get showOnlyHighNoise => _showOnlyHighNoise;
  double get minDecibelFilter => _minDecibelFilter;

  // 지도 컨트롤러 설정
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // 초기 데이터 로드
  Future<void> loadInitialData() async {
    await Future.wait([loadRegionNoiseData(), loadStatsSummary()]);
  }

  // 지역별 소음 데이터 로드
  Future<void> loadRegionNoiseData() async {
    try {
      _setLoading(true);
      _error = null;

      final data = await _noiseMapService.getRegionsBySeverity(
        minSeverity: _minSeverity,
        maxSeverity: _maxSeverity,
        limit: 200,
      );

      _regionNoiseData = data;
      await _updateMarkersAndPolygons();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 통계 요약 로드
  Future<void> loadStatsSummary() async {
    try {
      _statsSummary = await _noiseMapService.getNoiseStatsSummary();
      notifyListeners();
    } catch (e) {
      debugPrint('통계 요약 로드 실패: $e');
    }
  }

  // 마커와 폴리곤 업데이트
  Future<void> _updateMarkersAndPolygons() async {
    _markers.clear();
    _polygons.clear();

    for (final region in _regionNoiseData) {
      if (_shouldShowRegion(region)) {
        if (_showMarkers) {
          _addMarkerForRegion(region);
        }
        // 폴리곤은 나중에 구현 (실제 지역 경계 데이터 필요)
      }
    }

    notifyListeners();
  }

  // 지역이 필터 조건에 맞는지 확인
  bool _shouldShowRegion(RegionNoiseModel region) {
    // 데시벨 필터
    if (region.avgDecibel < _minDecibelFilter) return false;

    // 고소음 지역만 표시 옵션
    if (_showOnlyHighNoise && region.noiseSeverity < 70) return false;

    // 검색 쿼리 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      return region.fullAddress.toLowerCase().contains(query);
    }

    return true;
  }

  // 지역에 대한 마커 추가
  void _addMarkerForRegion(RegionNoiseModel region) {
    // 실제로는 지역의 좌표 데이터가 필요하지만
    // 현재는 지역명으로부터 대략적인 좌표를 생성
    final coordinates = _getCoordinatesForRegion(region);

    final marker = Marker(
      markerId: MarkerId(region.regionKey),
      position: coordinates,
      icon: _getMarkerIcon(region.noiseSeverity),
      infoWindow: InfoWindow(
        title: region.shortAddress,
        snippet:
            '평균 ${region.avgDecibel.toStringAsFixed(1)}dB (${region.totalRecords}건)',
        onTap: () => _onMarkerTapped(region),
      ),
    );

    _markers.add(marker);
  }

  // 소음 심각도에 따른 마커 아이콘 선택
  BitmapDescriptor _getMarkerIcon(int severity) {
    if (severity >= 80) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else if (severity >= 60) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (severity >= 40) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  // 지역명으로부터 대략적인 좌표 생성 (임시)
  LatLng _getCoordinatesForRegion(RegionNoiseModel region) {
    // 실제로는 지오코딩 API를 사용해야 함
    // 현재는 서울 중심으로 임시 좌표 생성
    double baseLat = 37.5665;
    double baseLng = 126.9780;

    // 지역명 해시코드를 이용한 임시 분산
    final hash = region.regionKey.hashCode;
    final latOffset = (hash % 1000 - 500) / 10000.0;
    final lngOffset = ((hash ~/ 1000) % 1000 - 500) / 10000.0;

    return LatLng(baseLat + latOffset, baseLng + lngOffset);
  }

  // 마커 탭 이벤트
  void _onMarkerTapped(RegionNoiseModel region) {
    // 지역 상세 정보 표시 로직
    debugPrint('지역 선택: ${region.fullAddress}');
  }

  // 검색 기능
  Future<void> searchRegions(String query) async {
    try {
      _setLoading(true);
      _searchQuery = query;

      if (query.isEmpty) {
        await loadRegionNoiseData();
      } else {
        final results = await _noiseMapService.searchRegionsByName(query);
        _regionNoiseData = results;
        await _updateMarkersAndPolygons();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 필터 설정
  void setSeverityFilter(int minSeverity, int maxSeverity) {
    _minSeverity = minSeverity;
    _maxSeverity = maxSeverity;
    loadRegionNoiseData();
  }

  void setDecibelFilter(double minDecibel) {
    _minDecibelFilter = minDecibel;
    _updateMarkersAndPolygons();
  }

  void setShowOnlyHighNoise(bool value) {
    _showOnlyHighNoise = value;
    _updateMarkersAndPolygons();
  }

  void setShowMarkers(bool value) {
    _showMarkers = value;
    _updateMarkersAndPolygons();
  }

  void setShowHeatmap(bool value) {
    _showHeatmap = value;
    notifyListeners();
  }

  // 지도 카메라 이동
  Future<void> moveToRegion(RegionNoiseModel region) async {
    if (_mapController != null) {
      final coordinates = _getCoordinatesForRegion(region);
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(coordinates, 14.0),
      );
    }
  }

  // 현재 위치로 이동
  Future<void> moveToCurrentLocation() async {
    // 위치 권한 확인 및 현재 위치 이동 로직
    if (_mapController != null) {
      // 기본값으로 서울시청으로 이동
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(37.5665, 126.9780), 11.0),
      );
    }
  }

  // 줌 레벨에 따른 표시 레벨 조정
  void onCameraMove(CameraPosition position) {
    // 줌 레벨에 따라 마커 표시 조정
    final zoom = position.zoom;

    if (zoom < 8) {
      // 시/도 레벨
    } else if (zoom < 11) {
      // 시/군/구 레벨
    } else {
      // 읍/면/동 레벨
    }
  }

  // 색상 범례 데이터
  List<LegendItem> getLegendItems() {
    return [
      LegendItem(color: Colors.red, label: '매우 심각 (80+)', range: '80-100'),
      LegendItem(color: Colors.orange, label: '심각 (60-79)', range: '60-79'),
      LegendItem(color: Colors.yellow, label: '보통 (40-59)', range: '40-59'),
      LegendItem(color: Colors.green, label: '양호 (0-39)', range: '0-39'),
    ];
  }

  // 필터 초기화
  void resetFilters() {
    _minSeverity = 0;
    _maxSeverity = 100;
    _minDecibelFilter = 40.0;
    _showOnlyHighNoise = false;
    _searchQuery = '';
    loadRegionNoiseData();
  }

  // 공통 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// 범례 아이템 클래스
class LegendItem {
  final Color color;
  final String label;
  final String range;

  LegendItem({required this.color, required this.label, required this.range});
}
