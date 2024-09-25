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

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:nimble_charts/src/base_chart_state.dart' show BaseChartState;
import 'package:nimble_charts/src/behaviors/chart_behavior.dart'
    show ChartBehavior, ChartStateBehavior, GestureType;
import 'package:nimble_charts/src/behaviors/select_nearest.dart'
    show SelectNearest;
import 'package:nimble_charts/src/chart_container.dart';
import 'package:nimble_charts/src/selection_model_config.dart'
    show SelectionModelConfig;
import 'package:nimble_charts/src/user_managed_state.dart'
    show UserManagedState;
import 'package:nimble_charts_common/common.dart' as common
    show
        BaseChart,
        LayoutConfig,
        MarginSpec,
        Performance,
        RTLSpec,
        SelectionModelType,
        Series,
        SeriesRendererConfig;

/// Base class for all charts.
///
/// This class provides the foundation for building various types of charts
/// with different configurations and behaviors.
@immutable
abstract class BaseChart<D> extends StatefulWidget {
  const BaseChart(
    this.seriesList, {
    super.key,
    bool? animate,
    Duration? animationDuration,
    this.defaultRenderer,
    this.customSeriesRenderers,
    this.behaviors,
    this.selectionModels,
    this.rtlSpec,
    this.defaultInteractions = true,
    this.layoutConfig,
    this.userManagedState,
  })  : animate = animate ?? true,
        animationDuration =
            animationDuration ?? const Duration(milliseconds: 300);

  /// Series list to draw.
  final List<common.Series<dynamic, D>> seriesList;

  /// Animation transitions.
  final bool animate;

  /// The duration of the animation when data changes.
  final Duration animationDuration;

  /// Used to configure the margin sizes around the drawArea that the axis and
  /// other things render into.
  final LayoutConfig? layoutConfig;

  // Default renderer used to draw series data on the chart.
  final common.SeriesRendererConfig<D>? defaultRenderer;

  /// Include the default interactions or not.
  final bool defaultInteractions;

  /// List of chart behaviors to apply to the chart.
  final List<ChartBehavior<D>>? behaviors;

  /// List of selection models to add to the chart.
  final List<SelectionModelConfig<D>>? selectionModels;

  // List of custom series renderers used to draw series data on the chart.
  //
  // Series assigned a rendererIdKey will be drawn with the matching renderer in
  // this list. Series without a rendererIdKey will be drawn by the default
  // renderer.
  final List<common.SeriesRendererConfig<D>>? customSeriesRenderers;

  /// The spec to use if RTL is enabled.
  final common.RTLSpec? rtlSpec;

  /// Optional state that overrides internally kept state, such as selection.
  final UserManagedState<D>? userManagedState;

  @override
  BaseChartState<D> createState() => BaseChartState<D>();

  /// Creates and returns a [common.BaseChart].
  ///
  /// Subclasses should override this method to create and configure the
  /// appropriate [common.BaseChart] instance.
  common.BaseChart<D> createCommonChart(BaseChartState<D> chartState);

  /// Updates the [common.BaseChart] based on changes in the widget properties.
  ///
  /// This method is called when the chart widget is updated, allowing the chart
  /// to be reconfigured based on the new widget properties.
  ///
  /// [chart] The [common.BaseChart] instance to update.
  /// [oldWidget] The previous [BaseChart] widget, if any.
  /// [chartState] The current [BaseChartState] instance.
  void updateCommonChart(
    common.BaseChart<D> chart,
    BaseChart<D>? oldWidget,
    BaseChartState<D> chartState,
  ) {
    common.Performance.time('chartsUpdateRenderers');
    // Set default renderer if one was provided.
    if (defaultRenderer != null &&
        defaultRenderer != oldWidget?.defaultRenderer) {
      chart.defaultRenderer = defaultRenderer!.build();
      chartState.markChartDirty();
    }

    // Add custom series renderers if any were provided.
    if (customSeriesRenderers != null) {
      // TODO: This logic does not remove old renderers and
      // shouldn't require the series configs to remain in the same order.
      for (var i = 0; i < customSeriesRenderers!.length; i++) {
        if (oldWidget == null ||
            (oldWidget.customSeriesRenderers != null &&
                i > oldWidget.customSeriesRenderers!.length) ||
            customSeriesRenderers![i] != oldWidget.customSeriesRenderers![i]) {
          chart.addSeriesRenderer(customSeriesRenderers![i].build());
          chartState.markChartDirty();
        }
      }
    }
    common.Performance.timeEnd('chartsUpdateRenderers');

    common.Performance.time('chartsUpdateBehaviors');
    _updateBehaviors(chart, chartState);
    common.Performance.timeEnd('chartsUpdateBehaviors');

    _updateSelectionModel(chart, chartState);

    chart.transition = animate ? animationDuration : Duration.zero;
  }

