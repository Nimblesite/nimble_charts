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

import 'package:nimble_charts_common/common.dart';
import 'package:nimble_charts_common/src/chart/cartesian/axis/scale.dart'
    show MutableScale;
import 'package:nimble_charts_common/src/chart/cartesian/axis/static_tick_provider.dart'
    show StaticTickProvider;
import 'package:nimble_charts_common/src/chart/cartesian/axis/tick_provider.dart'
    show TickHint, TickProvider;

/// A strategy that selects ticks without them colliding.
///
/// It selects every Nth tick, where N is the smallest tick increment from
/// [allowedTickIncrements] such that ticks do not collide. If no such increment
/// exists, ticks for the first step increment are returned;
///
/// The [TextStyle] is not overridden during [TickDrawStrategy.decorateTicks].
/// If the [TickSpec] style is null, then the default [TextStyle] is used.
class AutoAdjustingStaticTickProvider<D> extends TickProvider<D> {
  AutoAdjustingStaticTickProvider(this.tickSpec, this.allowedTickIncrements);
  final List<TickSpec<D>> tickSpec;
  final List<int> allowedTickIncrements;

  @override
  List<Tick<D>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required MutableScale<D> scale,
    required TickFormatter<D> formatter,
    required Map<D, String> formatterValueCache,
    required TickDrawStrategy<D> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<D>? tickHint,
  }) {
    var ticksForTheFirstIncrement = <Tick<D>>[];
    for (final tickIncrement in allowedTickIncrements) {
      final staticTickProvider =
          StaticTickProvider(tickSpec, tickIncrement: tickIncrement);
      final ticks = staticTickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: formatterValueCache,
        tickDrawStrategy: tickDrawStrategy,
        orientation: orientation,
        viewportExtensionEnabled: viewportExtensionEnabled,
        tickHint: tickHint,
      );
      if (ticksForTheFirstIncrement.isEmpty) {
        ticksForTheFirstIncrement = ticks;
      }
      final collisionReport = tickDrawStrategy.collides(ticks, orientation);
      if (!collisionReport.ticksCollide) {
        // Return the first non colliding ticks.
        return ticks;
      }
    }
    return ticksForTheFirstIncrement;
  }

  @override
  bool operator ==(Object other) =>
      other is AutoAdjustingStaticTickProvider &&
      tickSpec == other.tickSpec &&
      allowedTickIncrements == other.allowedTickIncrements;

  @override
  int get hashCode => tickSpec.hashCode;
}
