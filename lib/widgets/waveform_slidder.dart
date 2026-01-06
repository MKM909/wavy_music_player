import 'dart:math';
import 'package:flutter/material.dart';

class WaveformSlider extends StatefulWidget {
  final double progress; // 0.0 → 1.0
  final ValueChanged<double> onChanged;
  final double height;
  final Color? fillColor;
  final Color? thumbColor;
  final Color? inactiveColor;
  final int barCount;
  final int thumbRadius;


  const WaveformSlider({
    super.key,
    required this.progress,
    required this.onChanged,
    this.height = 44,
    required this.fillColor,
    this.thumbColor,
    this.inactiveColor,
    this.barCount  = 32,
    this.thumbRadius = 10,
  });

  @override
  State<WaveformSlider> createState() => _WaveformSliderState();
}

class _WaveformSliderState extends State<WaveformSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animProgress;
  double _dragProgress = 0;

  @override
  void initState() {
    super.initState();
    _dragProgress = widget.progress;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void didUpdateWidget(covariant WaveformSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    _animProgress = Tween<double>(
      begin: _dragProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller
      ..reset()
      ..forward();

    _dragProgress = widget.progress;
  }

  void _updateProgress(Offset local, double width) {
    final p = (local.dx / width).clamp(0.0, 1.0);
    setState(() => _dragProgress = p);
    widget.onChanged(p);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanDown: (d) => _updateProgress(d.localPosition, constraints.maxWidth),
          onPanUpdate: (d) => _updateProgress(d.localPosition, constraints.maxWidth),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                size: Size(constraints.maxWidth, widget.height),
                painter: WaveformPainter(
                  barCount: widget.barCount,
                  fillColor: widget.fillColor,
                  thumbColor: widget.thumbColor,
                  inactiveColor: widget.inactiveColor,
                  thumbRadius: widget.thumbRadius,
                  progress: _controller.isAnimating
                      ? _animProgress.value
                      : _dragProgress,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color? fillColor;
  final Color? thumbColor;
  final Color? inactiveColor;
  final int barCount;
  final int thumbRadius;

  late final List<double> _heights;

  WaveformPainter({
    required this.progress,
    this.fillColor,
    this.thumbColor,
    this.inactiveColor,
    this.thumbRadius = 10,
    required this.barCount,
  }) {
    _heights = _generateHeights(barCount);
  }

  // 🔹 Random but stable waveform
  List<double> _generateHeights(int count) {
    final random = Random(42); // change seed for different shapes
    return List.generate(
      count,
          (_) => random.nextDouble() * 0.6 + 0.25, // clamp range
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / barCount;
    final progressX = size.width * progress;

    final inactivePaint = Paint()
      ..color = inactiveColor ?? Colors.white.withOpacity(0.25)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = fillColor ?? const Color(0xFFFDE68A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < barCount; i++) {
      final x = spacing * i + spacing / 2;
      final barHeight = size.height * _heights[i];
      final top = (size.height - barHeight) / 2;
      final bottom = top + barHeight;

      if (x <= progressX) {
        canvas.drawLine(Offset(x, top), Offset(x, bottom), glowPaint);
        canvas.drawLine(Offset(x, top), Offset(x, bottom), activePaint);
      } else {
        canvas.drawLine(Offset(x, top), Offset(x, bottom), inactivePaint);
      }
    }

    // Thumb
    canvas.drawCircle(
      Offset(progressX, size.height / 2),
      thumbRadius.toDouble(),
      Paint()..color = thumbColor ?? const Color(0xFFFDE68A),
    );
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
