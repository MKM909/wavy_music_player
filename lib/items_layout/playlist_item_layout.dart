import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/screens/music/playlist_viewing_page.dart';

import '../clippers/squircle_clipper.dart';

class PlaylistItemLayout extends StatefulWidget {

  
  const PlaylistItemLayout({super.key});

  @override
  State<PlaylistItemLayout> createState() => _PlaylistItemLayoutState();
}

class _PlaylistItemLayoutState extends State<PlaylistItemLayout> {
  bool isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistViewingPage()
        ));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipPath(
                clipper: SquircleClipper(30),
                child: Container(
                  width: 70,
                  height: 70,
                  color: Color(0xFF342E1B),
                ),
              ),

              SizedBox(width: 15,),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Playlist Title',
                    style: GoogleFonts.rubik(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: isPlaying ? Color(0xFFFBBF24) : Color(0xFF342E1B),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'By Micah',
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isPlaying ? Color(0xFFFBBF24) : Color(0xFF342E1B),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPlaying ? Color(0xFFFBBF24) : Color(0xFF342E1B),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        '8 Songs',
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isPlaying ? Color(0xFFFBBF24) : Color(0xFF342E1B).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Spacer(),

              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isPlaying = !isPlaying;
                          if (isPlaying) {

                          } else {

                          }
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF342E1B).withValues(alpha: 0.5),
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
