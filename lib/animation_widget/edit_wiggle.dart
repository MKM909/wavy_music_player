import 'package:flutter/material.dart';

class EditWiggle extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const EditWiggle({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  State<EditWiggle> createState() => _EditWiggleState();
}

class _EditWiggleState extends State<EditWiggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _rotation = Tween<double>(
      begin: -0.025,
      end: 0.025,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EditWiggle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (_, child) {
        return Transform.rotate(
          angle: widget.enabled ? _rotation.value : 0,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
