import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/model/album.dart';
import 'package:wavy_muic_player/model/playlist.dart';
import 'package:wavy_muic_player/widgets/mini_player.dart';

import '../../bottom_sheets/music_player_sheet.dart';
import '../../clippers/squircle_clipper.dart';
import '../../controllers/music_controller.dart';
import '../../model/artist.dart';
import '../../model/playlist_song.dart';
import '../../model/song.dart';
import '../../services/playlist_service.dart';
import '../../widgets/album_artwork.dart';
import '../../widgets/continous_wave.dart';

class ArtistViewingPage extends StatefulWidget {

  final Artist artist;

  const ArtistViewingPage({super.key, required this.artist});

  @override
  State<ArtistViewingPage> createState() => _ArtistViewingPageState();
}

class _ArtistViewingPageState extends State<ArtistViewingPage> with TickerProviderStateMixin {
  late AnimationController _vinylController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
        builder: (context, musicController, _) {

          final current = musicController.currentSong;
          final firstSong = widget.artist.songs.first;

          final isPlayingFromArtist =
              current != null &&
                  widget.artist.songs.contains(current);

          final songs = widget.artist.songs;

          return Scaffold(
            backgroundColor: const Color(0xFF342E1B),
            body: Stack(
              children: [
                Positioned.fill(
                  child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    controller: _scrollController,
                    slivers: [
                      _buildSliverHeader(musicController: musicController, artist: widget.artist,isPlayingFromArtist: isPlayingFromArtist),
                      SliverToBoxAdapter(child: SizedBox(height: 10,)),
                      _buildSliverSongList(controller: musicController, songs: songs,),
                      SliverToBoxAdapter(child: SizedBox(height: 100,)),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF342E1B).withValues(alpha: 0.1),
                          const Color(0xFF342E1B).withValues(alpha: 0.6),
                          const Color(0xFF342E1B).withValues(alpha: 0.9),
                          const Color(0xFF342E1B),
                        ],
                      ),
                    ),
                  ),
                ),

