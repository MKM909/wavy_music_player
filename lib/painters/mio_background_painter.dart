import 'package:flutter/material.dart';

// Custom painter for the organic wavy background
// Custom painter for the organic wavy background
// Custom painter for the organic wavy background
class MIOBackgroundPainter extends CustomPainter {
  final Color color;
  MIOBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.3); // Starting height on the left edge

    // Organic wavy top edge
    path.cubicTo(
      size.width * 0.15, size.height * 0.05, // High peak left
      size.width * 0.35, size.height * 0.45, // Deep valley
      size.width * 0.50, size.height * 0.35, // Middle rise
    );
    path.cubicTo(
      size.width * 0.70, size.height * 0.20, // Higher peak right
      size.width * 0.85, size.height * 0.55, // Low dip before end
      size.width, size.height * 0.30,        // End point on right edge
    );

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


class MIORollingPainter extends CustomPainter {
  final double position; // 0.0 → 1.0
  final Color color;

  MIORollingPainter({
    required this.position,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final x = position * size.width;

    final double baseY = size.height * 0.28;

    const double radius = 50.0;
    const double shoulder = 70.0; // 👈 WIDER shoulders
    const double depth = 2;     // 👈 slightly deeper bulb

    final path = Path();

    // Start left, flat on the wave
    path.moveTo(x - radius - shoulder, baseY);

    // LEFT SHOULDER — stays horizontal longer
    path.cubicTo(
      x - radius - shoulder * 0.2, baseY,
      x - radius - shoulder * 0.1, baseY + radius * 0.15,
      x - radius, baseY + radius * 0.55,
    );

    // BULB — smooth, continuous drop
    path.cubicTo(
      x - radius, baseY + radius * depth,
      x + radius, baseY + radius * depth,
      x + radius, baseY + radius * 0.55,
    );

    // RIGHT SHOULDER — symmetric exit
    path.cubicTo(
      x + radius + shoulder * 0.1, baseY + radius * 0.15,
      x + radius + shoulder * 0.2, baseY,
      x + radius + shoulder, baseY,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MIORollingPainter oldDelegate) =>
      oldDelegate.position != position;
}
