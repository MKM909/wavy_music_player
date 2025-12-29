import 'package:flutter/material.dart';
import 'dart:math' as math;

class ContiniousWave extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color fillDouble;

  const ContiniousWave({
    super.key,
    required this.progress,
    this.fillDouble = const Color(0xFF00D2FF)
  });

  @override
  State<ContiniousWave> createState() => _WaveProgressLoaderState();
}

class _WaveProgressLoaderState extends State<ContiniousWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: WavePainter(
            animationValue: _controller.value,
            progress: widget.progress,
            color: widget.fillDouble,
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color color;

  WavePainter({
    required this.animationValue,
    required this.progress,
    required this.color
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();


    // 3. Calculate Wave Height (0.0 progress = bottom, 1.0 = top)
    double waveHeight = (1 - progress) * size.height;
    double amplitude = 10.0; // The "size" of the waves

    path.moveTo(0, waveHeight);

    // 4. Draw the Sine Wave
    for (double x = 0; x <= size.width; x++) {
      // Standard Wave Equation: y = A * sin(kx + phase)
      double y = amplitude * math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi));
      path.lineTo(x, waveHeight + y);
    }

    // 5. Close the path to fill the bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}