import 'package:flutter/material.dart';
import '../viewmodels/noise_map_viewmodel.dart';

class NoiseMapFilterWidget extends StatefulWidget {
  final NoiseMapViewModel viewModel;

  const NoiseMapFilterWidget({Key? key, required this.viewModel})
    : super(key: key);

  @override
  State<NoiseMapFilterWidget> createState() => _NoiseMapFilterWidgetState();
}

class _NoiseMapFilterWidgetState extends State<NoiseMapFilterWidget> {
  late RangeValues _severityRange;
  late double _decibelFilter;

  @override
  void initState() {
    super.initState();
    _severityRange = RangeValues(
      widget.viewModel.minSeverity.toDouble(),
      widget.viewModel.maxSeverity.toDouble(),
    );
    _decibelFilter = widget.viewModel.minDecibelFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '필터 설정',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  widget.viewModel.resetFilters();
                  setState(() {
                    _severityRange = const RangeValues(0, 100);
                    _decibelFilter = 40.0;
                  });
                },
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 소음 심각도 범위
          Text(
            '소음 심각도: ${_severityRange.start.round()} - ${_severityRange.end.round()}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          RangeSlider(
            values: _severityRange,
            min: 0,
            max: 100,
            divisions: 20,
            labels: RangeLabels(
              _severityRange.start.round().toString(),
              _severityRange.end.round().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _severityRange = values;
              });
            },
            onChangeEnd: (values) {
              widget.viewModel.setSeverityFilter(
                values.start.round(),
                values.end.round(),
              );
            },
          ),
          const SizedBox(height: 16),

          // 최소 데시벨 필터
          Text(
            '최소 데시벨: ${_decibelFilter.round()}dB',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _decibelFilter,
            min: 30,
            max: 100,
            divisions: 14,
            label: '${_decibelFilter.round()}dB',
            onChanged: (value) {
              setState(() {
                _decibelFilter = value;
              });
            },
            onChangeEnd: (value) {
              widget.viewModel.setDecibelFilter(value);
            },
          ),
          const SizedBox(height: 16),

          // 토글 옵션들
          _buildToggleOption(
            '고소음 지역만 표시',
            widget.viewModel.showOnlyHighNoise,
            widget.viewModel.setShowOnlyHighNoise,
          ),
          _buildToggleOption(
            '마커 표시',
            widget.viewModel.showMarkers,
            widget.viewModel.setShowMarkers,
          ),
          _buildToggleOption(
            '히트맵 표시',
            widget.viewModel.showHeatmap,
            widget.viewModel.setShowHeatmap,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
