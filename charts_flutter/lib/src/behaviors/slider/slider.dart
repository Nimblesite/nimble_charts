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

import 'package:meta/meta.dart' show immutable;
import 'package:nimble_charts/src/behaviors/chart_behavior.dart'
    show ChartBehavior, GestureType;
import 'package:nimble_charts_common/common.dart' as common
    show
        ChartBehavior,
        LayoutViewPaintOrder,
        RectSymbolRenderer,
        SelectionTrigger,
        Slider,
        SliderListenerCallback,
        SliderStyle,
        SymbolRenderer;

/// Chart behavior that adds a slider widget to a chart. When the slider is
/// dropped after drag, it will report its domain position and nearest datum
/// value. This behavior only supports charts that use continuous scales.
///
/// Input event types:
///   tapAndDrag - Mouse/Touch on the handle and drag across the chart.
///   pressHold - Mouse/Touch on the handle and drag across the chart instead of
///       panning.
///   longPressHold - Mouse/Touch for a while on the handle, then drag across
///       the data.
@immutable
class Slider<D> extends ChartBehavior<D> {
  /// Constructs a [Slider].
  ///
  /// [eventTrigger] sets the type of gesture handled by the slider.
  ///
  /// [handleRenderer] draws a handle for the slider. Defaults to a rectangle.
  ///
  /// [initialDomainValue] sets the initial position of the slider in domain
  /// units. The default is the center of the chart.
  ///
  /// [onChangeCallback] will be called when the position of the slider
  /// changes during a drag event.
  ///
  /// [snapToDatum] configures the slider to snap snap onto the nearest datum
  /// (by domain distance) when dragged. By default, the slider can be
  /// positioned anywhere along the domain axis.
  ///
  /// [style] configures the color and sizing of the slider line and handle.
  ///
  /// [layoutPaintOrder] configures the order in which the behavior should be
  /// painted. This value should be relative to LayoutPaintViewOrder.slider.
  /// (e.g. LayoutViewPaintOrder.slider + 1).
  factory Slider({
    common.SelectionTrigger? eventTrigger,
    common.SymbolRenderer? handleRenderer,
    initialDomainValue,
    String? roleId,
    common.SliderListenerCallback? onChangeCallback,
    bool snapToDatum = false,
    common.SliderStyle? style,
    int layoutPaintOrder = common.LayoutViewPaintOrder.slider,
  }) {
    eventTrigger ??= common.SelectionTrigger.tapAndDrag;
    handleRenderer ??= common.RectSymbolRenderer();
    // Default the handle size large enough to tap on a mobile device.
    style ??=
        common.SliderStyle(handleSize: const Rectangle<int>(0, 0, 20, 30));
    return Slider._internal(
      eventTrigger: eventTrigger,
      handleRenderer: handleRenderer,
      initialDomainValue: initialDomainValue,
      onChangeCallback: onChangeCallback,
      roleId: roleId,
      snapToDatum: snapToDatum,
      style: style,
      desiredGestures: Slider._getDesiredGestures(eventTrigger),
      layoutPaintOrder: layoutPaintOrder,
    );
  }

  Slider._internal({
    required this.eventTrigger,
    required this.snapToDatum,
    required this.desiredGestures,
    this.onChangeCallback,
    this.initialDomainValue,
    this.roleId,
    this.style,
    this.handleRenderer,
    this.layoutPaintOrder,
  });
  @override
  final Set<GestureType> desiredGestures;

  /// Type of input event for the slider.
  ///
  /// Input event types:
  ///   tapAndDrag - Mouse/Touch on the handle and drag across the chart.
  ///   pressHold - Mouse/Touch on the handle and drag across the chart instead
  ///       of panning.
  ///   longPressHold - Mouse/Touch for a while on the handle, then drag across
  ///       the data.
  final common.SelectionTrigger eventTrigger;

  /// The order to paint slider on the canvas.
  ///
  /// The smaller number is drawn first.  This value should be relative to
  /// LayoutPaintViewOrder.slider (e.g. LayoutViewPaintOrder.slider + 1).
  final int? layoutPaintOrder;

  /// Initial domain position of the slider, in domain units.
  final dynamic initialDomainValue;

  /// Callback function that will be called when the position of the slider
  /// changes during a drag event.
  ///
  /// The callback will be given the current domain position of the slider.
  final common.SliderListenerCallback? onChangeCallback;

  /// Custom role ID for this slider
  final String? roleId;

  /// Whether or not the slider will snap onto the nearest datum (by domain
  /// distance) when dragged.
  final bool snapToDatum;

  /// Color and size styles for the slider.
  final common.SliderStyle? style;

  /// Renderer for the handle. Defaults to a rectangle.
  final common.SymbolRenderer? handleRenderer;

  static Set<GestureType> _getDesiredGestures(
    common.SelectionTrigger eventTrigger,
  ) {
    final desiredGestures = <GestureType>{};
    switch (eventTrigger) {
      case common.SelectionTrigger.tapAndDrag:
        desiredGestures
          ..add(GestureType.onTap)
          ..add(GestureType.onDrag);
      case common.SelectionTrigger.pressHold:
      case common.SelectionTrigger.longPressHold:
        desiredGestures
          ..add(GestureType.onTap)
          ..add(GestureType.onLongPress)
          ..add(GestureType.onDrag);
      case common.SelectionTrigger.hover:
      case common.SelectionTrigger.tap:
        throw ArgumentError(
          'Slider does not support the event trigger ' '"$eventTrigger"',
        );
    }
    return desiredGestures;
  }

  @override
  common.Slider<D> createCommonBehavior() => common.Slider<D>(
        eventTrigger: eventTrigger,
        handleRenderer: handleRenderer,
        initialDomainValue: initialDomainValue as D,
        onChangeCallback: onChangeCallback,
        roleId: roleId,
        snapToDatum: snapToDatum,
        style: style,
      );

  @override
  void updateCommonBehavior(common.ChartBehavior<D> commonBehavior) {}

  @override
  String get role => 'Slider-$eventTrigger';

  @override
  bool operator ==(Object other) =>
      other is Slider &&
      eventTrigger == other.eventTrigger &&
      handleRenderer == other.handleRenderer &&
      initialDomainValue == other.initialDomainValue &&
      onChangeCallback == other.onChangeCallback &&
      roleId == other.roleId &&
      snapToDatum == other.snapToDatum &&
      style == other.style &&
      layoutPaintOrder == other.layoutPaintOrder;

  @override
  int get hashCode => Object.hash(
        eventTrigger,
        handleRenderer,
        initialDomainValue,
        roleId,
        snapToDatum,
        style,
        layoutPaintOrder,
      );
}
