import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/music_controller.dart';
import '../model/nav_item.dart';
import '../painters/music_nav_indicator.dart';
import 'inactive_nav_icon.dart';

class NavButton extends StatefulWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
        builder: (context, controller, child) {
        return GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.translucent,
          child: Container( // Removed AnimatedContainer to let Switcher handle it
            width: 70,
            height: 70,
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 300),
              // Use a gentle elastic or cubic curve for that "soothing" feel
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                // This creates a subtle scale and fade effect during the switch
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: widget.isActive
                  ? BubblyVoiceIndicator(
                key: ValueKey('active_${widget.item.label}'), // Unique keys are vital for Switcher
                isSpeaking: controller.isPlaying,
                width: 60, // Slightly larger for better visual hierarchy
                height: 60, // Slightly larger for better visual hierarchy
                color: const Color(0xFFFFE695),
                child: Icon(
                  widget.item.icon,
                  color: const Color(0xFF342E1B),
                  size: 26,
                ),
              )
                  : InactiveNavIcon(
                key: ValueKey('inactive_${widget.item.label}'),
                icon: widget.item.icon,
              ),
            ),
          ),
        );
      }
    );
  }
}