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

import 'dart:math' show Rectangle, pi;

import 'package:mockito/mockito.dart';
import 'package:nimble_charts_common/src/chart/treemap/treemap_label_decorator.dart'
    show TreeMapLabelDecorator;
import 'package:nimble_charts_common/src/chart/treemap/treemap_renderer_element.dart'
    show TreeMapRendererElement;
import 'package:nimble_charts_common/src/common/color.dart' show Color;
import 'package:nimble_charts_common/src/common/graphics_factory.dart'
    show GraphicsFactory;
import 'package:nimble_charts_common/src/common/line_style.dart' show LineStyle;
import 'package:nimble_charts_common/src/common/text_element.dart'
    show MaxWidthStrategy, TextDirection, TextElement;
import 'package:nimble_charts_common/src/common/text_measurement.dart'
    show TextMeasurement;
import 'package:nimble_charts_common/src/common/text_style.dart' show TextStyle;
import 'package:nimble_charts_common/src/data/series.dart' show AccessorFn;
import 'package:test/test.dart';

import '../../mox.mocks.dart';

/// A fake [GraphicsFactory] that returns [FakeTextStyle] and [FakeTextElement].
class FakeGraphicsFactory extends GraphicsFactory {
  @override
  TextStyle createTextPaint() => FakeTextStyle();

  @override
  TextElement createTextElement(String text) => FakeTextElement(text);

  @override
  LineStyle createLinePaint() => MockLinePaint();
}

/// Stores [TextStyle] properties for test to verify.
class FakeTextStyle implements TextStyle {
  @override
  Color? color;

  @override
  int? fontSize;

  @override
  String? fontFamily;

  @override
  String? fontWeight;

  @override
  double? lineHeight;
}

/// Fake [TextElement] which returns text length as [horizontalSliceWidth].
///
/// Font size is returned for [verticalSliceWidth] and [baseline].
class FakeTextElement implements TextElement {
  FakeTextElement(this._text);
  final String _text;

  @override
  String get text {
    if (maxWidthStrategy == MaxWidthStrategy.ellipsize) {
      var width = measureTextWidth(_text);
      const ellipsis = '\u2026';
      final ellipsisWidth = measureTextWidth(ellipsis);
      if (width <= maxWidth! || width <= ellipsisWidth) {
        return _text;
      } else {
        var len = _text.length;
        var ellipsizedText = _text;
        while (width >= maxWidth! - ellipsisWidth && len-- > 0) {
          ellipsizedText = ellipsizedText.substring(0, len);
          width = measureTextWidth(ellipsizedText);
        }
        return '$ellipsizedText$ellipsis';
      }
    }
    return _text;
  }

  @override
  TextStyle? textStyle;

  @override
  int? maxWidth;

  @override
  MaxWidthStrategy? maxWidthStrategy;

  @override
  TextDirection textDirection = TextDirection.ltr;

  @override
  double? opacity;

  @override
  TextMeasurement get measurement => TextMeasurement(
        horizontalSliceWidth: _text.length.toDouble(),
        verticalSliceWidth: (textStyle?.fontSize ?? 12).toDouble(),
        baseline: (textStyle?.fontSize ?? 12).toDouble(),
      );

  double measureTextWidth(String text) => text.length.toDouble();
}

class FakeTreeMapRendererElement extends TreeMapRendererElement<String> {
  FakeTreeMapRendererElement(
    this.labelAccessor,
    this.data, {
    required super.boundingRect,
    required super.index,
    required super.isLeaf,
  }) : super(
          series: _createMock(labelAccessor, data),
          domain: '',
          measure: 0,
        );

  static MockImmutableSeries<String> _createMock(
    AccessorFn<String>? labelAccessor,
    List<String> data,
  ) {
    final mock = MockImmutableSeries<String>();
    when(mock.labelAccessorFn).thenReturn(labelAccessor);
    when(mock.data).thenReturn(data);
    return mock;
  }

  final AccessorFn<String>? labelAccessor;
  final List<String> data;
}

const _defaultFontSize = 12;
const _defaultLineHeight = 12.0;
const _90DegreeClockwise = pi / 2;

