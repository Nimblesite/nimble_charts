// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:collection' show LinkedHashMap;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:nimble_charts_common/src/chart/bar/bar_lane_renderer_config.dart'
    show BarLaneRendererConfig;
import 'package:nimble_charts_common/src/chart/bar/bar_renderer.dart'
    show AnimatedBar, BarRenderer, BarRendererElement;
import 'package:nimble_charts_common/src/chart/bar/base_bar_renderer.dart'
    show
        allBarGroupWeightsKey,
        barGroupCountKey,
        barGroupIndexKey,
        barGroupWeightKey,
        previousBarGroupWeightKey,
        stackKeyKey;
import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart'
    show ImmutableAxis, domainAxisKey, measureAxisKey;
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart'
    show ChartCanvas;
import 'package:nimble_charts_common/src/chart/common/processed_series.dart'
    show ImmutableSeries, MutableSeries;
import 'package:nimble_charts_common/src/data/series.dart' show AttributeKey;

/// Key for storing a list of all domain values that exist in the series data.
///
/// In grouped stacked mode, this list will contain a combination of domain
/// value and series category.
const domainValuesKey =
    AttributeKey<Set<Object>>('BarLaneRenderer.domainValues');

/// Renders series data as a series of bars with lanes.
///
/// Every stack of bars will have a swim lane rendered underneath the series
/// data, in a gray color by default. The swim lane occupies the same width as
/// the bar elements, and will be completely covered up if the bar stack happens
/// to take up the entire measure domain range.
///
/// If every bar that shares a domain value has a null measure value, then the
/// swim lanes may optionally be merged together into one wide lane that covers
/// the full domain range band width.
class BarLaneRenderer extends BarRenderer<String> {
  factory BarLaneRenderer({
    BarLaneRendererConfig? config,
    String? rendererId,
  }) {
    rendererId ??= 'bar';
    config ??= BarLaneRendererConfig();
    return BarLaneRenderer._internal(config: config, rendererId: rendererId);
  }

  BarLaneRenderer._internal({
    required BarLaneRendererConfig super.config,
    required super.rendererId,
  }) : super.internal();

  /// Store a map of domain+barGroupIndex+category index to bar lanes in a
  /// stack.
  ///
  /// This map is used to render all the bars in a stack together, to account
  /// for rendering effects that need to take the full stack into account (e.g.
  /// corner rounding).
  ///
  /// [LinkedHashMap] is used to render the bars on the canvas in the same order
  /// as the data was given to the chart. For the case where both grouping and
  /// stacking are disabled, this means that bars for data later in the series
  /// will be drawn "on top of" bars earlier in the series.
  // ignore: prefer_collection_literals, https://github.com/dart-lang/linter/issues/1649
  final _barLaneStackMap = LinkedHashMap<String, List<AnimatedBar<String>>>();

  /// Store a map of flags to track whether all measure values for a given
  /// domain value are null, for every series on the chart.
  // ignore: prefer_collection_literals, https://github.com/dart-lang/linter/issues/1649
  final _allMeasuresForDomainNullMap = LinkedHashMap<String, bool>();

  @override
  void preprocessSeries(List<MutableSeries<String>> seriesList) {
    super.preprocessSeries(seriesList);

    _allMeasuresForDomainNullMap.clear();

    for (final series in seriesList) {
      final domainFn = series.domainFn;
      final measureFn = series.rawMeasureFn;

      final domainValues = <String>{};

      for (var barIndex = 0; barIndex < series.data.length; barIndex++) {
        final domain = domainFn(barIndex);
        final measure = measureFn(barIndex);

        domainValues.add(domain);

        // Update the "all measure null" tracking for bars that have the
        // current domain value.
        if ((config as BarLaneRendererConfig).mergeEmptyLanes) {
          final allNull = _allMeasuresForDomainNullMap[domain];
          final isNull = measure == null;

          _allMeasuresForDomainNullMap[domain] =
              allNull != null ? allNull && isNull : isNull;
        }
      }

      series.setAttr(domainValuesKey, domainValues);
    }
  }

