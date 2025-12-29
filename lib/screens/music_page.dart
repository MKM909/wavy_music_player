import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/bottom_sheets/playlist_creation_sheet.dart';
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

  List<MusicTabs> musicTabs = [
    MusicTabs(title: 'Downloaded Songs',),
    MusicTabs(title: 'Playlists',),
    MusicTabs(title: 'Liked Songs',),
    MusicTabs(title: 'Albums',),
    MusicTabs(title: 'Artists',),
  ];

  List<Widget> tabs = [
    DownloadedSongs(),
    Playlists(),
    LikedSongsScreen(),
    Container(),
    Container(),
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
    });
    double offset = index * 40;

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
    return Scaffold(
      backgroundColor: const Color(0xFFFFE695),
      body: Padding(
          padding: const EdgeInsets.only(top: 40,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: _buildheader(),
              ),
              SizedBox(height: 10,),
              _buildTabs(),
              SizedBox(height: 10,),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: tabs,
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget _buildheader(){

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
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: Color(0xFF342E1B),
          ),
        ),
        Spacer(),
        _currentPage == 1
          ? ClipRRect(
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
                      height: 40,
                      width: 40,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF342E1B).withValues(alpha: 0.35),
                      ),
                      child: Icon(
                        CupertinoIcons.add_circled,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )
            ),
          )
          : Container(),
        SizedBox(width: 10,),

        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (){},
                  splashColor: Colors.brown.withValues(alpha: 0.2),
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF342E1B).withValues(alpha: 0.35),
                    ),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
          ),
        ),

      ],
    );

  }

  Widget _buildTabs(){
    return SizedBox(
      height: 40,
      child: ListView.builder(
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
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
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
                                color: index == _currentPage ? Color(0xFF342E1B) : Color(0xFF342E1B).withValues(alpha: 0.35),
                              ),
                              child: Center(
                                child: Text(
                                  musicTabs[index].title,
                                  style: GoogleFonts.rubik(
                                    fontSize: 18,
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
              ],
            );
          }
      ),
    );
  }
}

