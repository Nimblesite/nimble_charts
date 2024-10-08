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

import 'package:nimble_charts_common/src/chart/cartesian/axis/axis_tick.dart'
    show AxisTicks;
import 'package:nimble_charts_common/src/chart/cartesian/axis/range_tick.dart'
    show RangeTick;

class RangeAxisTicks<D> extends AxisTicks<D> {
  RangeAxisTicks(RangeTick<D> super.tick)
      : rangeStartValue = tick.rangeStartValue,
        rangeStartLocationPx = tick.rangeStartLocationPx,
        rangeEndValue = tick.rangeEndValue,
        rangeEndLocationPx = tick.rangeEndLocationPx;

  /// The value that this range tick starting point represents
  final D rangeStartValue;

  /// Position of the range tick starting point.
  double rangeStartLocationPx;

  /// The value that this range tick ending point represents.
  final D rangeEndValue;

  /// Position of the range tick ending point.
  double rangeEndLocationPx;
}
