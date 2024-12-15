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

/// Chart behavior that monitors the specified [common.SelectionModel] and
/// darkens the color for selected data.
///
/// This is typically used for bars and pies to highlight segments.
///
/// It is used in combination with SelectNearest to update the selection model
/// and expand selection out to the domain value.
@immutable
class DomainHighlighter<D> extends ChartBehavior<D> {
  DomainHighlighter([this.selectionModelType = common.SelectionModelType.info]);
  @override
  final desiredGestures = <GestureType>{};

  /// The type of selection model to monitor for highlighting.
  final common.SelectionModelType selectionModelType;

  @override
  common.DomainHighlighter<D> createCommonBehavior() =>
      common.DomainHighlighter<D>(selectionModelType);

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {}

  @override
  String get role => 'domainHighlight-$selectionModelType';

  @override
  bool operator ==(Object other) =>
      other is DomainHighlighter &&
      selectionModelType == other.selectionModelType;

  @override
  int get hashCode => selectionModelType.hashCode;
}
