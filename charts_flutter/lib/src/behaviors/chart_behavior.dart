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

import 'dart:math' show Rectangle;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nimble_charts/src/base_chart_state.dart' show BaseChartState;
import 'package:nimble_charts_common/common.dart' as common
    show
        BehaviorPosition,
        ChartBehavior,
        InsideJustification,
        OutsideJustification;

/// Flutter wrapper for chart behaviors.
@immutable
abstract class ChartBehavior<D> {
  /// The set of gestures that this behavior wants to handle.
  Set<GestureType> get desiredGestures;

  /// Creates the common behavior that this Flutter behavior wraps.
  common.ChartBehavior<D> createCommonBehavior();

  /// Updates the common behavior with any new configurations.
  void updateCommonBehavior(common.ChartBehavior<D> commonBehavior);

  /// A unique identifier for this behavior's role in the chart.
  String get role;
}

/// A chart behavior that depends on Flutter [State].
abstract class ChartStateBehavior<B extends common.ChartBehavior> {
  /// Sets the chart state that this behavior depends on.
  set chartState(BaseChartState chartState);
}

/// A chart behavior that can build a Flutter [Widget].
abstract class BuildableBehavior<B extends common.ChartBehavior> {
  /// Builds a [Widget] based on the information passed in.
  ///
  /// [context] Flutter build context for extracting inherited properties such
  /// as Directionality.
  Widget build(BuildContext context);

  /// The position on the widget.
  common.BehaviorPosition get position;

  /// Justification of the widget, if [position] is top, bottom, start, or end.
  common.OutsideJustification get outsideJustification;

  /// Justification of the widget if [position] is
  /// [common.BehaviorPosition.inside].
  common.InsideJustification get insideJustification;

  /// Chart's draw area bounds are used for positioning.
  Rectangle<int>? get drawAreaBounds;
}

/// Types of gestures accepted by a chart.
enum GestureType {
  /// Long press gesture on the chart.
  onLongPress,

  /// Tap gesture on the chart.
  onTap,

  /// Hover gesture over the chart.
  onHover,

  /// Drag gesture on the chart.
  onDrag,
}
