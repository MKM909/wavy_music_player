import 'package:flutter/material.dart';
import 'dart:ui';

class OffsetSquircleBackgroundPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;

  OffsetSquircleBackgroundPainter({
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // ---------- Fill circle ----------
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, fillPaint);

    // ---------- Squircle outline ----------
    final outlinePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final path = Path();

    final double r = radius - 1;
    final double c = r * 0.55; // controls squircle softness

    // Slight offset
    final dx = 2.5;
    final dy = -0.5;

    path.moveTo(center.dx + dx, center.dy - r + dy);

    path.cubicTo(
      center.dx + c + dx,
      center.dy - r + dy,
      center.dx + r + dx,
      center.dy - c + dy,
      center.dx + r + dx,
      center.dy + dy,
    );

    path.cubicTo(
      center.dx + r + dx,
      center.dy + c + dy,
      center.dx + c + dx,
      center.dy + r + dy,
      center.dx + dx,
      center.dy + r + dy,
    );

    path.cubicTo(
      center.dx - c + dx,
      center.dy + r + dy,
      center.dx - r + dx,
      center.dy + c + dy,
      center.dx - r + dx,
      center.dy + dy,
    );

    path.cubicTo(
      center.dx - r + dx,
      center.dy - c + dy,
      center.dx - c + dx,
      center.dy - r + dy,
      center.dx + dx,
      center.dy - r + dy,
    );

    path.close();

    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
