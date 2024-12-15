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

import 'dart:math' show Point, Rectangle, max;
import 'dart:ui' as ui show Gradient, Shader;

import 'package:flutter/material.dart';
import 'package:nimble_charts/src/canvas/circle_sector_painter.dart'
    show CircleSectorPainter;
import 'package:nimble_charts/src/canvas/line_painter.dart' show LinePainter;
import 'package:nimble_charts/src/canvas/pie_painter.dart' show PiePainter;
import 'package:nimble_charts/src/canvas/point_painter.dart' show PointPainter;
import 'package:nimble_charts/src/canvas/polygon_painter.dart'
    show PolygonPainter;
import 'package:nimble_charts/src/text_element.dart' show TextElement;
import 'package:nimble_charts_common/common.dart' as common
    show
        BlendMode,
        CanvasBarStack,
        CanvasPie,
        ChartCanvas,
        Color,
        FillPatternType,
        GraphicsFactory,
        Link,
        LinkOrientation,
        StyleFactory,
        TextDirection,
        TextElement;

/// A Flutter implementation of [common.ChartCanvas] that delegates drawing to
/// a [Canvas].
///
/// This class provides the core drawing functionality for charts in Flutter,
/// implementing various drawing methods for shapes, lines, text, and other
/// chart elements.
class ChartCanvas implements common.ChartCanvas {
  /// Creates a new [ChartCanvas] that will draw on the given [canvas].
  ///
  /// [canvas] The Flutter canvas to draw on.
  /// [graphicsFactory] Factory used to create graphics elements.
  ChartCanvas(this.canvas, this.graphicsFactory);

  /// Pixels to allow to overdraw above the draw area that fades to transparent.
  static const double rect_top_gradient_pixels = 5;

  /// The Flutter canvas to draw on.
  final Canvas canvas;

  /// Factory used to create graphics elements.
  @override
  final common.GraphicsFactory graphicsFactory;

  /// Paint object used for all drawing operations.
  final _paint = Paint();

  /// Draws a sector of a circle, with optional fill and stroke.
  ///
  /// [center] The center point of the circle.
  /// [radius] The radius of the circle.
  /// [innerRadius] The inner radius for hollow circles.
  /// [startAngle] The starting angle in radians.
  /// [endAngle] The ending angle in radians.
  /// [fill] The fill color.
  /// [stroke] The stroke color.
  /// [strokeWidthPx] The stroke width in pixels.
  @override
  void drawCircleSector(
    Point center,
    double radius,
    double innerRadius,
    double startAngle,
    double endAngle, {
    common.Color? fill,
    common.Color? stroke,
    double? strokeWidthPx,
  }) {
    CircleSectorPainter.draw(
      canvas: canvas,
      paint: _paint,
      center: center,
      radius: radius,
      innerRadius: innerRadius,
      startAngle: startAngle,
      endAngle: endAngle,
      fill: fill,
    );
  }

  @override
  void drawLink(
    common.Link link,
    common.LinkOrientation orientation,
    common.Color fill,
  ) {
    // TODO: Implement drawLink for flutter.
    throw UnimplementedError('Flutter drawLink() has not been implemented.');
  }

  /// Draws a line with the specified style and points.
  ///
  /// [points] The points to draw the line through.
  /// [clipBounds] The clip bounds to apply.
  /// [fill] The fill color.
  /// [stroke] The stroke color.
  /// [roundEndCaps] Whether to use round end caps.
  /// [strokeWidthPx] The stroke width in pixels.
  /// [dashPattern] The dash pattern to use.
  @override
  void drawLine({
    required List<Point> points,
    Rectangle<num>? clipBounds,
    common.Color? fill,
    common.Color? stroke,
    bool? roundEndCaps,
    double? strokeWidthPx,
    List<int>? dashPattern,
  }) {
    LinePainter.draw(
      canvas: canvas,
      paint: _paint,
      points: points,
      clipBounds: clipBounds,
      fill: fill,
      stroke: stroke,
      roundEndCaps: roundEndCaps,
      strokeWidthPx: strokeWidthPx,
      dashPattern: dashPattern,
    );
  }

  /// Draws a pie chart segment.
  ///
  /// [canvasPie] The pie segment to draw.
  @override
  void drawPie(common.CanvasPie canvasPie) {
    PiePainter.draw(canvas, _paint, canvasPie);
  }

