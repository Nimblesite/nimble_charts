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

import 'dart:math' show Point;

import 'package:meta/meta.dart' show protected;
import 'package:nimble_charts_common/src/chart/common/chart_canvas.dart'
    show getAnimatedColor;
import 'package:nimble_charts_common/src/chart/common/processed_series.dart'
    show ImmutableSeries;
import 'package:nimble_charts_common/src/common/color.dart' show Color;

class ArcRendererElementList<D,
    TArcRendererElement extends ArcRendererElement<D>> {
  ArcRendererElementList({
    required this.arcs,
    required this.center,
    required this.innerRadius,
    required this.radius,
    required this.startAngle,
    this.stroke,
    this.strokeWidthPx,
  });
  final List<TArcRendererElement> arcs;
  final Point<double> center;
  final double innerRadius;
  final double radius;
  final double startAngle;

  /// Color of separator lines between arcs.
  final Color? stroke;

  /// Stroke width of separator lines between arcs.
  final double? strokeWidthPx;
}

abstract class ArcRendererElement<D> {
  ArcRendererElement({
    required this.startAngle,
    required this.endAngle,
    required this.series,
    this.color,
    this.index,
    this.key,
    this.domain,
  });
  double startAngle;
  double endAngle;
  Color? color;
  int? index;
  num? key;
  D? domain;
  ImmutableSeries<D> series;

  void updateAnimationPercent(
    ArcRendererElement<D> previous,
    ArcRendererElement<D> target,
    double animationPercent,
  ) {
    startAngle =
        ((target.startAngle - previous.startAngle) * animationPercent) +
            previous.startAngle;

    endAngle = ((target.endAngle - previous.endAngle) * animationPercent) +
        previous.endAngle;

    color = getAnimatedColor(previous.color!, target.color!, animationPercent);
  }
}

@protected
class AnimatedArcList<D, TArcRendererElement extends ArcRendererElement<D>> {
  final arcs = <AnimatedArc<D, TArcRendererElement>>[];
  Point<double>? center;
  double? innerRadius;
  double? radius;
  ImmutableSeries<D>? series;

  /// Color of separator lines between arcs.
  Color? stroke;

  /// Stroke width of separator lines between arcs.
  double? strokeWidthPx;
}

@protected
class AnimatedArc<D, TArcRendererElement extends ArcRendererElement<D>> {
  AnimatedArc(this.key, this.datum, this.domain);
  final String key;
  Object? datum;
  D? domain;

  ArcRendererElement<D>? _previousArc;
  late TArcRendererElement _targetArc;
  TArcRendererElement? _currentArc;

  // Flag indicating whether this arc is being animated out of the chart.
  bool animatingOut = false;

  /// Animates a arc that was removed from the series out of the view.
  ///
  /// This should be called in place of "setNewTarget" for arcs that represent
  /// data that has been removed from the series.
  ///
  /// Animates the angle of the arc to [endAngle], in radians.
  void animateOut(double endAngle) {
    final newTarget = _currentArc!.clone<TArcRendererElement>()

      // Animate the arc out by setting the angles to 0.
      ..startAngle = endAngle
      ..endAngle = endAngle;

    setNewTarget(newTarget);
    animatingOut = true;
  }

  void setNewTarget(TArcRendererElement newTarget) {
    animatingOut = false;
    _currentArc ??= newTarget.clone();
    _previousArc = _currentArc!.clone();
    _targetArc = newTarget;
  }

  TArcRendererElement getCurrentArc(double animationPercent) {
    if (animationPercent == 1.0 || _previousArc == null) {
      _currentArc = _targetArc;
      _previousArc = _targetArc;
      return _currentArc!;
    }

    _currentArc!
        .updateAnimationPercent(_previousArc!, _targetArc, animationPercent);

    return _currentArc!;
  }

  /// Returns the [startAngle] of the new target element, without updating
  /// animation state.
  double? get newTargetArcStartAngle => _targetArc.startAngle;

  /// Returns the [endAngle] of the new target element, without updating
  /// animation state.
  double? get currentArcEndAngle => _currentArc?.endAngle;

  /// Returns the [startAngle] of the currently rendered element, without
  /// updating animation state.
  double? get currentArcStartAngle => _currentArc?.startAngle;

  /// Returns the [endAngle] of the new target element, without updating
  /// animation state.
  double? get previousArcEndAngle => _previousArc?.endAngle;

  /// Returns the [startAngle] of the previously rendered element, without
  /// updating animation state.
  double? get previousArcStartAngle => _previousArc?.startAngle;
}

extension Aasdasd<D> on ArcRendererElement<D> {
  T clone<T extends ArcRendererElement<D>>(
    T Function({
      required Color? color,
      required double endAngle,
      required double startAngle,
      num? index,
      num? key,
      ImmutableSeries<D> series,
    }) fact,
  ) =>
      fact(
        startAngle: startAngle,
        endAngle: endAngle,
        color: color == null ? null : Color.fromOther(color: color!),
        index: index,
        key: key,
        series: series,
      );
}