                // App Bar
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
                    color: const Color(0xFFFFE695),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCircularButton(CupertinoIcons.back, () => Navigator.pop(context)),
                        SizedBox(width: 20,),
                        Expanded(
                          child: Text(
                            widget.artist.name.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.rubik(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Color(0xFF342E1B),
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                      ],
                    ),
                  ),
                ),

                // Pinned FAB
                Positioned(
                  top: 65,
                  right: 15,
                  child: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      // Fade in FAB when collapsed
                      double offset = _scrollController.hasClients ? _scrollController.offset : 0;
                      // 0 = fully expanded, 1 = fully collapsed
                      double collapsePercent = (offset / (275.0 - kToolbarHeight)).clamp(0.0, 1.0);

                      return Opacity(
                        opacity: collapsePercent,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - collapsePercent)), // optional slide-up effect
                          child: RotationTransition(
                            turns: _vinylController,
                            child: GestureDetector(
                              onTap: () {
                                if (songs.isEmpty) return;

                                if (isPlayingFromArtist) {
                                  musicController.togglePlayPause();
                                } else {
                                  musicController.playPlaylist(
                                    songs: songs,
                                    startIndex: 0,
                                  );
                                }
                              },

                              child: Container(
                                width: 60,
                                height: 60,
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
                                        width: 50,
                                        height: 50,
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
                                        width: 40,
                                        height: 40,
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
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFFDE68A),
                                        ),
                                        child: Center(
                                          child: Icon(Icons.play_circle, size: 24, color: Colors.black,),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: MiniPlayer(),
                )

              ],
            ),
          );
        }
    );
  }


  Widget _buildSliverHeader({required MusicController musicController, required Artist artist, required bool isPlayingFromArtist}) {
    return SliverAppBar(
      expandedHeight: 275.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFFFE695),
      automaticallyImplyLeading: false,
      title: Container(),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double top = constraints.biggest.height;
            double collapsePercent = ((top - kToolbarHeight) / (100.0 - kToolbarHeight)).clamp(0.0, 1.0);

            return Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: ContiniousWave(progress: collapsePercent, fillDouble: Color(0xFF342E1B),),
                ),
                Opacity(
                  opacity: collapsePercent,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: _buildAlbumCard(isPlayingFromArtist: isPlayingFromArtist, musicController: musicController),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF342E1B).withOpacity(0.35),
                        ),
                        child: IconButton(
                          icon: Icon( CupertinoIcons.ellipsis, color: Colors.white, size: 30),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }


  // Helper for your circular glass buttons
  Widget _buildCircularButton(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF342E1B).withOpacity(0.35),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 25),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverSongList(
      {
        required MusicController controller,
        required List<Song> songs,
      }) {
    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text(
              'No songs in this Album',
              style: GoogleFonts.rubik(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final song = songs[index];
          final isPlaying =
              controller.currentSong?.filePath == song.filePath;

          return _buildSongTile(
            song: song,
            isPlaying: isPlaying,
            onTap: () {
              if (isPlaying) {
                controller.togglePlayPause();
                MusicPlayerSheet.show(context);
              } else {
                controller.playPlaylist(
                  songs: songs,
                  startIndex: index,
                );
              }
            },
            musicController: controller,
          );
        },
        childCount: songs.length, // ✅ THIS FIXES IT
      ),
    );
  }



  Widget _buildAlbumCard({required bool isPlayingFromArtist, required MusicController musicController}) {

    return Transform.rotate(
      angle: 0.02,
      child: isPlayingFromArtist && musicController.currentSong?.albumArt != null
          ? SizedBox(
        height: 200,
        width: 300,
        child: Stack(
          children: [
            // Vinyl Record
            Positioned(
              top: 10,
              right: 0,
              bottom: 10,
              child: RotationTransition(
                turns: _vinylController,
                child: Container(
                  width: 150,
                  height: 150,
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
                          width: 100,
                          height: 100,
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
                          width: 80,
                          height: 80,
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
                          width: 50,
                          height: 50,
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
              bottom: 0,
              left: 20,
              right: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 150,
                  height: 200,
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
                    size: 150,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: const Color(0xFF342E1B),
                  ),
                ),
              ),
            )
          ],
        ),
      )
          : Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                    width: 150,
                    height: 150,
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
                            width: 90,
                            height: 90,
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
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1F2937), Color(0xFF000000)],
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 22,
                                    height: 22,
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
                          bottom: 10,
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
                    child: Consumer<MusicController>(
                        builder: (context, controller, _) {
                          if (controller.isPlaying) {
                            if (!_vinylController.isAnimating) {
                              _vinylController.repeat();
                            }
                          } else {
                            _vinylController.stop();
                          }
                          return RotationTransition(
                            turns: _vinylController,
                            child: Container(
                              width: 90,
                              height: 90,
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
                                      width: 50,
                                      height: 50,
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
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFFDE68A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
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




  Widget _buildSongTile({
    required Song song,
    required MusicController musicController,
    required bool isPlaying,
    required VoidCallback onTap,
  }) {
    final isCurrentSong = musicController.currentSong?.filePath == song.filePath;
    final isActuallyPlaying = isCurrentSong && musicController.isPlaying;
    return InkWell(
      onTap: () {
        if (isPlaying) {
          MusicPlayerSheet.show(context);
        } else {
          onTap();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10, top: 10),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipPath(
                clipper: SquircleClipper(20),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Color(0xFFFFE695).withValues(alpha: 0.5),
                  child: AlbumArtwork(
                    song: Song(filePath: song.filePath, title: song.title, fileName: song.fileName),
                    size: 60,
                    borderRadius: BorderRadius.circular(8),
                    nullIconColor: Color(0xFF342E1B),
                    backgroundColor: Color(0xFFFFE695).withValues(alpha: 0.5),
                  ),
                ),
              ),

              SizedBox(width: 15,),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: isPlaying ? Color(0xFFFBBF24) : Colors.white,
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isPlaying ? Color(0xFFFBBF24) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 15,),

              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onTap();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFE695).withValues(alpha: 0.5),
                        ),
                        child: Icon(
                          isActuallyPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 25,
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