  /// Draws a point at the specified location.
  ///
  /// [point] The point location.
  /// [radius] The radius of the point.
  /// [fill] The fill color.
  /// [stroke] The stroke color.
  /// [strokeWidthPx] The stroke width in pixels.
  /// [blendMode] The blend mode to use.
  @override
  void drawPoint({
    required Point point,
    required double radius,
    common.Color? fill,
    common.Color? stroke,
    double? strokeWidthPx,
    common.BlendMode? blendMode,
  }) {
    PointPainter.draw(
      canvas: canvas,
      paint: _paint,
      point: point,
      radius: radius,
      fill: fill,
      stroke: stroke,
      strokeWidthPx: strokeWidthPx,
    );
  }

  @override
  void drawPolygon({
    required List<Point> points,
    Rectangle<num>? clipBounds,
    common.Color? fill,
    common.Color? stroke,
    double? strokeWidthPx,
  }) {
    PolygonPainter.draw(
      canvas: canvas,
      paint: _paint,
      points: points,
      clipBounds: clipBounds,
      fill: fill,
      stroke: stroke,
      strokeWidthPx: strokeWidthPx,
    );
  }

  /// Creates a bottom to top gradient that transitions [fill] to transparent.
  ui.Gradient _createHintGradient(double left, double top, common.Color fill) =>
      ui.Gradient.linear(
        Offset(left, top),
        Offset(left, top - rect_top_gradient_pixels),
        [
          Color.fromARGB(fill.a, fill.r, fill.g, fill.b),
          Color.fromARGB(0, fill.r, fill.g, fill.b),
        ],
      );

  /// Draws a rectangle with the specified bounds and style.
  ///
  /// [bounds] The bounds of the rectangle.
  /// [fill] The fill color.
  /// [pattern] The fill pattern type.
  /// [stroke] The stroke color.
  /// [strokeWidthPx] The stroke width in pixels.
  /// [drawAreaBounds] Optional bounds for gradient drawing area.
  @override
  void drawRect(
    Rectangle<num> bounds, {
    common.Color? fill,
    common.FillPatternType? pattern,
    common.Color? stroke,
    double? strokeWidthPx,
    Rectangle<num>? drawAreaBounds,
  }) {
    // TODO: remove this explicit `bool` type when no longer needed
    // to work around https://github.com/dart-lang/language/issues/1785
    final drawStroke =
        strokeWidthPx != null && strokeWidthPx > 0.0 && stroke != null;

    final strokeWidthOffset = (drawStroke ? strokeWidthPx : 0);

    // Factor out stroke width, if a stroke is enabled.
    final fillRectBounds = Rectangle<num>(
      bounds.left + strokeWidthOffset / 2,
      bounds.top + strokeWidthOffset / 2,
      bounds.width - strokeWidthOffset,
      bounds.height - strokeWidthOffset,
    );

    switch (pattern) {
      case common.FillPatternType.forwardHatch:
        _drawForwardHatchPattern(
          fillRectBounds,
          canvas,
          fill: fill,
          drawAreaBounds: drawAreaBounds,
        );

      case common.FillPatternType.solid:
      case null:
        // Use separate rect for drawing stroke
        _paint.color = Color.fromARGB(fill!.a, fill.r, fill.g, fill.b);
        _paint.style = PaintingStyle.fill;

        // Apply a gradient to the top [rect_top_gradient_pixels] to transparent
        // if the rectangle is higher than the [drawAreaBounds] top.
        if (drawAreaBounds != null && bounds.top < drawAreaBounds.top) {
          _paint.shader = _createHintGradient(
            drawAreaBounds.left.toDouble(),
            drawAreaBounds.top.toDouble(),
            fill,
          );
        }

        canvas.drawRect(_getRect(fillRectBounds), _paint);
    }

    // [Canvas.drawRect] does not support drawing a rectangle with both a fill
    // and a stroke at this time. Use a separate rect for the stroke.
    if (drawStroke) {
      _paint
        ..color = Color.fromARGB(stroke.a, stroke.r, stroke.g, stroke.b)
        // Set shader to null if no draw area bounds so it can use the color
        // instead.
        ..shader = drawAreaBounds != null
            ? _createHintGradient(
                drawAreaBounds.left.toDouble(),
                drawAreaBounds.top.toDouble(),
                stroke,
              )
            : null;

      // ignore: cascade_invocations
      _paint
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = strokeWidthPx
        ..style = PaintingStyle.stroke;

      canvas.drawRect(_getRect(bounds), _paint);
    }

    // Reset the shader.
    _paint.shader = null;
  }

