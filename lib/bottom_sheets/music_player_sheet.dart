import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../controllers/music_controller.dart';
import '../model/liked_songs.dart';
import '../model/song.dart';
import '../painters/offset_squircle_background.dart';
import '../painters/softwave_painter.dart';
import '../services/liked_song_service.dart';
import '../widgets/album_artwork.dart';
import '../widgets/waveform_slidder.dart';

class MusicPlayerSheet extends StatefulWidget {
  const MusicPlayerSheet({Key? key}) : super(key: key);

  // Helper to show the bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MusicPlayerSheet(),
    );
  }

  @override
  State<MusicPlayerSheet> createState() => _MusicPlayerSheetState();
}

class _MusicPlayerSheetState extends State<MusicPlayerSheet>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  double progress = 0.45;
  bool isLiked = false;
  late AnimationController _vinylController;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
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
        builder: (context, musicController, child) {

          final currentSong = musicController.currentSong!;

          isLiked = LikedSongsService().isLiked(currentSong.filePath);

          if (musicController.isPlaying) {
            if (!_vinylController.isAnimating) {
              _vinylController.repeat();
            }
          } else {
            _vinylController.stop();
          }
          return DraggableScrollableSheet(
          initialChildSize: 1.0, // Start fully expanded
          minChildSize: 0.3, // Can be dragged down to 30%
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Container(
                padding: EdgeInsets.only(top: 5),
                margin: EdgeInsets.only(top: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedWave(color: Color(0xFF342E1B),size: const Size(double.infinity, 365), sec: 15,)
                    ),

                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedWave(color: Color(0xFFFB923C),size: const Size(double.infinity, 345), sec: 10,)
                    ),

                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedWave(color: Color(0xFFFFE695),size: const Size(double.infinity, 335), sec: 5,)
                    ),
                    Column(
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF342E1B).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Main Album Card
                        _buildAlbumCard(musicController),

                        Padding(
                          padding: const EdgeInsets.only(left: 30 , right : 30.0),
                          child: Column(
                            children: [

                              const SizedBox(height: 35),

                              _buildSongInfo(musicController),
                              const SizedBox(height: 34),

                            ],
                          ),
                        ),

                        // Header with Recent Players
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 30 , right : 30.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            musicController.showQueueEditor(context);
                                          },
                                          child: Icon(
                                            Icons.queue_music_sharp,
                                            color: Color(0xFF342E1B),
                                            size: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    // Progress Bar
                                    _buildProgressBar(musicController),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Previous Songs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Color(0xFF342E1B),
              ),
            ),
            Row(
              children: [
                _buildPlayerAvatar('👤'),
                const SizedBox(width: 8),
                _buildPlayerAvatar('🎵'),
                const SizedBox(width: 8),
                _buildPlayerAvatar('🎸'),
                const SizedBox(width: 8),
                _buildPlayerAvatar('🎹'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerAvatar(String emoji) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(MusicController musicController) {
    if(musicController.currentSong?.albumArt != null){
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: Stack(
          children: [
            // Vinyl Record
            Positioned(
              top: 10,
              right: 10,
              bottom: 10,
              child: RotationTransition(
                turns: _vinylController,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF342E1B), Colors.brown.shade500,],
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
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.brown.shade100.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.brown.shade300.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 80,
              bottom: 0,
              left: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(0xFF83733E).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(-10, 10),
                      ),
                    ],
                  ),
                  child: AlbumArtwork(
                    song: musicController.currentSong!,
                    size: 240,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: const Color(0xFF342E1B),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Transform.rotate(
        angle: 0.02,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Color(0xFF83733E).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Album Cover
                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFDE68A), Color(0xFFFBBF24)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFB923C), Color(0xFFEF4444)],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF1F2937), Color(0xFF000000)],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFFB923C),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Text(
                              'CNS n66',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF342E1B).withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Vinyl Record
                    Positioned(
                      top: 20,
                      right: -40,
                      child: RotationTransition(
                        turns: _vinylController,
                        child: Container(
                          width: 140,
                          height: 140,
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
                                  width: 100,
                                  height: 100,
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
                                  width: 60,
                                  height: 60,
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
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFDE68A),
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
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSongInfo(MusicController musicController) {

    Song song = musicController.currentSong!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            InkWell(
              onTap: (){
                musicController.toggleShuffle();
              },
              child: Icon(
                Icons.shuffle,
                color: musicController.isShuffleOn ? Color(0xFF342E1B) :const Color(0xFF342E1B).withOpacity(0.4),
                size: 28,
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                final service = LikedSongsService();
                final song = musicController.currentSong!;

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
                color: isLiked ? Colors.red : const Color(0xFF342E1B).withOpacity(0.4),
                size: 28,
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: (){
                musicController.toggleRepeatMode();
              },
              child: Icon(
                musicController.repeatMode == RepeatMode.off ? Icons.repeat : (musicController.repeatMode == RepeatMode.all ? Icons.repeat_sharp: Icons.repeat_one),
                color: musicController.repeatMode != RepeatMode.off ? Color(0xFF342E1B) :const Color(0xFF342E1B).withOpacity(0.4),
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title ?? 'No Song Playing',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF342E1B),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.artist ?? '',
                style: TextStyle(
                  fontSize: 20,
                  color: const Color(0xFF342E1B).withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(MusicController musicController) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WaveformSlider(
                barCount: 15,
                fillColor: const Color(0xFF342E1B),
                thumbColor: const Color(0xFFFB923C),
                inactiveColor: const Color(0xFF342E1B).withOpacity(0.1),
                progress: musicController.progress,
                onChanged: (value) {
                  final duration = musicController.totalDuration;
                  final seekTo = duration * value;
                  musicController.seek(seekTo);
                },
              ),
            ),
            const SizedBox(width: 20),
            _buildPlaybackControls(musicController)
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                musicController.formatDuration(musicController.currentPosition),
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF342E1B).withOpacity(0.6),
                ),
              ),
              Text(
                musicController.formatDuration(musicController.totalDuration),
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF342E1B).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(MusicController musicController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => musicController.playPrevious(),
          icon: const Icon(Icons.skip_previous_outlined),
          iconSize: 30,
          color: const Color(0xFF342E1B),
        ),

        GestureDetector(
          onTap: () => musicController.togglePlayPause(),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: OffsetSquircleBackgroundPainter(
                      fillColor: Colors.white,
                      strokeColor: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    musicController.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),

        IconButton(
          onPressed: () => musicController.playNext(),
          icon: Icon(Icons.skip_next_outlined),
          iconSize: 30,
          color: const Color(0xFF342E1B),
        ),
      ],
    );
  }

}
