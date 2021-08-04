import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  Future<BitmapDescriptor> getMarkerIcon(
      {String imagePath,
      Size size,
      Color markerBackgroundColor = Colors.white,
      Color shadowColor = Colors.grey,
      Color tagColor = Colors.blue,
      String tagValue,
      TextStyle tagTextStyle,
      double childPadding,
      double deviceSize,
      double leftPadding = 0.0,
      double rightPadding = 0.0,
      double shadowWidth = 10.0,
      double triangleHeight}) async {
    if (triangleHeight == null) {
      triangleHeight = size.height;
    }

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint normalPaint = Paint()..color = markerBackgroundColor;
    childPadding = childPadding ?? size.width / 3;

    final double distanceBetweenCenterLeftRight = 2 * childPadding;

    /// Calculate Center value
    Offset centerLeft = Offset(size.width / 2, size.height / 2);
    Offset centerRight =
        Offset(centerLeft.dx + distanceBetweenCenterLeftRight, size.height / 2);
    Offset centerMain = Offset(size.width / 2 + childPadding, size.height / 2);

    /// DRAW LEFT MARKER
    /// Init triangle & circle path
    Path trianglePath1 = new Path();
    Path circlePath1 = Path();

    /// Init triangle
    trianglePath1.moveTo(leftPadding + shadowWidth, centerLeft.dy);
    trianglePath1.lineTo(size.width - rightPadding, centerLeft.dy);

    trianglePath1.lineTo(centerLeft.dx + shadowWidth / 2,
        centerLeft.dy + triangleHeight - shadowWidth);

    /// Init Circle
    circlePath1.addOval(Rect.fromLTWH(0.0 + shadowWidth, 0.0 + shadowWidth,
        size.width - shadowWidth, size.height - shadowWidth));

    /// Draw Circle/Triangle Shadow
    canvas.drawShadow(trianglePath1, shadowColor, shadowWidth, true);

    canvas.drawShadow(circlePath1, shadowColor, shadowWidth / 2, true);

    /// Draw Circle
    canvas.drawPath(circlePath1, normalPaint);

    /// Draw triangle
    canvas.drawPath(trianglePath1, normalPaint);

    /// DRAW RIGHT MARKER
    /// Init triangle & circle path
    Path trianglePath2 = new Path();
    Path circlePath2 = Path();

    /// Init triangle
    trianglePath2.moveTo(
        centerRight.dx - (size.width / 2 - leftPadding - shadowWidth),
        centerRight.dy);
    trianglePath2.lineTo(
        centerRight.dx + (size.width / 2 - rightPadding), centerRight.dy);

    trianglePath2.lineTo(centerRight.dx + shadowWidth / 2,
        centerRight.dy + triangleHeight - shadowWidth);

    /// Init Circle
    circlePath2.addOval(Rect.fromLTWH(
        centerRight.dx - (size.width / 2) + shadowWidth,
        shadowWidth,
        size.width - shadowWidth,
        size.height - shadowWidth));

    /// Draw Circle/Triangle Shadow
    canvas.drawShadow(trianglePath2, shadowColor, shadowWidth, true);

    canvas.drawShadow(circlePath2, shadowColor, shadowWidth / 2, true);

    /// Draw Circle
    canvas.drawPath(circlePath2, normalPaint);

    /// Draw triangle
    canvas.drawPath(trianglePath2, normalPaint);

    /// DRAW MAIN MARKER FONT OF ALL MARKER
    /// Init triangle & circle path
    Path trianglePath3 = new Path();
    Path circlePath3 = Path();

    /// Init triangle
    trianglePath3.moveTo(
        centerMain.dx - (size.width / 2 - leftPadding - shadowWidth),
        centerMain.dy);
    trianglePath3.lineTo(
        centerMain.dx + (size.width / 2 - rightPadding), centerMain.dy);

    trianglePath3.lineTo(centerMain.dx + shadowWidth / 2,
        centerMain.dy + triangleHeight - shadowWidth);

    /// Init Circle
    circlePath3.addOval(Rect.fromLTWH(
        centerMain.dx - (size.width / 2) + shadowWidth,
        shadowWidth,
        size.width - shadowWidth,
        size.height - shadowWidth));

    /// Draw Circle/Triangle Shadow
    canvas.drawShadow(trianglePath3, shadowColor, shadowWidth, true);

    canvas.drawShadow(circlePath3, shadowColor, shadowWidth / 2, true);

    /// Draw Circle
    canvas.drawPath(circlePath3, normalPaint);

    /// Draw triangle
    canvas.drawPath(trianglePath3, normalPaint);

    /// Draw text
    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.text = TextSpan(
      text: '$tagValue',
      style: tagTextStyle ??
          TextStyle(
            fontSize: 40.0,
            color: tagColor,
          ),
    );

    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    textPainter.layout(minWidth: 0, maxWidth: textPainter.width);

    Offset drawPosition = Offset(
        centerMain.dx - (textPainter.width / 2) + (shadowWidth / 2),
        centerMain.dy - shadowWidth);

    textPainter.paint(canvas, drawPosition);

    /// Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt() +
            deviceSize.toInt() +
            (size.width ~/ 4) +
            (childPadding * 2).toInt(),
        size.height.toInt() + triangleHeight.toInt() + deviceSize.toInt());

    /// Convert image to bytes
    final ByteData byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }
}
