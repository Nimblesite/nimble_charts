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

import 'dart:math';

import 'package:nimble_charts_common/common.dart';
import 'package:nimble_charts_common/src/chart/common/base_renderer_element.dart';

/// Chart behavior that listens to tap event triggers and locks the specified
/// [SelectionModel]. This is used to prevent further updates to the selection
/// model, until it is unlocked again.
///
/// SelectionModels that can be updated:
///   info - To view the details of the selected items (ie: hover for web).
///   action - To select an item as an input, drill, or other selection.
///
/// You can add one LockSelection for each model type that you are updating.
/// Any previous LockSelection behavior for that selection model will be
/// removed.
class LockSelection<D> implements ChartBehavior<D, BaseRendererElement<D>> {
  LockSelection({this.selectionModelType = SelectionModelType.info}) {
    // Setup the appropriate gesture listening.
    switch (eventTrigger) {
      case SelectionTrigger.tap:
        _listener = GestureListener(onTapTest: _onTapTest, onTap: _onSelect);
      case SelectionTrigger.hover:
      case SelectionTrigger.tapAndDrag:
      case SelectionTrigger.pressHold:
      case SelectionTrigger.longPressHold:
        throw ArgumentError('LockSelection does not support the event '
            'trigger "$eventTrigger"');
    }
  }
  late GestureListener _listener;

  /// Type of selection model that should be updated by input events.
  final SelectionModelType selectionModelType;

  /// Type of input event that should trigger selection.
  final SelectionTrigger eventTrigger = SelectionTrigger.tap;

  BaseChart<D, BaseRendererElement<D>>? _chart;

  bool _onTapTest(Point<double> chartPoint) =>
      // If the tap is within the drawArea, then claim the event from others.
      _chart!.pointWithinRenderer(chartPoint);

  bool _onSelect(Point<double> chartPoint, [double? ignored]) {
    // Skip events that occur outside the drawArea for any series renderer.
    if (!_chart!.pointWithinRenderer(chartPoint)) {
      return false;
    }

    final selectionModel = _chart!.getSelectionModel(selectionModelType);

    // Do not lock the selection model if there is no selection. Locking nothing
    // would result in a very confusing user interface as the user tries to
    // interact with content on the chart.
    if (!selectionModel.locked && !selectionModel.hasAnySelection) {
      return false;
    }

    // Toggle the lock state.
    selectionModel.locked = !selectionModel.locked;

    // If the model was just unlocked, clear the selection to dismiss any stale
    // behavior elements. A new hovercard/etc. will appear after the user
    // triggers a new gesture.
    if (!selectionModel.locked) {
      selectionModel.clearSelection();
    }

    return false;
  }

  @override
  void attachTo(BaseChart<D, BaseRendererElement<D>> chart) {
    _chart = chart;
    chart.addGestureListener(_listener);

    // TODO: Update this dynamically based on tappable location.
    switch (eventTrigger) {
      case SelectionTrigger.tap:
      case SelectionTrigger.tapAndDrag:
      case SelectionTrigger.pressHold:
      case SelectionTrigger.longPressHold:
        chart.registerTappable(this);
      case SelectionTrigger.hover:
        chart.unregisterTappable(this);
    }
  }

  @override
  void removeFrom(BaseChart<D, BaseRendererElement<D>> chart) {
    chart
      ..removeGestureListener(_listener)
      ..unregisterTappable(this);
    _chart = null;
  }

  @override
  String get role => 'LockSelection-$selectionModelType';
}
