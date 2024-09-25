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

import 'package:nimble_charts/src/base_chart_state.dart';
import 'package:nimble_charts/src/cartesian_chart.dart' as cart;
import 'package:nimble_charts_common/common.dart' as common;

/// A numeric combo chart supports rendering each series of data with different
/// series renderers.
///
/// Note that if you have DateTime data, you should use [common.TimeSeriesChart]
/// . We do not expose a separate DateTimeComboChart because it would just be
/// a copy of that chart.
class NumericComboChart extends cart.CartesianChart<num> {
  /// Creates a numeric combo chart with the given series of data.
  ///
  /// [seriesList] The list of series to be plotted on the chart.
  /// [animate] Whether to animate the chart when data changes.
  /// [animationDuration] The duration of the animation when data changes.
  /// [domainAxis] The domain axis to use for the chart. If not provided, a
  /// default numeric axis will be used.
  /// [primaryMeasureAxis] The primary measure axis to use for the chart. If
  /// not provided, a default numeric axis will be used.
  /// [secondaryMeasureAxis] The secondary measure axis to use for the chart,
  /// if needed.
  /// [defaultRenderer] The default renderer to use for the series.
  /// [customSeriesRenderers] Custom renderers for specific series, if needed.
  /// [behaviors] A list of chart behaviors to attach to the chart.
  /// [selectionModels] A list of selection models to attach to the chart.
  /// [rtlSpec] Configures the chart for right-to-left languages.
  /// [layoutConfig] Configuration for chart layout.
  /// [defaultInteractions] Whether to add the default interactions to the
  /// chart.
  const NumericComboChart(
    super.seriesList, {
    super.key,
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.layoutConfig,
    super.defaultInteractions,
  });

  @override
  common.BaseChart<num> createCommonChart(BaseChartState<num> chartState) =>
      // Optionally create primary and secondary measure axes if the chart was
      // configured with them. If no axes were configured, then the chart will
      // use its default types (usually a numeric axis).
      common.NumericCartesianChart(
        layoutConfig: layoutConfig?.commonLayoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
      );
}

/// An ordinal combo chart supports rendering each series of data with different
/// series renderers.
class OrdinalComboChart extends cart.CartesianChart<String> {
  /// Creates an ordinal combo chart with the given series of data.
  ///
  /// [seriesList] The list of series to be plotted on the chart.
  /// [animate] Whether to animate the chart when data changes.
  /// [animationDuration] The duration of the animation when data changes.
  /// [domainAxis] The domain axis to use for the chart. If not provided, a
  /// default ordinal axis will be used.
  /// [primaryMeasureAxis] The primary measure axis to use for the chart. If
  /// not provided, a default numeric axis will be used.
  /// [secondaryMeasureAxis] The secondary measure axis to use for the chart,
  /// if needed.
  /// [defaultRenderer] The default renderer to use for the series.
  /// [customSeriesRenderers] Custom renderers for specific series, if needed.
  /// [behaviors] A list of chart behaviors to attach to the chart.
  /// [selectionModels] A list of selection models to attach to the chart.
  /// [rtlSpec] Configures the chart for right-to-left languages.
  /// [layoutConfig] Configuration for chart layout.
  /// [defaultInteractions] Whether to add the default interactions to the
  /// chart.
  const OrdinalComboChart(
    super.seriesList, {
    super.key,
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.layoutConfig,
    super.defaultInteractions,
  });

  @override
  common.BaseChart<String> createCommonChart(
    BaseChartState<String> chartState,
  ) =>
      // Optionally create primary and secondary measure axes if the chart was
      // configured with them. If no axes were configured, then the chart will
      // use its default types (usually a numeric axis).
      common.OrdinalCartesianChart(
        layoutConfig: layoutConfig?.commonLayoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
      );
}
