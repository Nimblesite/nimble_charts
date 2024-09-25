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

import 'package:meta/meta.dart' show immutable;
import 'package:nimble_charts_common/common.dart';

/// Default [AxisSpec] used for Timeseries charts.
@immutable
class EndPointsTimeAxisSpec extends DateTimeAxisSpec {
  /// Creates a [AxisSpec] that specialized for timeseries charts.
  ///
  /// [renderSpec] spec used to configure how the ticks and labels
  ///     actually render. Possible values are [GridlineRendererSpec],
  ///     [SmallTickRendererSpec] & [NoneRenderSpec]. Make sure that the <D>
  ///     given to the RenderSpec is of type [DateTime] for Timeseries.
  /// [tickProviderSpec] spec used to configure what ticks are generated.
  /// [tickFormatterSpec] spec used to configure how the tick labels
  ///     are formatted.
  /// [showAxisLine] override to force the axis to draw the axis
  ///     line.
  const EndPointsTimeAxisSpec({
    RenderSpec<DateTime>? renderSpec,
    DateTimeTickProviderSpec? tickProviderSpec,
    super.tickFormatterSpec,
    super.showAxisLine,
    super.viewport,
  }) : super(
          renderSpec: renderSpec ??
              const SmallTickRendererSpec<DateTime>(
                labelAnchor: TickLabelAnchor.inside,
                labelOffsetFromTickPx: 0,
              ),
          tickProviderSpec:
              tickProviderSpec ?? const DateTimeEndPointsTickProviderSpec(),
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EndPointsTimeAxisSpec && super == other);

  @override
  int get hashCode => (super.hashCode * 37) + runtimeType.hashCode;
}
