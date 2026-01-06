import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubblyVoiceIndicator extends StatefulWidget {
  final bool isSpeaking;
  final Color color;
  final Widget? child;
  final double height;
  final double width;

  const BubblyVoiceIndicator({
    super.key,
    required this.isSpeaking,
    this.color = const Color(0xFFFF00CC),
    this.child,
    required this.height,
    required this.width,
  });

  @override
  State<BubblyVoiceIndicator> createState() => _BubblyVoiceIndicatorState();
}

class _BubblyVoiceIndicatorState extends State<BubblyVoiceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>  scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slower for a "liquid" feel
    )..repeat();

    scale = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: widget.isSpeaking ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutBack,
      builder: (context, morphValue, _) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The "Formless" Outer Border (Grey Aura)
                  Positioned.fill(
                    child: AnimatedScale(
                      scale: scale.value,
                      duration: Duration(milliseconds: 1200),
                      child: CustomPaint(
                        painter: LiquidPainter(
                          morphValue: morphValue,
                          animValue: _controller.value,
                          color: Colors.grey.withOpacity(0.3),
                          isOuter: true,
                        ),
                      ),
                    ),
                  ),
                  // The Main Bubbly/Spiky Body
                  Positioned.fill(
                    child: AnimatedScale(
                      scale: scale.value,
                      duration: Duration(milliseconds: 1200),
                      child: CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: LiquidPainter(
                          morphValue: morphValue,
                          animValue: _controller.value,
                          color: widget.color,
                          isOuter: false,
                        ),
                      ),
                    ),
                  ),
                  if (widget.child != null) widget.child!,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double morphValue;
  final double animValue;
  final Color color;
  final bool isOuter;

  LiquidPainter({
    required this.morphValue,
    required this.animValue,
    required this.color,
    required this.isOuter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = isOuter ? size.width * 0.58 : size.width * 0.55;

    final paint = Paint()
      ..color = color
      ..style = isOuter ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = isOuter ? 2.0 : 0;

    if (!isOuter) {
      paint.shader = RadialGradient(
        colors: [color.withOpacity(0.7), color],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.5));
    }

    final path = Path();
    const int totalPoints = 30; // High density for bubbly spikes
    final points = <Offset>[];

    for (int i = 0; i <= totalPoints; i++) {
      double angle = (i * 2 * math.pi) / totalPoints;

      // Organic Noise Logic:
      // We mix multiple frequencies to avoid "hardcoded" patterns.
      double time = animValue * 2 * math.pi;

      // Wave A: Slow deep swells
      double waveA = math.sin(angle * 2 + time);
      // Wave B: Faster "bubbly" spikes
      double waveB = math.cos(angle * 5 - time * 2);
      // Wave C: High frequency jitter
      //double waveC = math.sin(angle * 15 + time * 3);

      double noise = (waveA * 0.15) + (waveB * 0.075) + (waveB * 0.05);

      // Outer border moves slightly differently to feel "detached"
      double intensity = isOuter ? 25.0 : 18.0;
      double currentRadius = baseRadius + (noise * intensity * morphValue);

      double x = center.dx + currentRadius * math.cos(angle);
      double y = center.dy + currentRadius * math.sin(angle);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      // Cubic Bezier for much smoother, liquid-like bubbles
      final controlPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, controlPoint.dx, controlPoint.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) => true;
}