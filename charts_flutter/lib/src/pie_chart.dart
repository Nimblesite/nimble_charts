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

import 'package:nimble_charts/src/base_chart.dart' show BaseChart;
import 'package:nimble_charts/src/base_chart_state.dart' show BaseChartState;
import 'package:nimble_charts_common/common.dart' as common
    show ArcRendererConfig, PieChart;

/// A pie chart that displays data as a circle divided into sectors, each
/// representing a proportion of the whole.
class PieChart<D> extends BaseChart<D> {
  /// Creates a pie chart with the given series of data.
  ///
  /// [seriesList] The list of series to be plotted on the chart. A pie chart
  /// typically expects a single series.
  /// [animate] Whether to animate the chart when data changes.
  /// [animationDuration] The duration of the animation when data changes.
  /// [defaultRenderer] The default renderer to use for the series. If not
  /// provided, a default ArcRendererConfig will be used.
  /// [behaviors] A list of chart behaviors to attach to the chart.
  /// [selectionModels] A list of selection models to attach to the chart.
  /// [rtlSpec] Configures the chart for right-to-left languages.
  /// [layoutConfig] Configuration for chart layout.
  /// [defaultInteractions] Whether to add the default interactions to the
  /// chart.
  const PieChart(
    super.seriesList, {
    super.key,
    super.animate,
    super.animationDuration,
    common.ArcRendererConfig<D>? super.defaultRenderer,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.layoutConfig,
    super.defaultInteractions,
  });

  @override
  common.PieChart<D> createCommonChart(BaseChartState chartState) =>
      common.PieChart<D>(layoutConfig: layoutConfig?.commonLayoutConfig);
}
