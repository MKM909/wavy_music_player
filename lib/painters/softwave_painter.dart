import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedWave extends StatefulWidget {
  final Size size;
  final Color color;

  final int sec;

  const AnimatedWave({
    super.key,
    required this.size,
    required this.color,
    required this.sec,
  });

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double elapsed = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration d) {
      setState(() {
        elapsed = d.inMilliseconds / (widget.sec * 1000); // seconds
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: SoftWavePainter(
        color: widget.color,
        time: elapsed,
      ),
    );
  }
}


class SoftWavePainter extends CustomPainter {
  final Color color;
  final double time; // 0 → 1

  SoftWavePainter({
    required this.color,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    final baseY = size.height * 0.45;
    final speed = time * 0.5 * math.pi;

    // Start bottom-left
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);

    // Sample wave horizontally
    for (double x = 0; x <= size.width; x += 4) {
      final nx = x / size.width;

      // --- Layered sine waves (organic feel) ---
      final wave1 = math.sin((nx * 2 * math.pi) + speed) * 24;
      final wave2 = math.sin((nx * 4 * math.pi) + speed * 1.6) * 14;
      final wave3 = math.sin((nx * 7 * math.pi) - speed * 0.8) * 6;

      final y = baseY + wave1 + wave2 + wave3;

      path.lineTo(x, y);
    }

    // Close shape
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SoftWavePainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

