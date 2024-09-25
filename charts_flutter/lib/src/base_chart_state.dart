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

import 'dart:ui' show TextDirection;

import 'package:flutter/material.dart'
    show
        AnimationController,
        BuildContext,
        State,
        TickerProviderStateMixin,
        Widget;
import 'package:flutter/widgets.dart'
    show CustomMultiChildLayout, Directionality, LayoutId;
import 'package:nimble_charts/src/base_chart.dart' show BaseChart;
import 'package:nimble_charts/src/behaviors/chart_behavior.dart'
    show BuildableBehavior, ChartBehavior, ChartStateBehavior;
import 'package:nimble_charts/src/chart_container.dart' show ChartContainer;
import 'package:nimble_charts/src/chart_gesture_detector.dart'
    show ChartGestureDetector;
import 'package:nimble_charts/src/chart_state.dart' show ChartState;
import 'package:nimble_charts/src/widget_layout_delegate.dart';
import 'package:nimble_charts_common/common.dart' as common;

/// The state for a [BaseChart] widget.
class BaseChartState<D> extends State<BaseChart<D>>
    with TickerProviderStateMixin
    implements ChartState {
  // Animation
  late AnimationController _animationController;
  double _animationValue = 0;

  BaseChart<D>? _oldWidget;

  ChartGestureDetector? _chartGestureDetector;

  bool _configurationChanged = false;

  /// A list of behaviors that are automatically built.
  final autoBehaviorWidgets = <ChartBehavior<D>>[];

  /// A list of behaviors that are added by the user.
  final addedBehaviorWidgets = <ChartBehavior<D>>[];

  /// A map of behaviors by role.
  final addedCommonBehaviorsByRole = <String, common.ChartBehavior>{};

  /// A map of selection changed listeners by type.
  final addedSelectionChangedListenersByType =
      <common.SelectionModelType, common.SelectionModelListener<D>>{};

  /// A map of selection updated listeners by type.
  final addedSelectionUpdatedListenersByType =
      <common.SelectionModelType, common.SelectionModelListener<D>>{};

  /// A map of behavior animation controllers by behavior.
  final _behaviorAnimationControllers =
      <ChartStateBehavior, AnimationController>{};

  /// The layout ID for the chart container.
  static const chartContainerLayoutID = 'chartContainer';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(_animationTick);
  }

  @override
  void requestRebuild() {
    setState(() {});
  }

  @override
  void markChartDirty() {
    _configurationChanged = true;
  }

  @override
  void resetChartDirtyFlag() {
    _configurationChanged = false;
  }

  @override
  bool get chartIsDirty => _configurationChanged;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// Builds the common chart canvas widget.
  Widget _buildChartContainer() {
    final chartContainer = ChartContainer<D>(
      oldChartWidget: _oldWidget,
      chartWidget: widget,
      chartState: this,
      animationValue: _animationValue,
      rtl: Directionality.of(context) == TextDirection.rtl,
      rtlSpec: widget.rtlSpec,
      userManagedState: widget.userManagedState,
    );
    _oldWidget = widget;

    final desiredGestures = widget.getDesiredGestures(this);
    if (desiredGestures.isNotEmpty) {
      _chartGestureDetector ??= ChartGestureDetector();
      return _chartGestureDetector!
          .makeWidget(context, chartContainer, desiredGestures);
    } else {
      return chartContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartWidgets = <LayoutId>[];
    final idAndBehaviorMap = <String, BuildableBehavior>{};

    // Add the common chart canvas widget.
    chartWidgets.add(
      LayoutId(
        id: chartContainerLayoutID,
        child: _buildChartContainer(),
      ),
    );

    // Add widget for each behavior that can build widgets
    addedCommonBehaviorsByRole.forEach((id, behavior) {
      if (behavior is BuildableBehavior) {
        assert(id != chartContainerLayoutID);

        final buildableBehavior = behavior as BuildableBehavior;
        idAndBehaviorMap[id] = buildableBehavior;

        final widget = buildableBehavior.build(context);
        chartWidgets.add(LayoutId(id: id, child: widget));
      }
    });

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return CustomMultiChildLayout(
      delegate: WidgetLayoutDelegate(
        chartContainerLayoutID,
        idAndBehaviorMap,
        isRTL,
      ),
      children: chartWidgets,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _behaviorAnimationControllers
      ..forEach((_, controller) => controller.dispose())
      ..clear();
    super.dispose();
  }

  @override
  void setAnimation(Duration transition) {
    _playAnimation(transition);
  }

  void _playAnimation(Duration duration) {
    _animationController
      ..duration = duration
      ..forward(from: (duration == Duration.zero) ? 1.0 : 0.0);
    _animationValue = _animationController.value;
  }

  void _animationTick() {
    setState(() {
      _animationValue = _animationController.value;
    });
  }

  /// Get animation controller to be used by [behavior].
  AnimationController getAnimationController(ChartStateBehavior behavior) {
    _behaviorAnimationControllers[behavior] ??=
        AnimationController(vsync: this);

    return _behaviorAnimationControllers[behavior]!;
  }

  /// Dispose of animation controller used by [behavior].
  void disposeAnimationController(ChartStateBehavior behavior) {
    final controller = _behaviorAnimationControllers.remove(behavior);
    controller?.dispose();
  }
}
