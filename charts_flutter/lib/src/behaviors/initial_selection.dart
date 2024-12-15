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

import 'package:collection/collection.dart' show ListEquality;
import 'package:meta/meta.dart' show immutable;
import 'package:nimble_charts/src/behaviors/chart_behavior.dart'
    show ChartBehavior, GestureType;
import 'package:nimble_charts_common/common.dart' as common
    show ChartBehavior, InitialSelection, SelectionModelType, SeriesDatumConfig;

/// Chart behavior that sets the initial selection for a [selectionModelType].
@immutable
class InitialSelection<D> extends ChartBehavior<D> {
  InitialSelection({
    this.selectionModelType = common.SelectionModelType.info,
    this.selectedSeriesConfig,
    this.selectedDataConfig,
    this.shouldPreserveSelectionOnDraw = false,
  });
  @override
  final desiredGestures = <GestureType>{};

  /// The type of selection model to set initial selection for.
  final common.SelectionModelType selectionModelType;

  /// List of series IDs that should be initially selected.
  final List<String>? selectedSeriesConfig;

  /// List of specific data points that should be initially selected.
  final List<common.SeriesDatumConfig<D>>? selectedDataConfig;

  /// Whether to preserve the selection when the chart is redrawn.
  final bool shouldPreserveSelectionOnDraw;

  @override
  common.InitialSelection<D> createCommonBehavior() =>
      common.InitialSelection<D>(
        selectionModelType: selectionModelType,
        selectedDataConfig: selectedDataConfig,
        selectedSeriesConfig: selectedSeriesConfig,
        shouldPreserveSelectionOnDraw: shouldPreserveSelectionOnDraw,
      );

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {}

  @override
  String get role => 'InitialSelection-$selectionModelType';

  @override
  bool operator ==(Object other) =>
      other is InitialSelection &&
      selectionModelType == other.selectionModelType &&
      const ListEquality()
          .equals(selectedSeriesConfig, other.selectedSeriesConfig) &&
      const ListEquality().equals(selectedDataConfig, other.selectedDataConfig);

  @override
  int get hashCode {
    var hashcode = selectionModelType.hashCode;
    hashcode = hashcode * 37 + (selectedSeriesConfig?.hashCode ?? 0);
    hashcode = hashcode * 37 + (selectedDataConfig?.hashCode ?? 0);
    return hashcode;
  }
}
