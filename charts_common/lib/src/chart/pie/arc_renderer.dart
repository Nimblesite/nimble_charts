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
import 'dart:math' show Point, max, pi;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart'
    show ChartCanvas;
import 'package:nimble_charts_common/src/chart/common/processed_series.dart'
    show ImmutableSeries, MutableSeries;
import 'package:nimble_charts_common/src/chart/pie/arc_renderer_config.dart'
    show ArcRendererConfig;
import 'package:nimble_charts_common/src/chart/pie/arc_renderer_decorator.dart'
    show ArcRendererDecorator;
import 'package:nimble_charts_common/src/chart/pie/arc_renderer_element.dart'
    show AnimatedArc, AnimatedArcList, ArcRendererElement;
import 'package:nimble_charts_common/src/chart/pie/base_arc_renderer.dart';
import 'package:nimble_charts_common/src/common/style/style_factory.dart'
    show StyleFactory;
import 'package:nimble_charts_common/src/data/series.dart' show AttributeKey;

const arcElementsKey =
    AttributeKey<List<ArcRendererElement<Object>>>('ArcRenderer.elements');

class ArcRenderer<D, D2 extends ArcRendererElement<D>>
    extends BaseArcRenderer<D> {
  factory ArcRenderer({String? rendererId, ArcRendererConfig<D, D2>? config}) =>
      ArcRenderer._internal(
        rendererId: rendererId ?? 'line',
        config: config ?? ArcRendererConfig(),
      );

  ArcRenderer._internal({required super.rendererId, required this.config})
      : arcRendererDecorators = config.arcRendererDecorators,
        super(config: config);
  @override
  final ArcRendererConfig<D, D2> config;

  @override
  final List<ArcRendererDecorator<D, D2>> arcRendererDecorators;

  /// Store a map of series drawn on the chart, mapped by series name.
  ///
  /// [LinkedHashMap] is used to render the series on the canvas in the same
  /// order as the data was given to the chart.
  // ignore: prefer_collection_literals, https://github.com/dart-lang/linter/issues/1649
  final _seriesArcMap = LinkedHashMap<String, AnimatedArcList<D, D2>>();

  // Store a list of arcs that exist in the series data.
  //
  // This list will be used to remove any [AnimatedArc] that were rendered in
  // previous draw cycles, but no longer have a corresponding datum in the new
  // data.
  final _currentKeys = <String>[];

  @override
  void preprocessSeries(List<MutableSeries<D>> seriesList) {
    for (final series in seriesList) {
      final elements = <ArcRendererElement<D>>[];

      final domainFn = series.domainFn;
      final measureFn = series.measureFn;

      final seriesMeasureTotal = series.seriesMeasureTotal;

      // On the canvas, arc measurements are defined as angles from the positive
      // x axis. Start our first slice at the positive y axis instead.
      var startAngle = config.startAngle;
      final arcLength = config.arcLength;

      var totalAngle = 0.0;

      final measures = <num?>[];

      if (series.data.isEmpty) {
        // If the series has no data, generate an empty arc element that
        // occupies the entire chart.
        //
        // Use a tiny epsilon difference to ensure that the canvas renders a
        // "full" circle, in the correct direction.
        final angle = arcLength == 2 * pi ? arcLength * .999999 : arcLength;
        final endAngle = startAngle + angle;

        final details = ArcRendererElement<D>(
          startAngle: startAngle,
          endAngle: endAngle,
          index: 0,
          key: 0,
          series: series,
        );

        elements.add(details);
      } else {
        // Otherwise, generate an arc element per datum.
        for (var arcIndex = 0; arcIndex < series.data.length; arcIndex++) {
          final domain = domainFn(arcIndex);
          final measure = measureFn(arcIndex);
          measures.add(measure);
          if (measure == null) {
            continue;
          }

          final percentOfSeries = measure / seriesMeasureTotal;
          final angle = arcLength * percentOfSeries;
          final endAngle = startAngle + angle;

          final details = ArcRendererElement<D>(
            startAngle: startAngle,
            endAngle: endAngle,
            index: arcIndex,
            key: arcIndex,
            domain: domain,
            series: series,
          );

          elements.add(details);

          // Update the starting angle for the next datum in the series.
          startAngle = endAngle;

          totalAngle = totalAngle + angle;
        }
      }

      series.setAttr(arcElementsKey, elements);
    }
  }

  @override
  void update(List<ImmutableSeries<D>> seriesList, bool isAnimatingThisDraw) {
    _currentKeys.clear();

    final bounds = chart!.drawAreaBounds;

    final center = Point<double>(
      bounds.left + bounds.width / 2,
      bounds.top + bounds.height / 2,
    );

    final radius =
        bounds.height < bounds.width ? (bounds.height / 2) : (bounds.width / 2);

    if (config.arcRatio != null &&
        (config.arcRatio! < 0 || config.arcRatio! > 1)) {
      throw ArgumentError('arcRatio must be between 0 and 1');
    }

    final innerRadius = _calculateInnerRadius(radius);

    for (final series in seriesList) {
      final colorFn = series.colorFn;
      final arcListKey = series.id;

      final arcList =
          _seriesArcMap.putIfAbsent(arcListKey, AnimatedArcList.new);

      final elementsList =
          series.getAttr(arcElementsKey)! as List<ArcRendererElement<D>>;

      if (series.data.isEmpty) {
        // If the series is empty, set up the "no data" arc element. This should
        // occupy the entire chart, and use the chart style's no data color.
        final details = elementsList[0];

        const arcKey = '__no_data__';

        // If we already have an AnimatingArc for that index, use it.
        var animatingArc =
            arcList.arcs.firstWhereOrNull((arc) => arc.key == arcKey);

        arcList
          ..center = center
          ..radius = radius
          ..innerRadius = innerRadius
          ..series = series
          ..stroke = config.noDataColor
          ..strokeWidthPx = 0.0;

        // If we don't have any existing arc element, create a new arc. Unlike
        // real arcs, we should not animate the no data state in from 0.
        if (animatingArc == null) {
          animatingArc = AnimatedArc<D>(arcKey, null, null);
          arcList.arcs.add(animatingArc);
        } else {
          animatingArc
            ..datum = null
            ..domain = null;
        }

        // Update the set of arcs that still exist in the series data.
        _currentKeys.add(arcKey);

        // Get the arcElement we are going to setup.
        // Optimization to prevent allocation in non-animating case.
        final arcElement = ArcRendererElement<D>(
          color: config.noDataColor,
          startAngle: details.startAngle,
          endAngle: details.endAngle,
          series: series,
        );

        animatingArc.setNewTarget(arcElement);
      } else {
        var previousEndAngle = config.startAngle;

        for (var arcIndex = 0; arcIndex < series.data.length; arcIndex++) {
          final Object? datum = series.data[arcIndex];
          final details = elementsList[arcIndex];
          final domainValue = details.domain;

          final arcKey = '${series.id}__$domainValue';

          // If we already have an AnimatingArc for that index, use it.
          var animatingArc =
              arcList.arcs.firstWhereOrNull((arc) => arc.key == arcKey);

          arcList
            ..center = center
            ..radius = radius
            ..innerRadius = innerRadius
            ..series = series
            ..stroke = config.stroke
            ..strokeWidthPx = config.strokeWidthPx;

          // If we don't have any existing arc element, create a new arc and
          // have it animate in from the position of the previous arc's end
          // angle. If there were no previous arcs, then animate everything in
          // from 0.
          if (animatingArc == null) {
            animatingArc = AnimatedArc<D>(arcKey, datum, domainValue)
              ..setNewTarget(
                ArcRendererElement<D>(
                  color: colorFn!(arcIndex),
                  startAngle: previousEndAngle,
                  endAngle: previousEndAngle,
                  index: arcIndex,
                  series: series,
                ),
              );

            arcList.arcs.add(animatingArc);
          } else {
            animatingArc.datum = datum;

            previousEndAngle = animatingArc.previousArcEndAngle ?? 0.0;
          }

          animatingArc.domain = domainValue;

          // Update the set of arcs that still exist in the series data.
          _currentKeys.add(arcKey);

          // Get the arcElement we are going to setup.
          // Optimization to prevent allocation in non-animating case.
          final arcElement = ArcRendererElement<D>(
            color: colorFn!(arcIndex),
            startAngle: details.startAngle,
            endAngle: details.endAngle,
            index: arcIndex,
            series: series,
          );

          animatingArc.setNewTarget(arcElement);
        }
      }
    }

    // Animate out arcs that don't exist anymore.
    _seriesArcMap.forEach((key, arcList) {
      for (var arcIndex = 0; arcIndex < arcList.arcs.length; arcIndex++) {
        final arc = arcList.arcs[arcIndex];
        final arcStartAngle = arc.previousArcStartAngle;

        if (!_currentKeys.contains(arc.key)) {
          // Default to animating out to the top of the chart, clockwise, if
          // there are no arcs that start past this arc.
          var targetArcAngle = (2 * pi) + config.startAngle;

          // Find the nearest start angle of the next arc that still exists in
          // the data.
          for (final nextArc
              in arcList.arcs.where((arc) => _currentKeys.contains(arc.key))) {
            final nextArcStartAngle = nextArc.newTargetArcStartAngle;

            if (arcStartAngle! < nextArcStartAngle! &&
                nextArcStartAngle < targetArcAngle) {
              targetArcAngle = nextArcStartAngle;
            }
          }

          arc.animateOut(targetArcAngle);
        }
      }
    });
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    // Clean up the arcs that no longer exist.
    if (animationPercent == 1.0) {
      final keysToRemove = <String>[];

      _seriesArcMap.forEach((key, arcList) {
        arcList.arcs.removeWhere((arc) => arc.animatingOut);

        if (arcList.arcs.isEmpty) {
          keysToRemove.add(key);
        }
      });

      keysToRemove.forEach(_seriesArcMap.remove);
    }
    super.paint(canvas, animationPercent);
  }

  /// Assigns colors to series that are missing their colorFn.
  @override
  void assignMissingColors(
    Iterable<MutableSeries<D>> seriesList, {
    required bool emptyCategoryUsesSinglePalette,
  }) {
    var maxMissing = 0;

    for (final series in seriesList) {
      if (series.colorFn == null) {
        maxMissing = max(maxMissing, series.data.length);
      }
    }

    if (maxMissing > 0) {
      final colorPalettes = StyleFactory.style.getOrderedPalettes(1);
      final colorPalette = colorPalettes[0].makeShades(maxMissing);

      for (final series in seriesList) {
        series.colorFn ??= (index) => colorPalette[index!];
      }
    }
  }

  /// Calculates the size of the inner pie radius given the outer radius.
  double _calculateInnerRadius(double radius) {
    // arcRatio trumps arcWidth. If neither is defined, then inner radius is 0.
    if (config.arcRatio != null) {
      return max(radius - radius * config.arcRatio!, 0);
    } else if (config.arcWidth != null) {
      return max(radius - config.arcWidth!, 0);
    } else {
      return 0;
    }
  }

  @override
  List<AnimatedArcList<D>> getArcLists({String? seriesId}) {
    if (seriesId == null) {
      return _seriesArcMap.values.toList();
    }
    final arcList = _seriesArcMap[seriesId];

    if (arcList == null) return <AnimatedArcList<D>>[];
    return [arcList];
  }
}
