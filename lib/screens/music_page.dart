import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/bottom_sheets/playlist_creation_sheet.dart';
import 'package:wavy_muic_player/screens/music/albums.dart';
import 'package:wavy_muic_player/screens/music/artists.dart';
import 'package:wavy_muic_player/screens/music/playlists.dart';

import '../model/music_tabs.dart';
import 'music/downloaded_songs.dart';
import 'music/liked_songs.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {

  bool edit = false;

  List<MusicTabs> musicTabs = [
    MusicTabs(title: 'Downloaded Songs',),
    MusicTabs(title: 'Playlists',),
    MusicTabs(title: 'Liked Songs',),
    MusicTabs(title: 'Albums',),
    MusicTabs(title: 'Artists',),
  ];

  int _currentPage = 0;
  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _pageController.dispose();
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
      edit = false;
    });
    double offset = index * 80;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    late List<Widget> tabs = [
      DownloadedSongs(),
      Playlists(edit: edit,),
      LikedSongsScreen(),
      Albums(),
      Artists(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFE695),
      body: Padding(
          padding: const EdgeInsets.only(top: 40,),
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: tabs,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFE695),
                        const Color(0xFFFFE695).withValues(alpha: 0.9),
                        const Color(0xFFFFE695).withValues(alpha: 0.7),
                        const Color(0xFFFFE695).withValues(alpha: 0.3),
                        const Color(0xFFFFE695).withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: _buildHeader(),
                      ),
                      SizedBox(height: 10,),
                      _buildTabs(),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget _buildHeader(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.library_music_sharp,
          size: 35,
          color: Color(0xFF342E1B),
        ),
        SizedBox(width: 10,),
        Text(
          'Library',
          style: GoogleFonts.rubik(
            fontSize: 45,
            fontWeight: FontWeight.w600,
            color: Color(0xFF342E1B),
          ),
        ),
        Spacer(),
        _fadeAction(
          visible: _currentPage == 1,
          child: ClipRRect(
            key: const ValueKey('edit'),
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => edit = !edit);
                  },
                  splashColor: Colors.brown.withValues(alpha: 0.2),
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF342E1B).withValues(alpha: 0.35),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 10,),

        _fadeAction(
            visible: _currentPage == 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (){ PlaylistCreationSheet.show(context); },
                      splashColor: Colors.brown.withValues(alpha: 0.2),
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      child: Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF342E1B).withValues(alpha: 0.35),
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  )
              ),
            )
        ),

      ],
    );

  }

  Widget _fadeAction({
    required bool visible,
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (widget, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(animation),
            child: widget,
          ),
        );
      },
      child: visible
          ? child
          : const SizedBox(
        key: ValueKey('empty'),
        width: 50,
        height: 50,
      ),
    );
  }


  Widget _buildTabs(){
    return SizedBox(
      height: 50,
      child: ListView.builder(
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          controller: _scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 20, right: 10),
          itemCount: musicTabs.length,
          itemBuilder: (context, index){
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.clamp),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30, tileMode: TileMode.clamp),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: (){
                                  _onNavBarTapped(index);
                                },
                                splashColor: Colors.brown.withValues(alpha: 0.2),
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                  constraints: BoxConstraints(minWidth: 60),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: index == _currentPage ? Color(0xFF342E1B).withValues(alpha: 0.75) : Color(0xFF342E1B).withValues(alpha: 0.25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      musicTabs[index].title,
                                      style: GoogleFonts.rubik(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: index == _currentPage ? Colors.white : Color(0xFF342E1B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}

