import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wavy_muic_player/painters/music_nav_indicator.dart';

import '../model/nav_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple.shade100,
      child: Center(
        child: Icon(
          Icons.home_rounded,
          color: Colors.white,
          size: 100,
        ),
      ),
    );;
  }

}








