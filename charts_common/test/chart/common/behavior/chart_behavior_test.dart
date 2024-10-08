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

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/common/base_chart.dart';
import 'package:nimble_charts_common/src/chart/common/behavior/chart_behavior.dart';
import 'package:nimble_charts_common/src/chart/common/datum_details.dart';
import 'package:nimble_charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:nimble_charts_common/src/chart/common/series_renderer.dart';
import 'package:test/test.dart';

import '../../../mox.mocks.dart';

class ParentBehavior implements ChartBehavior<String> {
  ParentBehavior(this.child);
  final ChartBehavior<String> child;

  @override
  String get role => '';

  @override
  void attachTo(BaseChart<String> chart) {
    chart.addBehavior(child);
  }

  @override
  void removeFrom(BaseChart<String> chart) {
    chart.removeBehavior(child);
  }
}

class ConcreteChart extends BaseChart<String> {
  @override
  SeriesRenderer<String> makeDefaultRenderer() => throw UnimplementedError();

  @override
  List<DatumDetails<String>> getDatumDetails(SelectionModelType _) =>
      throw UnimplementedError();
}

void main() {
  late ConcreteChart chart;
  late MockBehavior<String> namedBehavior;
  late MockBehavior<String> unnamedBehavior;

  setUp(() {
    chart = ConcreteChart();

    namedBehavior = MockBehavior();
    when(namedBehavior.role).thenReturn('foo');

    unnamedBehavior = MockBehavior();
    when(unnamedBehavior.role).thenReturn('_role_'); // can't do null here
  });

  group('Attach & Detach', () {
    test('attach is called once', () {
      chart.addBehavior(namedBehavior);
      verify(namedBehavior.attachTo(chart)).called(1);

      verify(namedBehavior.role);
      verifyNoMoreInteractions(namedBehavior);
    });

    test('detach is called once', () {
      chart.addBehavior(namedBehavior);
      verify(namedBehavior.attachTo(chart)).called(1);

      chart.removeBehavior(namedBehavior);
      verify(namedBehavior.removeFrom(chart)).called(1);

      verify(namedBehavior.role);
      verifyNoMoreInteractions(namedBehavior);
    });

    test('detach is called when name is reused', () {
      final otherBehavior = MockBehavior<String>();
      when(otherBehavior.role).thenReturn('foo');

      chart.addBehavior(namedBehavior);
      verify(namedBehavior.attachTo(chart)).called(1);

      chart.addBehavior(otherBehavior);
      verify(namedBehavior.removeFrom(chart)).called(1);
      verify(otherBehavior.attachTo(chart)).called(1);

      verify(namedBehavior.role);
      verify(otherBehavior.role);
      verifyNoMoreInteractions(namedBehavior);
      verifyNoMoreInteractions(otherBehavior);
    });

    test('detach is not called when name is null', () {
      chart.addBehavior(namedBehavior);
      verify(namedBehavior.attachTo(chart)).called(1);

      chart.addBehavior(unnamedBehavior);
      verify(unnamedBehavior.attachTo(chart)).called(1);

      verify(namedBehavior.role);
      verify(unnamedBehavior.role);
      verifyNoMoreInteractions(namedBehavior);
      verifyNoMoreInteractions(unnamedBehavior);
    });

    test('detach is not called when name is different', () {
      final otherBehavior = MockBehavior<String>();
      when(otherBehavior.role).thenReturn('bar');

      chart.addBehavior(namedBehavior);
      verify(namedBehavior.attachTo(chart)).called(1);

      chart.addBehavior(otherBehavior);
      verify(otherBehavior.attachTo(chart)).called(1);

      verify(namedBehavior.role);
      verify(otherBehavior.role);
      verifyNoMoreInteractions(namedBehavior);
      verifyNoMoreInteractions(otherBehavior);
    });

    test('behaviors are removed when chart is destroyed', () {
      final parentBehavior = ParentBehavior(unnamedBehavior);

      chart.addBehavior(parentBehavior);
      // The parent should add the child behavior.
      verify(unnamedBehavior.attachTo(chart)).called(1);

      chart.destroy();

      // The parent should remove the child behavior.
      verify(unnamedBehavior.removeFrom(chart)).called(1);

      // Remove should only be called once and shouldn't trigger a concurrent
      // modification exception.
      verify(unnamedBehavior.role);
      verifyNoMoreInteractions(unnamedBehavior);
    });
  });
}
