import 'package:flutter/material.dart';

class RollingIndicatorPainter extends CustomPainter {
  final double position; // 0.0 to 1.0
  final Color color;
  final Color bgColor;

  RollingIndicatorPainter({
    required this.position,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorX = position * size.width;
    const double radius = 28.0;
    const double bgPadding = 4.0;

    // Draw the background teardrop (slightly larger)
    _drawTeardrop(canvas, Offset(indicatorX, 0), radius + bgPadding, bgColor);

    // Draw the foreground teardrop
    _drawTeardrop(canvas, Offset(indicatorX, 0), radius, color);
  }

  void _drawTeardrop(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();

    final double height = radius * 1.55;
    final double shoulderY = center.dy + radius * 0.35;
    final double controlX = radius * 1.15;
    final double controlY = radius * 1.25;

    // Bottom point
    path.moveTo(center.dx, center.dy + height);

    // Right side (soft shoulder)
    path.cubicTo(
      center.dx + controlX, center.dy + height, // pull outward
      center.dx + radius, center.dy + controlY,
      center.dx + radius, shoulderY,
    );

    // Top curve (smooth cap)
    path.arcToPoint(
      Offset(center.dx - radius, shoulderY),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Left side (mirror)
    path.cubicTo(
      center.dx - radius, center.dy + controlY,
      center.dx - controlX, center.dy + height,
      center.dx, center.dy + height,
    );

    path.close();
    canvas.drawPath(path, paint);
  }


  @override
  bool shouldRepaint(RollingIndicatorPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.bgColor != bgColor;
  }
}