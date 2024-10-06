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
import 'package:meta/meta.dart' show immutable, protected;
import 'package:nimble_charts/src/base_chart.dart' show BaseChart;
import 'package:nimble_charts/src/base_chart_state.dart' show BaseChartState;
import 'package:nimble_charts_common/common.dart' as common
    show AxisSpec, BaseChart, CartesianChart, NumericAxis, NumericAxisSpec;

/// Base class for all cartesian charts.
///
/// A cartesian chart is a chart that uses a cartesian coordinate system - it
/// has a domain axis and a measure axis.
@immutable
abstract class CartesianChart<D> extends BaseChart<D> {
  /// Creates a [CartesianChart].
  ///
  /// [seriesList] List of series of data this chart will visualize.
  /// [domainAxis] Specification for the domain axis.
  /// [primaryMeasureAxis] Specification for the primary measure axis.
  /// [secondaryMeasureAxis] Specification for the secondary measure axis.
  /// [disjointMeasureAxes] Specifications for any disjoint measure axes.
  /// [defaultRenderer] Default renderer used to draw series data on the chart.
  /// [customSeriesRenderers] Custom renderers used to draw series data.
  /// [behaviors] List of behaviors to attach to this chart.
  /// [selectionModels] List of selection models used in this chart.
  /// [rtlSpec] Configures the chart to be RTL.
  /// [defaultInteractions] Whether to use the default interactions.
  /// [layoutConfig] Layout configuration for the chart.
  /// [userManagedState] User managed state for the chart.
  /// [flipVerticalAxis] Whether to flip the vertical axis direction.
  const CartesianChart(
    super.seriesList, {
    super.key,
    super.animate,
    super.animationDuration,
    this.domainAxis,
    this.primaryMeasureAxis,
    this.secondaryMeasureAxis,
    this.disjointMeasureAxes,
    super.defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.defaultInteractions,
    super.layoutConfig,
    super.userManagedState,
    this.flipVerticalAxis,
  });

  /// The domain axis for this chart (usually the x-axis).
  final common.AxisSpec? domainAxis;

  /// The primary measure axis for this chart (usually the y-axis).
  final common.NumericAxisSpec? primaryMeasureAxis;

  /// The secondary measure axis for this chart.
  final common.NumericAxisSpec? secondaryMeasureAxis;

  /// Map of axis ID to measure axis spec for all disjoint measure axes.
  final LinkedHashMap<String, common.NumericAxisSpec>? disjointMeasureAxes;

  /// Whether to flip the vertical axis direction.
  final bool? flipVerticalAxis;

  @override
  void updateCommonChart(
    common.BaseChart<D> chart,
    BaseChart<D>? oldWidget,
    BaseChartState<D> chartState,
  ) {
    super.updateCommonChart(chart, oldWidget, chartState);
    final prev = oldWidget as CartesianChart?;
    final cartesianChart = chart as common.CartesianChart;

    if (flipVerticalAxis != null) {
      cartesianChart.flipVerticalAxisOutput = flipVerticalAxis!;
    }

    if (domainAxis != null && domainAxis != prev?.domainAxis) {
      cartesianChart.domainAxisSpec = domainAxis!;
      chartState.markChartDirty();
    }

    if (primaryMeasureAxis != prev?.primaryMeasureAxis) {
      cartesianChart.primaryMeasureAxisSpec = primaryMeasureAxis;
      chartState.markChartDirty();
    }

    if (secondaryMeasureAxis != prev?.secondaryMeasureAxis) {
      cartesianChart.secondaryMeasureAxisSpec = secondaryMeasureAxis;
      chartState.markChartDirty();
    }

    if (disjointMeasureAxes != prev?.disjointMeasureAxes) {
      cartesianChart.disjointMeasureAxisSpecs = disjointMeasureAxes;
      chartState.markChartDirty();
    }
  }

  /// Creates a map of axis IDs to [common.NumericAxis] for disjoint measure axes.
  ///
  /// This method is used internally to create numeric axes for disjoint measures
  /// based on the specifications provided in [disjointMeasureAxes].
  @protected
  LinkedHashMap<String, common.NumericAxis>? createDisjointMeasureAxes() {
    if (disjointMeasureAxes != null) {
      // ignore: prefer_collection_literals
      final disjointAxes = LinkedHashMap<String, common.NumericAxis>();
      disjointMeasureAxes!.forEach((axisId, axisSpec) {
        disjointAxes[axisId] = axisSpec.createAxis();
      });
      return disjointAxes;
    } else {
      return null;
    }
  }
}
