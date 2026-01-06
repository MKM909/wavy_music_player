import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/widgets/waveform_slidder.dart';

import '../bottom_sheets/add_to_playlist_sheet.dart';
import '../bottom_sheets/music_player_sheet.dart';
import '../clippers/squircle_clipper.dart';
import '../controllers/music_controller.dart';
import '../model/liked_songs.dart';
import '../model/song.dart';
import '../services/liked_song_service.dart';
import 'album_artwork.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key,});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {

  bool isLiked = false;
  bool expandMusicPlayer = false;
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
          if (controller.currentSong == null) {
            return const SizedBox.shrink();
          }

          final currentSong = controller.currentSong!;

          bool isPlaying = controller.isPlaying;

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
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(isPlaying ? (expandMusicPlayer ? 40 : 50) : 100), topRight: Radius.circular(isPlaying ? (expandMusicPlayer ? 40 : 50) : 100), bottomLeft: Radius.circular(isPlaying ? 50 : 100), bottomRight: Radius.circular(isPlaying ? 50 : 100)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    height: 50, // 👈 explicit
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50), bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.98, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (_, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        opacity: expandMusicPlayer ? 1.0 : 0.85,
                        child: _miniPlayer(),
                      ),
                    ),
                  ),
                ),
              ),
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

          return ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Material(
              borderRadius: BorderRadius.circular(100),
              color: Colors.transparent,
              child: InkWell(
                onTap: () => MusicPlayerSheet.show(context),
                child:  _collapsedMiniPlayer(controller,currentSong),
              ),
            ),
          );
        }
    );
  }

  Widget _collapsedMiniPlayer(MusicController controller, Song currentSong){
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipPath(
              clipper: SquircleClipper(5),
              child: Container(
                width: 20,
                height: 20,
                color: Color(0xFF342E1B),
                child: AlbumArtwork(
                  song: currentSong,
                  size: 20,
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: const Color(0xFF342E1B),
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
