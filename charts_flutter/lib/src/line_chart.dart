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

import 'package:nimble_charts/flutter.dart';
import 'package:nimble_charts/src/base_chart_state.dart';
import 'package:nimble_charts/src/cartesian_chart.dart' as cart;
import 'package:nimble_charts_common/common.dart' as common;

/// A line chart that displays data as a series of points connected by straight
/// line segments.
class LineChart extends cart.CartesianChart<num> {
  /// Creates a line chart with the given series of data.
  ///
  /// [seriesList] The list of series to be plotted on the chart.
  /// [animate] Whether to animate the chart when data changes.
  /// [animationDuration] The duration of the animation when data changes.
  /// [domainAxis] The domain axis to use for the chart. If not provided, a
  /// default axis will be used.
  /// [primaryMeasureAxis] The primary measure axis to use for the chart. If
  /// not provided, a default numeric axis will be used.
  /// [secondaryMeasureAxis] The secondary measure axis to use for the chart,
  /// if needed.
  /// [disjointMeasureAxes] A map of measure axes for disjoint domains,
  /// if needed.
  /// [defaultRenderer] The default renderer to use for the series. If not
  /// provided, a default LineRendererConfig will be used.
  /// [customSeriesRenderers] Custom renderers for specific series, if needed.
  /// [behaviors] A list of chart behaviors to attach to the chart.
  /// [selectionModels] A list of selection models to attach to the chart.
  /// [rtlSpec] Configures the chart for right-to-left languages.
  /// [layoutConfig] Configuration for chart layout.
  /// [defaultInteractions] Whether to add the default interactions to the
  /// chart.
  /// [flipVerticalAxis] Whether to flip the vertical axis of the chart.
  /// [userManagedState] Allows external management of chart state.
  const LineChart(
    super.seriesList, {
    super.key,
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    common.LineRendererConfig<num>? super.defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.layoutConfig,
    super.defaultInteractions,
    super.flipVerticalAxis,
    super.userManagedState,
  });

  @override
  common.LineChart createCommonChart(BaseChartState chartState) =>
      // Optionally create primary and secondary measure axes if the chart was
      // configured with them. If no axes were configured, then the chart will
      // use its default types (usually a numeric axis).
      common.LineChart(
        layoutConfig: layoutConfig?.commonLayoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
        disjointMeasureAxes: createDisjointMeasureAxes(),
      );

  @override
  void addDefaultInteractions(List<ChartBehavior> behaviors) {
    super.addDefaultInteractions(behaviors);

    behaviors.add(LinePointHighlighter<num>());
  }
}
