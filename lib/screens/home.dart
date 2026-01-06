import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/screens/home_page.dart';
import 'package:wavy_muic_player/screens/music_page.dart';
import 'package:wavy_muic_player/screens/profile_page.dart';
import 'package:wavy_muic_player/screens/search_page.dart';
import 'package:wavy_muic_player/widgets/fluid_nav_bar.dart';
import 'package:wavy_muic_player/widgets/mini_player.dart';

import '../model/nav_item.dart';

// Demo usage matching the design
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;
  bool isLiked = false;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  List<Widget> tab = [
    HomePage(),
    MusicPage(),
    SearchPage(),
    ProfilePage(),
  ];

  List<NavItem> tabIcons = const [
    NavItem(label: 'Home', icon: Icons.home_rounded),
    NavItem(label: 'Music', icon: Icons.library_music),
    NavItem(label: 'Search', icon: Icons.search),
    NavItem(label: 'Profile', icon: Icons.person_rounded),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: [
            // 🎨 Animated page transitions with swipe enabled
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: false,
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
              child: FluidNavBar(
                  key: _bottomNavigationKey,
                  tabs: tabIcons,
                  currentIndex: _currentPage,
                  onTap: _onNavBarTapped
              ),
            ),

            // Positioned(
            //   bottom: 100,
            //   left: 0,
            //   right: 0,
            //   child: MiniPlayer(),
            // )

          ],
        ),
      ),
    );
  }
}