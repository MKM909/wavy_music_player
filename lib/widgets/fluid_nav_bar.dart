import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/widgets/waveform_slidder.dart';

import '../bottom_sheets/add_to_playlist_sheet.dart';
import '../bottom_sheets/music_player_sheet.dart';
import '../clippers/squircle_clipper.dart';
import '../controllers/music_controller.dart';
import '../model/liked_songs.dart';
import '../model/nav_item.dart';
import '../model/song.dart';
import '../services/liked_song_service.dart';
import 'album_artwork.dart';
import 'nav_button.dart';

class FluidNavBar extends StatefulWidget {

  final List<NavItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FluidNavBar({super.key, required this.tabs, required this.currentIndex, required this.onTap});

  @override
  State<FluidNavBar> createState() => _FluidNavBarState();
}

class _FluidNavBarState extends State<FluidNavBar> with SingleTickerProviderStateMixin {

  bool isLiked = false;
  bool expandMusicPlayer = true;
  late final AnimationController _vinylController;
  String? _lastSongPath;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final musicController = context.read<MusicController>();
    final likedService = LikedSongsService();

    final song = musicController.currentSong;
    if (song != null) {
      isLiked = likedService.isLiked(song.filePath);
    }
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
          bool isPlaying = controller.currentSong != null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(isPlaying ? (expandMusicPlayer ? 40 : 50) : 100), topRight: Radius.circular(isPlaying ? (expandMusicPlayer ? 40 : 50) : 100), bottomLeft: Radius.circular(isPlaying ? 50 : 100), bottomRight: Radius.circular(isPlaying ? 50 : 100)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      height: expandMusicPlayer ? 175 : 130, // 👈 explicit
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(isPlaying ? (expandMusicPlayer ? 40 : 50) : 100), topRight: Radius.circular(isPlaying ? (expandMusicPlayer ? 40 : 50) : 100), bottomLeft: Radius.circular(isPlaying ? 50 : 100), bottomRight: Radius.circular(isPlaying ? 50 : 100)),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.98, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        builder: (_, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOut,
                              opacity: expandMusicPlayer ? 1.0 : 0.85,
                              child: _miniPlayer(),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child:  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(isPlaying ? 45 : 100), topRight: Radius.circular(isPlaying ? 45 : 100), bottomLeft: Radius.circular(isPlaying ? 45 : 100), bottomRight: Radius.circular(isPlaying ? 45 : 100)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            widget.tabs.length,
                                (index) => NavButton(
                              item: widget.tabs[index],
                              isActive: index == widget.currentIndex,
                              onTap: (){
                                widget.onTap(index);
                                if(widget.tabs[index].label == widget.tabs[widget.currentIndex].label){
                                  expandMusicPlayer = !expandMusicPlayer;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _miniPlayer(){
    return Consumer<MusicController>(
        builder: (context, controller, child) {

          if (controller.currentSong == null) {
            return const SizedBox.shrink();
          }

          final currentSong = controller.currentSong!;

          if (_lastSongPath != currentSong.filePath) {
            _lastSongPath = currentSong.filePath;
            isLiked = LikedSongsService().isLiked(currentSong.filePath);
          }


          if (controller.isPlaying) {
            if (!_vinylController.isAnimating) {
              _vinylController.repeat();
            }
          } else {
            _vinylController.stop();
          }

          return InkWell(
            onTap: () => MusicPlayerSheet.show(context),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );

                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15), // 👈 comes from bottom
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              child: expandMusicPlayer
                  ? _expandedMiniPlayer(controller,currentSong)
                  : _collapsedMiniPlayer(controller,currentSong),
            ),
          );
        }
    );
  }

  Widget _expandedMiniPlayer(MusicController controller, Song currentSong){
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom : 20, top: 20),
      child: Row(
        children: [
          ClipPath(
            clipper: SquircleClipper(20),
            child: Container(
              width: 50,
              height: 50,
              color: Color(0xFF342E1B),
              child: AlbumArtwork(
                song: currentSong,
                size: 50,
                borderRadius: BorderRadius.circular(8),
                nullIconColor: Color(0xFF342E1B),
                backgroundColor: const Color(0xFFFFE695),
              ),
            ),
          ),

          SizedBox(width: 10,),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentSong!.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFE695),
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  controller.currentSong!.artist,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFE695),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: () {
              final service = LikedSongsService();
              final song = controller.currentSong!;

              setState(() {
                if (isLiked) {
                  service.removeSong(song.filePath);
                } else {
                  service.addSong(
                    LikedSong(
                        filePath: song.filePath,
                        title: song.title,
                        artist: song.artist,
                        fileSize: song.fileSize
                    ),
                  );
                }
                isLiked = !isLiked;
              });
            },
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : const Color(0xFFFFE695),
              size: 28,
            ),
          ),



          SizedBox(width: 10),

          GestureDetector(
            onTap: () => controller.togglePlayPause(),
            child: RotationTransition(
              turns: _vinylController,
              child: Container(
                width: 45,
                height: 45,
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
                        width: 25,
                        height: 25,
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
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFDE68A),
                        ),
                        child: Center(
                          child: Icon( controller.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded, size: 18, color: Colors.black,),
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
    );
  }

  Widget _collapsedMiniPlayer(MusicController controller, Song currentSong){
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipPath(
              clipper: SquircleClipper(5),
              child: Container(
                width: 20,
                height: 20,
                child: AlbumArtwork(
                  song: currentSong,
                  size: 20,
                  borderRadius: BorderRadius.circular(8),
                  nullIconColor: Color(0xFF342E1B),
                  backgroundColor: const Color(0xFFFFE695),
                ),
              ),
            ),
            SizedBox(width: 20,),
            Expanded(
              child: WaveformSlider(
                barCount: 15,
                height: 10,
                fillColor: const Color(0xFFFFE695),
                thumbColor: const Color(0xFFFB923C),
                inactiveColor: Colors.white,
                thumbRadius: 8,
                progress: controller.progress,
                onChanged: (value) {
                  final duration = controller.totalDuration;
                  final seekTo = duration * value;
                  controller.seek(seekTo);
                },
              ),
            ),
            SizedBox(width: 20,),
            Text(
              controller.formatDuration(controller.totalDuration),
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFFE695),
              ),
            ),
          ]
      ),
    );
  }

}
