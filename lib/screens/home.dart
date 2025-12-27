import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wavy_muic_player/screens/home_page.dart';
import 'package:wavy_muic_player/screens/music_page.dart';
import 'package:wavy_muic_player/screens/profile_page.dart';
import 'package:wavy_muic_player/screens/search_page.dart';

import '../widgets/wavy_navigation_bar.dart';

// Demo usage matching the design
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  List<Widget> tab = [
    HomePage(),
    MusicPage(),
    SearchPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 👇 Called when nav bar is tapped
  void _onNavBarTapped(int index) {
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  // 👇 Called when user swipes PageView
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Update nav bar to match swiped page
    final CurvedNavigationBarState? navBarState =
        _bottomNavigationKey.currentState;
    navBarState?.setPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE695),
      body: Stack(
        children: [
          // 🎨 Animated page transitions with swipe enabled
          Positioned.fill(
            child: SafeArea(
              top: false,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged, // 👈 Syncs nav bar when swiping
                children: tab,
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurvedNavigationBar(
              key: _bottomNavigationKey, // 👈 Key for programmatic control
              items: <Widget>[
                Icon(Icons.home_rounded, size: 30, color: Colors.white),
                Icon(Icons.music_note_rounded, size: 30, color: Colors.white),
                Icon(Icons.search_rounded, size: 30, color: Colors.white),
                Icon(Icons.person_rounded, size: 30, color: Colors.white),
              ],
              index: _currentPage,
              backgroundColor: Colors.transparent,
              height: 75,
              animationDuration: Duration(milliseconds: 800),
              color: Color(0xFF342E1B),
              onTap: _onNavBarTapped, // 👈 Animates PageView when tapped
            ),
          ),
        ],
      ),
    );
  }
}