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

/// A bar chart that displays one or more series of data as a set of rectangles.
///
/// Each rectangle represents a single data point in the series and has a length
/// proportional to the value of that data point.
class BarChart extends cart.CartesianChart<String> {
  /// Creates a bar chart with the given series of data.
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
  /// [barGroupingType] The type of grouping to use for multiple series.
  /// [defaultRenderer] The default renderer to use for the series. If not
  /// provided, a default BarRendererConfig will be used.
  /// [customSeriesRenderers] Custom renderers for specific series, if needed.
  /// [behaviors] A list of chart behaviors to attach to the chart.
  /// [selectionModels] A list of selection models to attach to the chart.
  /// [rtlSpec] Configures the chart for right-to-left languages.
  /// [vertical] Whether to render the bars vertically (true) or horizontally
  /// (false).
  /// [defaultInteractions] Whether to add the default interactions to the
  /// chart.
  /// [layoutConfig] Configuration for chart layout.
  /// [userManagedState] Allows external management of chart state.
  /// [barRendererDecorator] A decorator for the bar renderer.
  /// [flipVerticalAxis] Whether to flip the vertical axis of the chart.
  BarChart(
    super.seriesList, {
    super.key,
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    common.BarGroupingType? barGroupingType,
    common.BarRendererConfig<String>? defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    this.vertical = true,
    super.defaultInteractions,
    super.layoutConfig,
    super.userManagedState,
    this.barRendererDecorator,
    super.flipVerticalAxis,
  }) : super(
          defaultRenderer: defaultRenderer ??
              common.BarRendererConfig<String>(
                groupingType: barGroupingType,
                barRendererDecorator: barRendererDecorator,
              ),
        );

  /// Whether the bars are rendered vertically or horizontally.
  ///
  /// If true, the bars will be rendered vertically with the domain axis along
  /// the bottom of the chart. If false, the bars will be rendered horizontally
  /// with the domain axis along the left side of the chart.
  final bool vertical;

  /// A decorator for the bar renderer that can add extra drawing on top of the
  /// bars.
  final common.BarRendererDecorator<String>? barRendererDecorator;

  @override
  common.BaseChart<String> createCommonChart(
    BaseChartState<String> chartState,
  ) =>
      // Optionally create primary and secondary measure axes if the chart was
      // configured with them. If no axes were configured, then the chart will
      // use its default types (usually a numeric axis).
      common.BarChart(
        vertical: vertical,
        layoutConfig: layoutConfig?.commonLayoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
        disjointMeasureAxes: createDisjointMeasureAxes(),
      );

  @override
  void addDefaultInteractions(List<ChartBehavior> behaviors) {
    super.addDefaultInteractions(behaviors);

    behaviors.add(DomainHighlighter<String>());
  }
}