  /// Draws a rounded rectangle with the specified bounds and style.
  ///
  /// [bounds] The bounds of the rectangle.
  /// [fill] The fill color.
  /// [stroke] The stroke color.
  /// [patternColor] The pattern color.
  /// [fillPattern] The fill pattern type.
  /// [patternStrokeWidthPx] The pattern stroke width in pixels.
  /// [strokeWidthPx] The stroke width in pixels.
  /// [radius] The corner radius.
  /// [roundTopLeft] Whether to round the top left corner.
  /// [roundTopRight] Whether to round the top right corner.
  /// [roundBottomLeft] Whether to round the bottom left corner.
  /// [roundBottomRight] Whether to round the bottom right corner.
  @override
  void drawRRect(
    Rectangle<num> bounds, {
    common.Color? fill,
    common.Color? stroke,
    common.Color? patternColor,
    common.FillPatternType? fillPattern,
    double? patternStrokeWidthPx,
    double? strokeWidthPx,
    num? radius,
    bool roundTopLeft = false,
    bool roundTopRight = false,
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  }) {
    // Use separate rect for drawing stroke
    _paint
      ..color = Color.fromARGB(fill!.a, fill.r, fill.g, fill.b)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      _getRRect(
        bounds,
        radius: radius?.toDouble() ?? 0.0,
        roundTopLeft: roundTopLeft,
        roundTopRight: roundTopRight,
        roundBottomLeft: roundBottomLeft,
        roundBottomRight: roundBottomRight,
      ),
      _paint,
    );
  }

  /// Draws a stack of bars with the specified configuration.
  ///
  /// [barStack] The stack of bars to draw.
  /// [drawAreaBounds] Optional bounds for gradient drawing area.
  @override
  void drawBarStack(
    common.CanvasBarStack barStack, {
    Rectangle<num>? drawAreaBounds,
  }) {
    // only clip if rounded rect.

    // Clip a rounded rect for the whole region if rounded bars.
    final roundedCorners = barStack.radius != null && 0 < barStack.radius!;

    if (roundedCorners) {
      canvas
        ..save()
        ..clipRRect(
          _getRRect(
            barStack.fullStackRect,
            radius: barStack.radius!.toDouble(),
            roundTopLeft: barStack.roundTopLeft,
            roundTopRight: barStack.roundTopRight,
            roundBottomLeft: barStack.roundBottomLeft,
            roundBottomRight: barStack.roundBottomRight,
          ),
        );
    }

    // Draw each bar.
    for (var barIndex = 0; barIndex < barStack.segments.length; barIndex++) {
      // TODO: Add configuration for hiding stack line.
      // TODO: Don't draw stroke on bottom of bars.
      final segment = barStack.segments[barIndex];
      drawRect(
        segment.bounds,
        fill: segment.fill,
        pattern: segment.pattern,
        stroke: segment.stroke,
        strokeWidthPx: segment.strokeWidthPx,
        drawAreaBounds: drawAreaBounds,
      );
    }

    if (roundedCorners) {
      canvas.restore();
    }
  }

  /// Draws text with the specified configuration.
  ///
  /// [textElement] The text element to draw.
  /// [offsetX] The x offset.
  /// [offsetY] The y offset.
  /// [rotation] The rotation angle in radians.
  @override
  void drawText(
    common.TextElement textElement,
    int offsetX,
    int offsetY, {
    double rotation = 0.0,
  }) {
    // Must be Flutter TextElement.
    assert(textElement is TextElement);

    final flutterTextElement = textElement as TextElement;
    final textDirection = flutterTextElement.textDirection;
    final measurement = flutterTextElement.measurement;

    if (rotation != 0) {
      // TODO: Remove once textAnchor works.
      if (textDirection == common.TextDirection.rtl) {
        offsetY += measurement.horizontalSliceWidth.toInt();
      }

      offsetX -= flutterTextElement.verticalFontShift;

      canvas
        ..save()
        ..translate(offsetX.toDouble(), offsetY.toDouble())
        ..rotate(rotation);

      textElement.textPainter!.paint(canvas, Offset.zero);

      canvas.restore();
    } else {
      // TODO: Remove once textAnchor works.
      if (textDirection == common.TextDirection.rtl) {
        offsetX -= measurement.horizontalSliceWidth.toInt();
      }

      // Account for missing center alignment.
      if (textDirection == common.TextDirection.center) {
        offsetX -= (measurement.horizontalSliceWidth / 2).ceil();
      }

      offsetY -= flutterTextElement.verticalFontShift;

      textElement.textPainter!
          .paint(canvas, Offset(offsetX.toDouble(), offsetY.toDouble()));
    }
  }

  @override
  void setClipBounds(Rectangle<int> clipBounds) {
    canvas
      ..save()
      ..clipRect(_getRect(clipBounds));
  }

  @override
  void resetClipBounds() {
    canvas.restore();
  }

  /// Convert dart:math [Rectangle] to Flutter [Rect].
  Rect _getRect(Rectangle<num> rectangle) => Rect.fromLTWH(
        rectangle.left.toDouble(),
        rectangle.top.toDouble(),
        rectangle.width.toDouble(),
        rectangle.height.toDouble(),
      );

  /// Convert dart:math [Rectangle] and to Flutter [RRect].
  RRect _getRRect(
    Rectangle<num> rectangle, {
    double radius = 0,
    bool roundTopLeft = false,
    bool roundTopRight = false,
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  }) {
    final cornerRadius = radius == 0 ? Radius.zero : Radius.circular(radius);

    return RRect.fromLTRBAndCorners(
      rectangle.left.toDouble(),
      rectangle.top.toDouble(),
      rectangle.right.toDouble(),
      rectangle.bottom.toDouble(),
      topLeft: roundTopLeft ? cornerRadius : Radius.zero,
      topRight: roundTopRight ? cornerRadius : Radius.zero,
      bottomLeft: roundBottomLeft ? cornerRadius : Radius.zero,
      bottomRight: roundBottomRight ? cornerRadius : Radius.zero,
    );
  }

  /// Draws a forward hatch pattern in the given bounds.
  void _drawForwardHatchPattern(
    Rectangle<num> bounds,
    Canvas canvas, {
    common.Color? background,
    common.Color? fill,
    double fillWidthPx = 4.0,
    Rectangle<num>? drawAreaBounds,
  }) {
    background ??= common.StyleFactory.style.white;
    fill ??= common.StyleFactory.style.black;

    // Fill in the shape with a solid background color.
    _paint
      ..color = Color.fromARGB(
        background.a,
        background.r,
        background.g,
        background.b,
      )
      ..style = PaintingStyle.fill;

    // Apply a gradient the background if bounds exceed the draw area.
    if (drawAreaBounds != null && bounds.top < drawAreaBounds.top) {
      _paint.shader = _createHintGradient(
        drawAreaBounds.left.toDouble(),
        drawAreaBounds.top.toDouble(),
        background,
      );
    }

    canvas.drawRect(_getRect(bounds), _paint);

    // As a simplification, we will treat the bounds as a large square and fill
    // it up with lines from the bottom-left corner to the top-right corner.
    // Get the longer side of the bounds here for the size of this square.
    final size = max(bounds.width, bounds.height);

    final x0 = bounds.left + size + fillWidthPx;
    final x1 = bounds.left - fillWidthPx;
    final y0 = bounds.bottom - size - fillWidthPx;
    final y1 = bounds.bottom + fillWidthPx;
    const offset = 8;

    final isVertical = bounds.height >= bounds.width;

    // The "first" line segment will be drawn from the bottom left corner of the
    // bounds, up and towards the right. Start the loop N iterations "back" to
    // draw partial line segments beneath (or to the left) of this segment,
    // where N is the number of offsets that fit inside the smaller dimension of
    // the bounds.
    final smallSide = isVertical ? bounds.width : bounds.height;
    final start = -(smallSide / offset).round() * offset;

    // Keep going until we reach the top or right of the bounds, depending on
    // whether the rectangle is oriented vertically or horizontally.
    final end = size + offset;

    // Create gradient for line painter if top bounds exceeded.
    ui.Shader? lineShader;
    if (drawAreaBounds != null && bounds.top < drawAreaBounds.top) {
      lineShader = _createHintGradient(
        drawAreaBounds.left.toDouble(),
        drawAreaBounds.top.toDouble(),
        fill,
      );
    }

    for (var i = start; i < end; i = i + offset) {
      // For vertical bounds, we need to draw lines from top to bottom. For
      // bounds, we need to draw lines from left to right.
      final modifier = isVertical ? -1 * i : i;

      // Draw a line segment in the bottom right corner of the pattern.
      LinePainter.draw(
        canvas: canvas,
        paint: _paint,
        points: [
          Point(x0 + modifier, y0),
          Point(x1 + modifier, y1),
        ],
        stroke: fill,
        strokeWidthPx: fillWidthPx,
        shader: lineShader,
      );
    }
  }

  @override
  set drawingView(String? viewName) {}
}
