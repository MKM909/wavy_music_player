import 'package:flutter/material.dart';
import 'dart:math' as math;

// Custom painter for the wavy nav bar background - matching the design
class WavyNavPainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0 for position
  final int itemCount;
  final Color color;

  WavyNavPainter({
    required this.animationValue,
    required this.itemCount,
    required this.color,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw the irregular wavy top edge to match the design
    // The design shows organic, flowing waves with varying peaks

    // First section - gentle rise
    path.lineTo(0, size.height * 0.25);

    path.cubicTo(
      size.width * 0.06, size.height * 0.001,
      size.width * 0.12, size.height * 0.02,
      size.width * 0.18, size.height * 0.3,
    );


    // First peak (high)
    path.cubicTo(
      size.width * 0.25, size.height * 0.17,
      size.width * 0.27, size.height * 0.10,
      size.width * 0.32, size.height * 0.12,
    );

    // Dip down
    path.cubicTo(
      size.width * 0.37, size.height * 0.14,
      size.width * 0.40, size.height * 0.35,
      size.width * 0.45, size.height * 0.40,
    );

    // Second peak (medium-high)
    path.cubicTo(
      size.width * 0.50, size.height * 0.45,
      size.width * 0.53, size.height * 0.18,
      size.width * 0.58, size.height * 0.15,
    );

    // Another valley
    path.cubicTo(
      size.width * 0.63, size.height * 0.12,
      size.width * 0.66, size.height * 0.30,
      size.width * 0.70, size.height * 0.38,
    );

    // Third peak (lower)
    path.cubicTo(
      size.width * 0.74, size.height * 0.46,
      size.width * 0.77, size.height * 0.25,
      size.width * 0.82, size.height * 0.28,
    );

    // Final gentle descent
    path.cubicTo(
      size.width * 0.88, size.height * 0.32,
      size.width * 0.93, size.height * 0.50,
      size.width, size.height * 0.60,
    );

    // Complete the shape
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }


  @override
  bool shouldRepaint(WavyNavPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}