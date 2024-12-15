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

import 'package:flutter/material.dart';
import 'package:nimble_charts/src/behaviors/chart_behavior.dart';
import 'package:nimble_charts_common/common.dart' as common;

/// Chart behavior that centers the viewport on the selected domain.
///
/// It is used in combination with SelectNearest to update the selection model
/// and notify this behavior to update the viewport on selection change.
///
/// This behavior can only be used on [common.CartesianChart].
@immutable
class SlidingViewport<D> extends ChartBehavior<D> {
  SlidingViewport([this.selectionModelType = common.SelectionModelType.info]);
  @override
  final desiredGestures = <GestureType>{};

  /// The type of selection model to monitor for viewport changes.
  final common.SelectionModelType selectionModelType;

  @override
  common.SlidingViewport<D> createCommonBehavior() =>
      common.SlidingViewport<D>(selectionModelType);

  @override
  void updateCommonBehavior(common.ChartBehavior<D> commonBehavior) {}

  @override
  String get role => 'slidingViewport-$selectionModelType';

  @override
  bool operator ==(Object other) =>
      other is SlidingViewport &&
      selectionModelType == other.selectionModelType;

  @override
  int get hashCode => selectionModelType.hashCode;
}