  void _updateBehaviors(common.BaseChart chart, BaseChartState<D> chartState) {
    final behaviorList = List<ChartBehavior<D>>.from(behaviors ?? []);

    // Insert automatic behaviors to the front of the behavior list.
    if (defaultInteractions) {
      if (chartState.autoBehaviorWidgets.isEmpty) {
        addDefaultInteractions(chartState.autoBehaviorWidgets);
      }

      // Add default interaction behaviors to the front of the list if they
      // don't conflict with user behaviors by role.
      chartState.autoBehaviorWidgets.reversed
          .where(_notACustomBehavior)
          .forEach((behavior) {
        behaviorList.insert(0, behavior);
      });
    }

    // Remove any behaviors from the chart that are not in the incoming list.
    // Walk in reverse order they were added.
    // Also, remove any persisting behaviors from incoming list.
    for (var i = chartState.addedBehaviorWidgets.length - 1; i >= 0; i--) {
      final addedBehavior = chartState.addedBehaviorWidgets[i];
      if (!behaviorList.remove(addedBehavior)) {
        final role = addedBehavior.role;
        chartState.addedBehaviorWidgets.remove(addedBehavior);
        chartState.addedCommonBehaviorsByRole.remove(role);
        chart.removeBehavior(chartState.addedCommonBehaviorsByRole[role]);
        chartState.markChartDirty();
      }
    }

    // Add any remaining/new behaviors.
    for (final behaviorWidget in behaviorList) {
      final commonBehavior = behaviorWidget.createCommonBehavior();

      // Assign the chart state to any behavior that needs it.
      if (commonBehavior is ChartStateBehavior) {
        (commonBehavior as ChartStateBehavior).chartState = chartState;
      }

      chart.addBehavior(commonBehavior);
      chartState.addedBehaviorWidgets.add(behaviorWidget);
      chartState.addedCommonBehaviorsByRole[behaviorWidget.role] =
          commonBehavior;
      chartState.markChartDirty();
    }
  }

  /// Create the list of default interaction behaviors.
  ///
  /// Subclasses can override this method to customize the default interactions
  /// that are added to the chart.
  ///
  /// [behaviors] The list of [ChartBehavior] to add the default interactions
  /// to.
  void addDefaultInteractions(List<ChartBehavior> behaviors) {
    // Update selection model
    behaviors.add(
      SelectNearest<D>(),
    );
  }

  bool _notACustomBehavior(ChartBehavior behavior) =>
      behaviors == null ||
      !behaviors!.any(
        (userBehavior) => userBehavior.role == behavior.role,
      );

  void _updateSelectionModel(
    common.BaseChart<D> chart,
    BaseChartState<D> chartState,
  ) {
    final prevTypes = List<common.SelectionModelType>.from(
      chartState.addedSelectionChangedListenersByType.keys,
    );

    // Update any listeners for each type.
    selectionModels?.forEach((model) {
      final selectionModel = chart.getSelectionModel(model.type);

      final prevChangedListener =
          chartState.addedSelectionChangedListenersByType[model.type];
      if (!identical(model.changedListener, prevChangedListener)) {
        if (prevChangedListener != null) {
          selectionModel.removeSelectionChangedListener(prevChangedListener);
        }
        selectionModel.addSelectionChangedListener(model.changedListener!);
        chartState.addedSelectionChangedListenersByType[model.type] =
            model.changedListener!;
      }

      final prevUpdatedListener =
          chartState.addedSelectionUpdatedListenersByType[model.type];
      if (!identical(model.updatedListener, prevUpdatedListener)) {
        if (prevUpdatedListener != null) {
          selectionModel.removeSelectionUpdatedListener(prevUpdatedListener);
        }
        selectionModel.addSelectionUpdatedListener(model.updatedListener!);
        chartState.addedSelectionUpdatedListenersByType[model.type] =
            model.updatedListener!;
      }

      prevTypes.remove(model.type);
    });

    // Remove any lingering listeners.
    for (final type in prevTypes) {
      chart.getSelectionModel(type)
        ..removeSelectionChangedListener(
          chartState.addedSelectionChangedListenersByType[type]!,
        )
        ..removeSelectionUpdatedListener(
          chartState.addedSelectionUpdatedListenersByType[type]!,
        );
    }
  }

  /// Gets distinct set of gestures this chart will subscribe to.
  ///
  /// This is needed to allow setup of the [GestureDetector] widget with only
  /// gestures we need to listen to and it must wrap [ChartContainer] widget.
  /// Gestures are then setup to be proxied in [common.BaseChart] and that is
  /// held by [ChartContainerRenderObject].
  Set<GestureType> getDesiredGestures(BaseChartState chartState) {
    final types = <GestureType>{};
    behaviors?.forEach((behavior) {
      types.addAll(behavior.desiredGestures);
    });

    if (defaultInteractions && chartState.autoBehaviorWidgets.isEmpty) {
      addDefaultInteractions(chartState.autoBehaviorWidgets);
    }

    for (final behavior in chartState.autoBehaviorWidgets) {
      types.addAll(behavior.desiredGestures);
    }
    return types;
  }
}

/// Configuration for the chart layout.
@immutable
class LayoutConfig {
  const LayoutConfig({
    required this.leftMarginSpec,
    required this.topMarginSpec,
    required this.rightMarginSpec,
    required this.bottomMarginSpec,
  });

  /// Margin specification for the left side of the chart.
  final common.MarginSpec leftMarginSpec;

  /// Margin specification for the top side of the chart.
  final common.MarginSpec topMarginSpec;

  /// Margin specification for the right side of the chart.
  final common.MarginSpec rightMarginSpec;

  /// Margin specification for the bottom side of the chart.
  final common.MarginSpec bottomMarginSpec;

  /// Converts the layout configuration to the common [common.LayoutConfig].
  common.LayoutConfig get commonLayoutConfig => common.LayoutConfig(
        leftSpec: leftMarginSpec,
        topSpec: topMarginSpec,
        rightSpec: rightMarginSpec,
        bottomSpec: bottomMarginSpec,
      );
}
