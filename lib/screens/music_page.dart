import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/items_layout/playlist_item_layout.dart';

import '../clippers/squircle_clipper.dart';
import '../model/music_tabs.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {

  List<MusicTabs> musicTabs = [
    MusicTabs(title: 'All'),
    MusicTabs(title: 'Playlists',),
    MusicTabs(title: 'Liked Songs',),
    MusicTabs(title: 'Downloaded Songs',),
    MusicTabs(title: 'Albums',),
    MusicTabs(title: 'Artists',),
  ];

  List<Widget> tabs = [
    AllMusic(),
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 👇 Called when nav bar is tapped
  void _onTabBarTapped(int index) {
    setState(() {
      _currentPage = index;
    });

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
            SizedBox(height: 20,),
            _buildTabs(),
            SizedBox(height: 20,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: IndexedStack(
                  index: _currentPage,
                  children: tabs,
                ),
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Music',
          style: GoogleFonts.rubik(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: Color(0xFF342E1B),
          ),
        ),
        Spacer(),
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
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF342E1B).withValues(alpha: 0.35),
                  ),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            )
          ),
        )

      ],
    );

  }

  Widget _buildTabs(){
    return SizedBox(
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20, right: 20),
        itemCount: musicTabs.length,
        itemBuilder: (context, index){
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (){
                            _onTabBarTapped(index);
                          },
                          splashColor: Colors.brown.withValues(alpha: 0.2),
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            constraints: BoxConstraints(minWidth: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: index == _currentPage ? Color(0xFF342E1B) : Color(0xFF342E1B).withValues(alpha: 0.35),
                            ),
                            child: Center(
                              child: Text(
                                musicTabs[index].title,
                                style: GoogleFonts.rubik(
                                  fontSize: 20,
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

class AllMusic extends StatefulWidget {
  const AllMusic({super.key});

  @override
  State<AllMusic> createState() => _AllMusicState();
}

class _AllMusicState extends State<AllMusic> with AutomaticKeepAliveClientMixin<AllMusic> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 65),
        itemCount: 10,
        itemBuilder: (context, index){
          return PlaylistItemLayout();
        }
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

