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
    show AxisOrientation;
import 'package:nimble_charts_common/src/chart/cartesian/axis/draw_strategy/tick_draw_strategy.dart'
    show TickDrawStrategy;
import 'package:nimble_charts_common/src/chart/cartesian/axis/ordinal_scale.dart'
    show OrdinalScale;
import 'package:nimble_charts_common/src/chart/cartesian/axis/tick.dart'
    show Tick;
import 'package:nimble_charts_common/src/chart/cartesian/axis/tick_formatter.dart'
    show TickFormatter;
import 'package:nimble_charts_common/src/chart/cartesian/axis/tick_provider.dart'
    show BaseTickProvider, TickHint;
import 'package:nimble_charts_common/src/chart/common/chart_context.dart'
    show ChartContext;
import 'package:nimble_charts_common/src/common/graphics_factory.dart'
    show GraphicsFactory;

/// A strategy for selecting ticks to draw given ordinal domain values.
class OrdinalTickProvider extends BaseTickProvider<String> {
  const OrdinalTickProvider();

  @override
  List<Tick<String>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required OrdinalScale scale,
    required TickFormatter<String> formatter,
    required Map<String, String> formatterValueCache,
    required TickDrawStrategy<String> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<String>? tickHint,
  }) =>
      createTicks(
        scale.domain.domains,
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: formatterValueCache,
        tickDrawStrategy: tickDrawStrategy,
      );

  @override
  bool operator ==(Object other) => other is OrdinalTickProvider;

  @override
  int get hashCode => 31;
}
