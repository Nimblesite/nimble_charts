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

import 'dart:math';

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/selection/lock_selection.dart';
import 'package:nimble_charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:nimble_charts_common/src/common/gesture_listener.dart';
import 'package:test/test.dart';

import '../../../../mox.mocks.dart';

class MockChart extends MockBaseChart<dynamic> {
  GestureListener? lastListener;

  @override
  GestureListener addGestureListener(GestureListener? listener) {
    lastListener = listener;
    return listener!;
  }

  @override
  void removeGestureListener(GestureListener? listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
  }
}

class MockSelectionModel extends MockMutableSelectionModel<dynamic> {
  bool _locked = false;

  @override
  bool get locked => _locked;

  @override
  set locked(bool? value) {
    if (value != null) {
      _locked = value;
    }
  }
}

void main() {
  late MockChart chart;
  late MockSelectionModel hoverSelectionModel;
  late MockSelectionModel clickSelectionModel;

  LockSelection<dynamic> makeLockSelectionBehavior(
    SelectionModelType selectionModelType,
  ) {
    final behavior = LockSelection<dynamic>(
      selectionModelType: selectionModelType,
    )..attachTo(chart);

    return behavior;
  }

  void setupChart({
    required Point<double> forPoint,
    required bool isWithinRenderer,
  }) {
    when(chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
  }

  setUp(() {
    hoverSelectionModel = MockSelectionModel();
    clickSelectionModel = MockSelectionModel();

    chart = MockChart();
    when(chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(hoverSelectionModel);
    when(chart.getSelectionModel(SelectionModelType.action))
        .thenReturn(clickSelectionModel);
  });

  group('LockSelection trigger handling', () {
    test('can lock model with a selection', () {
      // Setup chart matches point with single domain single series.
      makeLockSelectionBehavior(SelectionModelType.info);
      const point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true);

      when(hoverSelectionModel.hasAnySelection).thenReturn(true);

      // Act
      chart.lastListener?.onTapTest(point);
      chart.lastListener?.onTap?.call(point);

      // Validate
      verify(hoverSelectionModel.hasAnySelection);
      expect(hoverSelectionModel.locked, equals(true));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('can lock and unlock model', () {
      // Setup chart matches point with single domain single series.
      makeLockSelectionBehavior(SelectionModelType.info);
      const point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true);

      when(hoverSelectionModel.hasAnySelection).thenReturn(true);

      //TODO: this makes the test pass, but not sure if it's the
      //right way to do it
      //when(hoverSelectionModel.clearSelection()).thenReturn(true);

      // Act
      chart.lastListener?.onTapTest(point);
      chart.lastListener?.onTap?.call(point);

      // Validate
      verify(hoverSelectionModel.hasAnySelection);
      expect(hoverSelectionModel.locked, equals(true));

      // Act
      chart.lastListener?.onTapTest(point);
      chart.lastListener?.onTap?.call(point);

      // Validate
      verify(hoverSelectionModel.clearSelection());
      expect(hoverSelectionModel.locked, equals(false));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not lock model with empty selection', () {
      // Setup chart matches point with single domain single series.
      makeLockSelectionBehavior(SelectionModelType.info);
      const point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true);

      when(hoverSelectionModel.hasAnySelection).thenReturn(false);

      // Act
      chart.lastListener?.onTapTest(point);
      chart.lastListener?.onTap?.call(point);

      // Validate
      verify(hoverSelectionModel.hasAnySelection);
      expect(hoverSelectionModel.locked, equals(false));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      final behavior = makeLockSelectionBehavior(SelectionModelType.info);
      const point = Point<double>(100, 100);
      setupChart(forPoint: point, isWithinRenderer: true);
      expect(chart.lastListener, isNotNull);

      // Act
      behavior.removeFrom(chart);

      // Validate
      expect(chart.lastListener, isNull);
    });
  });
}
