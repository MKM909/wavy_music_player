import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../bottom_sheets/music_player_sheet.dart';
import '../clippers/squircle_clipper.dart';
import '../controllers/music_controller.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key,});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {

  bool isLiked = false;
  late final AnimationController _vinylController;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  @override
  void dispose() {
    _vinylController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
        builder: (context, controller, child) {
          if (controller.currentSong == null) {
            return const SizedBox.shrink();
          }

          if(controller.currentSong!.artwork != null){
            debugPrint("MYAPP: mini player -> image loaded");
          }else{
            debugPrint("MYAPP: mini player -> image not loaded");
          }

          if (controller.isPlaying) {
            if (!_vinylController.isAnimating) {
              _vinylController.repeat();
            }
          } else {
            _vinylController.stop();
          }
          return GestureDetector(
            onTap: (){
              MusicPlayerSheet.show(context);
            },

            // Swipe detection
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;

              // Swipe left → next
              if (velocity < -300) {
                controller.playNext();
              }

              // Swipe right → previous
              if (velocity > 300) {
                controller.playPrevious();
              }
            },

            child: Container(
              height: 75,
              margin: EdgeInsets.symmetric(horizontal: 20),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Row(
                        children: [
                          ClipPath(
                            clipper: SquircleClipper(20),
                            child: Container(
                              width: 45,
                              height: 45,
                              color: Color(0xFF342E1B),
                              child: controller.currentSong?.artwork != null
                                  ? Image.memory(
                                controller.currentSong!.artwork!,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                                  : Icon(Icons.music_note_rounded, color: Colors.white),
                            ),
                          ),

                          SizedBox(width: 15,),

                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.currentSong!.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.rubik(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF342E1B),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  controller.currentSong!.artist,
                                  style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF342E1B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 10,),

                          InkWell(
                            onTap: (){
                              controller.toggleShuffle();
                            },
                            child: Icon(
                              Icons.shuffle,
                              color: controller.isShuffleOn ? Color(0xFF342E1B) :const Color(0xFF342E1B).withOpacity(0.4),
                              size: 28,
                            ),
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

                          GestureDetector(
                            onTap: () => controller.togglePlayPause(),
                            child: RotationTransition(
                              turns: _vinylController,
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
                                          child: Icon( controller.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded, size: 20, color: Colors.black,),
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
                    LinearProgressIndicator(
                      minHeight: 5,
                      value: controller.progress,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF342E1B),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
