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

import 'package:nimble_charts_common/src/chart/cartesian/axis/axis.dart'
    show Axis;
import 'package:nimble_charts_common/src/chart/cartesian/axis/draw_strategy/small_tick_draw_strategy.dart'
    show SmallTickRendererSpec;
import 'package:nimble_charts_common/src/chart/cartesian/axis/spec/axis_spec.dart'
    show AxisSpec;
import 'package:nimble_charts_common/src/chart/cartesian/axis/spec/date_time_axis_spec.dart'
    show DateTimeAxisSpec;
import 'package:nimble_charts_common/src/chart/cartesian/axis/time/date_time_axis.dart'
    show DateTimeAxis;
import 'package:nimble_charts_common/src/chart/cartesian/cartesian_chart.dart'
    show CartesianChart;
import 'package:nimble_charts_common/src/chart/common/series_renderer.dart'
    show SeriesRenderer;
import 'package:nimble_charts_common/src/chart/line/line_renderer.dart'
    show LineRenderer;
import 'package:nimble_charts_common/src/common/date_time_factory.dart'
    show DateTimeFactory, LocalDateTimeFactory;

class TimeSeriesChart extends CartesianChart<DateTime> {
  TimeSeriesChart({
    super.vertical,
    super.layoutConfig,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    this.dateTimeFactory = const LocalDateTimeFactory(),
  }) : super(
          domainAxis: DateTimeAxis(dateTimeFactory),
        );
  final DateTimeFactory dateTimeFactory;

  @override
  void initDomainAxis() {
    domainAxis!.tickDrawStrategy = const SmallTickRendererSpec<DateTime>()
        .createDrawStrategy(context, graphicsFactory!);
  }

  @override
  SeriesRenderer<DateTime> makeDefaultRenderer() =>
      LineRenderer<DateTime>()..rendererId = SeriesRenderer.defaultRendererId;

  @override
  Axis<DateTime> createDomainAxisFromSpec(AxisSpec<DateTime> axisSpec) =>
      (axisSpec as DateTimeAxisSpec).createDateTimeAxis(dateTimeFactory);
}
