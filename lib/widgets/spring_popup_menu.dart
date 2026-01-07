import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

OverlayEntry? _activeSpringMenu; // ✅ single instance

Future<void> showSpringPopupMenu({
  required BuildContext context,
  required Offset position,
  required List<SpringMenuItem> items,
}) async {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;

  // ✅ Remove existing menu if present
  _activeSpringMenu?.remove();
  _activeSpringMenu = null;

  final bool showAbove = position.dy > screenSize.height * 0.6;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _SpringPopupOverlay(
      position: position,
      screenSize: screenSize,
      showAbove: showAbove,
      onDismiss: () {
        entry.remove();
        _activeSpringMenu = null;
      },
      items: items.map((item) {
        return item.copyWithDismiss(() {
          entry.remove();
          _activeSpringMenu = null;
        });
      }).toList(),
    ),
  );

  _activeSpringMenu = entry;
  overlay.insert(entry);
}


class _SpringPopupOverlay extends StatefulWidget {
  final Offset position;
  final Size screenSize;
  final bool showAbove;
  final VoidCallback onDismiss;
  final List<Widget> items;

  const _SpringPopupOverlay({
    required this.position,
    required this.screenSize,
    required this.showAbove,
    required this.onDismiss,
    required this.items,
  });

  @override
  State<_SpringPopupOverlay> createState() => _SpringPopupOverlayState();
}

class _SpringPopupOverlayState extends State<_SpringPopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  static const double _menuWidth = 220;
  static const double _itemHeight = 56;
  static const double _screenPadding = 12;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuHeight = widget.items.length * _itemHeight + 20;

    // ✅ CLAMP X
    double left = widget.position.dx - _menuWidth + 20;
    left = left.clamp(
      _screenPadding,
      widget.screenSize.width - _menuWidth - _screenPadding,
    );

    // ✅ CLAMP Y
    double top = widget.showAbove
        ? widget.position.dy - menuHeight - 16
        : widget.position.dy + 12;

    top = top.clamp(
      _screenPadding,
      widget.screenSize.height - menuHeight - _screenPadding,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),

        Positioned(
          left: left,
          top: top,
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              alignment:
              widget.showAbove ? Alignment.bottomRight : Alignment.topRight,
              child: Material(
                type: MaterialType.transparency,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: _menuWidth,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF342E1B).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.items,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SpringMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? _dismiss;

  const SpringMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    VoidCallback? dismiss,
  }) : _dismiss = dismiss;

  SpringMenuItem copyWithDismiss(VoidCallback dismiss) {
    return SpringMenuItem(
      icon: icon,
      label: label,
      onTap: onTap,
      dismiss: dismiss,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _dismiss?.call();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


