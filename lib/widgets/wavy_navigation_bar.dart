import 'package:flutter/material.dart';
import 'package:wavy_muic_player/painters/mio_background_painter.dart';
import '../painters/wavy_nav_painter.dart';

class WavyMusicNavBar extends StatefulWidget {
  final List<IconData> icons;
  final Function(int) onTap;
  final Color backgroundColor;
  final Color navColor;
  final Color iconColor;
  final Color selectedIconColor;

  const WavyMusicNavBar({
    super.key,
    required this.icons,
    required this.onTap,
    this.backgroundColor = const Color(0xFFFFE695),
    this.navColor = const Color(0xFF342E1B),
    this.iconColor = const Color(0xFF342E1B),
    this.selectedIconColor = const Color(0xFFFFE695),
  });

  @override
  State<WavyMusicNavBar> createState() => _WavyMusicNavBarState();
}

class _WavyMusicNavBarState extends State<WavyMusicNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _currentIndex = 0;
  int _previousIndex = 0;
  int _displayedIconIndex = 0;
  bool _iconSwapped = false;

  double get t =>
      _controller.isAnimating ? _controller.value : 1.0; // ⭐ key line

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
      if (t >= 0.5 && !_iconSwapped) {
        _displayedIconIndex = _currentIndex;
        _iconSwapped = true;
      }
      setState(() {}); // ⭐ forces repaint safely
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    _previousIndex = _currentIndex;
    _currentIndex = index;
    _iconSwapped = false;

    _controller.forward(from: 0);
    widget.onTap(index);
  }

  double _position(double width) {
    final count = widget.icons.length;
    final spacing = width / (count * 2);
    final step = width / count;

    final from = spacing + step * _previousIndex;
    final to = spacing + step * _currentIndex;

    return (from + (to - from) * t) / width;
  }

  double _bubbleScale() {
    if (t < 0.8) return 1.0;
    if (t < 0.9) {
      return 1.0 - 0.15 * Curves.easeOut.transform((t - 0.8) / 0.1);
    }
    return 0.85 +
        0.25 * Curves.elasticOut.transform((t - 0.9) / 0.1);
  }

  double _iconScale() => 1.0 - (t - 0.5).abs() * 0.3;
  double _iconOpacity() => t < 0.5 ? 1 - t * 2 : (t - 0.5) * 2;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final pos = _position(width);

    return Container(
      height: 140,
      color: widget.backgroundColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: MIOBackgroundPainter(widget.navColor),
            ),
          ),

          Positioned(
            top: 22,
            left: 0,
            right: 0,
            height: 30,
            child: CustomPaint(
              painter: MIORollingPainter(
                position: pos,
                color: widget.selectedIconColor,
              ),
            ),
          ),

          Positioned(
            left: pos * width - 22,
            top: 47,
            child: Opacity(
              opacity: 1,
              child: Transform.scale(
                scale: 1,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: widget.navColor,
                    shape: BoxShape.circle,
                  ),
                  child: Transform.scale(
                    scale: 1,
                    child: Icon(
                      widget.icons[_displayedIconIndex],
                      color: widget.selectedIconColor,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.icons.length, (i) {
                final active = i == _currentIndex;
                return GestureDetector(
                  onTap: () => _onItemTapped(i),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1,
                    child: Transform.translate(
                      offset: Offset(0, active ? -6 : 0),
                      child: Transform.scale(
                        scale: 1,
                        child: Icon(
                          widget.icons[i],
                          color: widget.iconColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
