import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bottom_sheets/music_player_sheet.dart';
import '../clippers/squircle_clipper.dart';

class MusicPlaying extends StatefulWidget {
  final AnimationController vinylController;
  const MusicPlaying({super.key, required this.vinylController});

  @override
  State<MusicPlaying> createState() => _MusicPlayingState();
}

class _MusicPlayingState extends State<MusicPlaying> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        MusicPlayerSheet.show(context);
      },
      child: Container(
        height: 70,
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFE695),Color(0xFFFBBF24),]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 5
            ),
          ],
        ),
        child: Row(
          children: [
            ClipPath(
              clipper: SquircleClipper(20),
              child: Container(
                width: 45,
                height: 45,
                color: Color(0xFF342E1B),
              ),
            ),

            SizedBox(width: 15,),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Song Title',
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF342E1B),
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  'Artist',
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF342E1B),
                  ),
                ),
              ],
            ),

            Spacer(),

            Icon(
              Icons.shuffle,
              color: const Color(0xFF342E1B).withOpacity(0.4),
              size: 28,
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  isLiked = !isLiked;
                });
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : const Color(0xFF342E1B).withOpacity(0.4),
                size: 28,
              ),
            ),

            SizedBox(width: 8),

            RotationTransition(
              turns: widget.vinylController,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.vinylController.repeat();
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF000000)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFDE68A),
                          ),
                          child: Center(
                            child: Icon(Icons.play_circle, size: 20, color: Colors.black,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
