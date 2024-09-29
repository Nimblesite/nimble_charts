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

import 'package:nimble_charts_common/src/chart/bar/bar_renderer.dart'
    show BarRenderer;
import 'package:nimble_charts_common/src/chart/cartesian/cartesian_chart.dart'
    show OrdinalCartesianChart;
import 'package:nimble_charts_common/src/chart/common/series_renderer.dart'
    show SeriesRenderer;

class BarChart extends OrdinalCartesianChart {
  BarChart({
    super.vertical,
    super.layoutConfig,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
  });

  @override
  BarRenderer<String> makeDefaultRenderer() =>
      BarRenderer<String>()..rendererId = SeriesRenderer.defaultRendererId;
}
