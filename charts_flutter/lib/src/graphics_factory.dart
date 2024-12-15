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

import 'package:flutter/widgets.dart'
    show BuildContext, DefaultTextStyle, MediaQuery;
import 'package:nimble_charts/src/line_style.dart' show LineStyle;
import 'package:nimble_charts/src/text_element.dart' show TextElement;
import 'package:nimble_charts/src/text_style.dart' show TextStyle;
import 'package:nimble_charts_common/common.dart' as common
    show GraphicsFactory, LineStyle, TextElement, TextStyle;

/// A Flutter implementation of [common.GraphicsFactory] that creates graphics
/// elements for chart rendering.
///
/// This factory creates text elements, text styles, and line styles that are
/// used to render various chart components in a Flutter environment.
class GraphicsFactory implements common.GraphicsFactory {
  /// Creates a new [GraphicsFactory] with the given build context.
  ///
  /// [context] The build context used to access text styling information.
  /// [helper] Optional helper for accessing MediaQuery information.
  GraphicsFactory(
    BuildContext context, {
    GraphicsFactoryHelper helper = const GraphicsFactoryHelper(),
  })  : textScaleFactor = helper.getTextScaleFactorOf(context),
        defaultTextStyle = DefaultTextStyle.of(context);

  /// The text scale factor from the MediaQuery.
  final double textScaleFactor;

  /// The default text style from the build context.
  final DefaultTextStyle defaultTextStyle;

  /// Creates a new [TextStyle] with default properties.
  ///
  /// The text style will inherit the font family from the default text style.
  @override
  common.TextStyle createTextPaint() =>
      TextStyle()..fontFamily = defaultTextStyle.style.fontFamily;

  /// Creates a new [TextElement] with the given text.
  ///
  /// [text] The text content for the element.
  /// The text element will use the current text scale factor and default text
  /// style.
  @override
  common.TextElement createTextElement(String text) =>
      TextElement(text, textScaleFactor: textScaleFactor)
        ..textStyle = createTextPaint();

  /// Creates a new [LineStyle] with default properties.
  @override
  common.LineStyle createLinePaint() => LineStyle();
}

/// Helper class for accessing MediaQuery information.
///
/// This class wraps MediaQuery functionality to allow for testing and
/// dependency injection.
class GraphicsFactoryHelper {
  /// Creates a new [GraphicsFactoryHelper].
  const GraphicsFactoryHelper();

  /// Gets the text scale factor from the MediaQuery of the given context.
  ///
  /// [context] The build context to get the text scale factor from.
  double getTextScaleFactorOf(BuildContext context) =>
      MediaQuery.textScaleFactorOf(context);
}