  @override
  void update(
    List<ImmutableSeries<String>> seriesList,
    bool isAnimatingThisDraw,
  ) {
    super.update(seriesList, isAnimatingThisDraw);

    // Add gray bars to render under every bar stack.
    for (final series in seriesList) {
      final domainValues = series.getAttr(domainValuesKey)! as Set<String>;

      final domainAxis =
          series.getAttr(domainAxisKey)! as ImmutableAxis<String>;
      final measureAxis = series.getAttr(measureAxisKey)! as ImmutableAxis<num>;
      final seriesStackKey = series.getAttr(stackKeyKey);
      final barGroupCount = series.getAttr(barGroupCountKey)!;
      final barGroupIndex = series.getAttr(barGroupIndexKey)!;
      final previousBarGroupWeight = series.getAttr(previousBarGroupWeightKey);
      final barGroupWeight = series.getAttr(barGroupWeightKey);
      final allBarGroupWeights = series.getAttr(allBarGroupWeightsKey);
      final measureAxisPosition = measureAxis.getLocation(0.0);
      final measureFn = series.measureFn;

      // Create a fake series for [BarLabelDecorator] to use when looking up the
      // index of each datum.
      final laneSeries =
          MutableSeries<String>.clone(seriesList[0] as MutableSeries<String>)
            ..data = <Object>[]

            // Don't render any labels on the swim lanes.
            ..labelAccessorFn = (index) => '';

      var laneSeriesIndex = 0;
      for (final domainValue in domainValues) {
        // Skip adding any background bars if they will be covered up by the
        // domain-spanning null bar.
        if (_allMeasuresForDomainNullMap[domainValue] == true) {
          continue;
        }

        // Add a fake datum to the series for [BarLabelDecorator].
        final datum = {'index': laneSeriesIndex};
        laneSeries.data.add(datum);

        // Each bar should be stored in barStackMap in a structure that mirrors
        // the visual rendering of the bars. Thus, they should be grouped by
        // domain value, series category (by way of the stack keys that were
        // generated for each series in the preprocess step), and bar group
        // index to account for all combinations of grouping and stacking.
        final barStackMapKey =
            '${domainValue}__${seriesStackKey}__$barGroupIndex';

        final barKey = '${barStackMapKey}0';

        final barStackList = _barLaneStackMap.putIfAbsent(
          barStackMapKey,
          () => <AnimatedBar<String>>[],
        );

        // If we already have an AnimatingBar for that index, use it.
        var animatingBar =
            barStackList.firstWhereOrNull((bar) => bar.key == barKey);

        final renderNegativeLanes =
            (config as BarLaneRendererConfig).renderNegativeLanes;

        final measureValue = measureFn(0);
        final measureIsNegative = measureValue != null && measureValue < 0;
        final maxMeasureValue = _getMaxMeasureValue(
          measureAxis,
          measureIsNegative && renderNegativeLanes,
        );

        // If we don't have any existing bar element, create a new bar and have
        // it animate in from the domain axis.
        if (animatingBar == null) {
          animatingBar = makeAnimatedBar(
            key: barKey,
            series: laneSeries,
            datum: datum,
            barGroupIndex: barGroupIndex,
            previousBarGroupWeight: previousBarGroupWeight,
            barGroupWeight: barGroupWeight,
            allBarGroupWeights: allBarGroupWeights,
            color: (config as BarLaneRendererConfig).backgroundBarColor,
            details: BarRendererElement<String>(),
            domainValue: domainValue,
            domainAxis: domainAxis,
            domainWidth: domainAxis.rangeBand.round(),
            fillColor: (config as BarLaneRendererConfig).backgroundBarColor,
            measureValue: maxMeasureValue,
            measureOffsetValue: 0.0,
            measureAxisPosition: measureAxisPosition,
            measureAxis: measureAxis,
            numBarGroups: barGroupCount,
            strokeWidthPx: config.strokeWidthPx,
            measureIsNull: false,
            measureIsNegative: renderNegativeLanes && measureIsNegative,
          );

          barStackList.add(animatingBar);
        } else {
          animatingBar
            ..datum = datum
            ..series = laneSeries
            ..domainValue = domainValue;
        }

        // Get the barElement we are going to setup.
        // Optimization to prevent allocation in non-animating case.
        final barElement = makeBarRendererElement(
          barGroupIndex: barGroupIndex,
          previousBarGroupWeight: previousBarGroupWeight,
          barGroupWeight: barGroupWeight,
          allBarGroupWeights: allBarGroupWeights,
          color: (config as BarLaneRendererConfig).backgroundBarColor,
          details: BarRendererElement<String>(),
          domainValue: domainValue,
          domainAxis: domainAxis,
          domainWidth: domainAxis.rangeBand.round(),
          fillColor: (config as BarLaneRendererConfig).backgroundBarColor,
          measureValue: maxMeasureValue,
          measureOffsetValue: 0.0,
          measureAxisPosition: measureAxisPosition,
          measureAxis: measureAxis,
          numBarGroups: barGroupCount,
          strokeWidthPx: config.strokeWidthPx,
          measureIsNull: false,
          measureIsNegative: renderNegativeLanes && measureIsNegative,
        );

        animatingBar.setNewTarget(barElement);

        laneSeriesIndex++;
      }
    }

    // Add domain-spanning bars to render when every measure value for every
    // datum of a given domain is null.
    if ((config as BarLaneRendererConfig).mergeEmptyLanes) {
      // Use the axes from the first series.
      final domainAxis =
          seriesList[0].getAttr(domainAxisKey)! as ImmutableAxis<String>;
      final measureAxis =
          seriesList[0].getAttr(measureAxisKey)! as ImmutableAxis<num>;

      final measureAxisPosition = measureAxis.getLocation(0.0);
      final maxMeasureValue = _getMaxMeasureValue(measureAxis, false);

      const barGroupIndex = 0;
      const previousBarGroupWeight = 0.0;
      const barGroupWeight = 1.0;
      const barGroupCount = 1;

      // Create a fake series for [BarLabelDecorator] to use when looking up the
      // index of each datum. We don't care about any other series values for
      // the merged lanes, so just clone the first series.
      final mergedSeries =
          MutableSeries<String>.clone(seriesList[0] as MutableSeries<String>)
            ..data = <Object>[]

            // Add a label accessor that returns the empty lane label.
            ..labelAccessorFn =
                (index) => (config as BarLaneRendererConfig).emptyLaneLabel;

      var mergedSeriesIndex = 0;
      _allMeasuresForDomainNullMap.forEach((domainValue, allNull) {
        if (allNull) {
          // Add a fake datum to the series for [BarLabelDecorator].
          final datum = {'index': mergedSeriesIndex};
          mergedSeries.data.add(datum);

          final barStackMapKey = '${domainValue}__allNull__';

          final barKey = '${barStackMapKey}0';

          final barStackList = _barLaneStackMap.putIfAbsent(
            barStackMapKey,
            () => <AnimatedBar<String>>[],
          );

          // If we already have an AnimatingBar for that index, use it.
          var animatingBar =
              barStackList.firstWhereOrNull((bar) => bar.key == barKey);

          // If we don't have any existing bar element, create a new bar and
          // have
          // it animate in from the domain axis.
          if (animatingBar == null) {
            animatingBar = makeAnimatedBar(
              key: barKey,
              series: mergedSeries,
              datum: datum,
              barGroupIndex: barGroupIndex,
              previousBarGroupWeight: previousBarGroupWeight,
              barGroupWeight: barGroupWeight,
              color: (config as BarLaneRendererConfig).backgroundBarColor,
              details: BarRendererElement<String>(),
              domainValue: domainValue,
              domainAxis: domainAxis,
              domainWidth: domainAxis.rangeBand.round(),
              fillColor: (config as BarLaneRendererConfig).backgroundBarColor,
              measureValue: maxMeasureValue,
              measureOffsetValue: 0.0,
              measureAxisPosition: measureAxisPosition,
              measureAxis: measureAxis,
              numBarGroups: barGroupCount,
              strokeWidthPx: config.strokeWidthPx,
              measureIsNull: false,
              measureIsNegative: false,
            );

            barStackList.add(animatingBar);
          } else {
            animatingBar
              ..datum = datum
              ..series = mergedSeries
              ..domainValue = domainValue;
          }

          // Get the barElement we are going to setup.
          // Optimization to prevent allocation in non-animating case.
          final barElement = makeBarRendererElement(
            barGroupIndex: barGroupIndex,
            previousBarGroupWeight: previousBarGroupWeight,
            barGroupWeight: barGroupWeight,
            color: (config as BarLaneRendererConfig).backgroundBarColor,
            details: BarRendererElement<String>(),
            domainValue: domainValue,
            domainAxis: domainAxis,
            domainWidth: domainAxis.rangeBand.round(),
            fillColor: (config as BarLaneRendererConfig).backgroundBarColor,
            measureValue: maxMeasureValue,
            measureOffsetValue: 0.0,
            measureAxisPosition: measureAxisPosition,
            measureAxis: measureAxis,
            numBarGroups: barGroupCount,
            strokeWidthPx: config.strokeWidthPx,
            measureIsNull: false,
            measureIsNegative: false,
          );

          animatingBar.setNewTarget(barElement);

          mergedSeriesIndex++;
        }
      });
    }
  }

  /// Gets the maximum measure value that will fit in the draw area.
  num _getMaxMeasureValue(ImmutableAxis<num> measureAxis, bool laneIsNegative) {
    final pos = chart.vertical
        ? chart.drawAreaBounds.top
        : ((isRtl && !laneIsNegative) || (!isRtl && laneIsNegative))
            ? chart.drawAreaBounds.left
            : chart.drawAreaBounds.right;

    return measureAxis.getDomain(pos.toDouble());
  }

  /// Paints the current bar data on the canvas.
  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    _barLaneStackMap.forEach((stackKey, barStack) {
      // Turn this into a list so that the getCurrentBar isn't called more than
      // once for each animationPercent if the barElements are iterated more
      // than once.
      final barElements = barStack
          .map((animatingBar) => animatingBar.getCurrentBar(animationPercent))
          .toList();

      paintBar(canvas, animationPercent, barElements);
    });

    super.paint(canvas, animationPercent);
  }
}
