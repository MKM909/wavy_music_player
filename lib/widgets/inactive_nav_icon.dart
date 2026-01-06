import 'package:flutter/material.dart';

class InactiveNavIcon extends StatelessWidget {
  final IconData icon;

  const InactiveNavIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Lower opacity for inactive state to make the active one pop
        color: const Color(0xFFFFE695).withOpacity(0.15),
      ),
      child: Icon(
        icon,
        color: const Color(0xFFFFE695).withOpacity(0.7),
        size: 24,
      ),
    );
  }
}