void main() {
  late MockCanvas canvas;
  late GraphicsFactory graphicsFactory;
  late Rectangle<int> drawBounds;

  setUpAll(() {
    canvas = MockCanvas();
    graphicsFactory = FakeGraphicsFactory();
    drawBounds = const Rectangle(0, 0, 100, 100);
  });

  group('tree map', () {
    test('label can fit in a new single line, no rotation, ltr', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'Region',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: false,
      );
      final decorator = TreeMapLabelDecorator()
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
        );

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(3));
      expect(captured[0].text, 'Region');
      expect(
        captured[0].maxWidth,
        equals(drawBounds.width - decorator.labelPadding * 2),
      );
      expect(captured[0].textDirection, equals(TextDirection.ltr));
      expect(captured[1], decorator.labelPadding);
      expect(captured[2], decorator.labelPadding);
    });

    test('label can fit in a new single line, no rotation, rtl', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'Region',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: false,
      );

      final decorator = TreeMapLabelDecorator()
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          rtl: true,
        );

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(3));
      expect(captured[0].text, 'Region');
      expect(
        captured[0].maxWidth,
        equals(drawBounds.width - decorator.labelPadding * 2),
      );
      expect(captured[0].textDirection, equals(TextDirection.rtl));
      expect(captured[1], drawBounds.width - decorator.labelPadding);
      expect(captured[2], decorator.labelPadding);
    });

    test('label can fit in a new single line, with rotation, ltr', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'Region',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: false,
      );

      final decorator = TreeMapLabelDecorator()
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          renderVertically: true,
        );

      final captured = verify(
        canvas.drawText(
          captureAny,
          captureAny,
          captureAny,
          rotation: _90DegreeClockwise,
        ),
      ).captured;
      expect(captured, hasLength(3));
      expect(captured[0].text, 'Region');
      expect(
        captured[0].maxWidth,
        equals(drawBounds.height - decorator.labelPadding * 2),
      );
      expect(captured[0].textDirection, equals(TextDirection.ltr));
      expect(
        captured[1],
        drawBounds.right - decorator.labelPadding - 2 * _defaultFontSize,
      );
      expect(captured[2], decorator.labelPadding);
    });

    test('label can fit in a new single line, with rotation, rtl', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'Region',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: false,
      );

      final decorator = TreeMapLabelDecorator()
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          rtl: true,
          renderVertically: true,
        );

      final captured = verify(
        canvas.drawText(
          captureAny,
          captureAny,
          captureAny,
          rotation: _90DegreeClockwise,
        ),
      ).captured;
      expect(captured, hasLength(3));
      expect(captured[0].text, 'Region');
      expect(
        captured[0].maxWidth,
        equals(drawBounds.height - decorator.labelPadding * 2),
      );
      expect(captured[0].textDirection, equals(TextDirection.rtl));
      expect(
        captured[1],
        equals(
          drawBounds.right - decorator.labelPadding - 2 * _defaultFontSize,
        ),
      );
      expect(captured[2], equals(drawBounds.height - decorator.labelPadding));
    });

    test('label can not fit in a new single line, no multiline', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'This Label is too long for a single line therefore it will be '
            'ellipsized with ellipsis at the end',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: false,
      );

      final decorator = TreeMapLabelDecorator()
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
        );

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(3));
      expect(captured[0].maxWidthStrategy, equals(MaxWidthStrategy.ellipsize));
      expect(
        captured[0].maxWidth,
        equals(drawBounds.width - decorator.labelPadding * 2),
      );
    });

    test(
        'label can not fit in a new single line, no rotation, ltr, with '
        'multiline. Label should be broke without cutting any word', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'This Label is too long for a single line therefore it will be '
            'ellipsized with ellipsis at the end of the new truncated label',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: true,
      );

      final decorator = TreeMapLabelDecorator(enableMultiline: true)
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          renderMultiline: renderElement.isLeaf,
        );

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(6));
      // First line.
      expect(
          captured[0].text,
          'This Label is too long for a single line therefore it will be '
          'ellipsized with ellipsis at');
      expect(captured[1], equals(decorator.labelPadding));
      expect(captured[2], equals(decorator.labelPadding));
      // Second line.
      expect(captured[3].text, 'the end of the new truncated label');
      expect(captured[4], equals(decorator.labelPadding));
      expect(
        captured[5],
        equals(decorator.labelPadding + _defaultLineHeight.toInt()),
      );
    });

    test(
        'label can not fit in a new single line, no rotation, rtl, with '
        'multiline, the first long word in the label should be cutting into '
        'two pieces', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'ThisLabelistoolongforasinglelinethereforeitwillbeellipsizedwith'
            'ellipsisattheendofthenewtruncated label',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: true,
      );

      final decorator = TreeMapLabelDecorator(enableMultiline: true)
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          rtl: true,
          renderMultiline: renderElement.isLeaf,
        );

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(6));
      // First line.
      expect(
          captured[0].text,
          'ThisLabelistoolongforasinglelinethereforeitwillbeellipsizedwithelli'
          'psisattheendofthenewtrunc');
      expect(captured[1], equals(drawBounds.width - decorator.labelPadding));
      expect(captured[2], equals(decorator.labelPadding));
      // Second line.
      expect(captured[3].text, 'ated label');
      expect(captured[4], equals(drawBounds.width - decorator.labelPadding));
      expect(
        captured[5],
        equals(decorator.labelPadding + _defaultLineHeight.toInt()),
      );
    });

    test(
        'label can not fit in a new single line or even the box, with '
        'rotation, ltr, multiline, the MaxWidthStrategy of the last '
        'line should be ellipsize', () {
      final data = ['A'];
      const rect = Rectangle(0, 0, 50, 100);
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'This Label is too long for a single line therefore it will be '
            'ellipsized with ellipsis at the end of the new truncated label '
            'This Label is too long for a single line therefore it will be '
            'ellipsized with ellipsis at the end of the new truncated label '
            'This Label is too long for a single line therefore it will be '
            'ellipsized with ellipsis at the end of the new truncated label',
        data,
        boundingRect: rect,
        index: 0,
        isLeaf: true,
      );

      final decorator = TreeMapLabelDecorator(enableMultiline: true)
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          renderVertically: true,
          renderMultiline: renderElement.isLeaf,
        );

      final captured = verify(
        canvas.drawText(
          captureAny,
          captureAny,
          captureAny,
          rotation: _90DegreeClockwise,
        ),
      ).captured;
      expect(captured, hasLength(9));
      // First line.
      expect(
        captured[1],
        equals(rect.right - decorator.labelPadding - 2 * _defaultFontSize),
      );
      expect(captured[2], equals(decorator.labelPadding));
      // Second line.
      expect(
        captured[4],
        equals(
          rect.right -
              decorator.labelPadding -
              2 * _defaultFontSize -
              _defaultLineHeight,
        ),
      );
      expect(captured[5], equals(decorator.labelPadding));
      // Last line.
      expect(captured[6].maxWidthStrategy, equals(MaxWidthStrategy.ellipsize));
      expect(
        captured[7],
        equals(
          rect.right -
              decorator.labelPadding -
              2 * _defaultFontSize -
              2 * _defaultLineHeight,
        ),
      );
      expect(captured[8], equals(decorator.labelPadding));
    });

    test(
        'label can not fit in a new single line, with rotation, rtl, '
        'multiline', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => 'This Label is too long for a single line therefore it will be '
            'ellipsized with ellipsis at the end of the new truncated label',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: true,
      );

      final decorator = TreeMapLabelDecorator(enableMultiline: true)
        ..decorate(
          renderElement,
          canvas,
          graphicsFactory,
          drawBounds: drawBounds,
          animationPercent: 1,
          renderVertically: true,
          rtl: true,
          renderMultiline: renderElement.isLeaf,
        );

      final captured = verify(
        canvas.drawText(
          captureAny,
          captureAny,
          captureAny,
          rotation: _90DegreeClockwise,
        ),
      ).captured;
      expect(captured, hasLength(6));
      // First line.
      expect(
        captured[1],
        equals(
          drawBounds.right - decorator.labelPadding - 2 * _defaultFontSize,
        ),
      );
      expect(captured[2], equals(drawBounds.height - decorator.labelPadding));
      // Second line.
      expect(
        captured[4],
        equals(
          drawBounds.right -
              decorator.labelPadding -
              2 * _defaultFontSize -
              _defaultLineHeight,
        ),
      );
      expect(captured[5], equals(drawBounds.height - decorator.labelPadding));
    });
  });

  group('Null and empty label scenarios', () {
    test('Skip label if label accessor does not exist', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        null,
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: true,
      );

      TreeMapLabelDecorator().decorate(
        renderElement,
        canvas,
        graphicsFactory,
        drawBounds: drawBounds,
        animationPercent: 1,
      );

      verifyNever(canvas.drawText(any, any, any));
    });

    test('Skip label if label is empty', () {
      final data = ['A'];
      final renderElement = FakeTreeMapRendererElement(
        (_) => '',
        data,
        boundingRect: drawBounds,
        index: 0,
        isLeaf: true,
      );

      TreeMapLabelDecorator().decorate(
        renderElement,
        canvas,
        graphicsFactory,
        drawBounds: drawBounds,
        animationPercent: 1,
      );

      verifyNever(canvas.drawText(any, any, any));
    });
  });
}
