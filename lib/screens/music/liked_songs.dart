import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../bottom_sheets/add_to_playlist_sheet.dart';
import '../../clippers/squircle_clipper.dart';
import '../../controllers/music_controller.dart';
import '../../model/liked_songs.dart';
import '../../model/song.dart';
import '../../services/liked_song_service.dart';
import '../../services/music_library_service.dart';
import '../../widgets/album_artwork.dart';

class LikedSongsScreen extends StatefulWidget {
  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  final likedService = LikedSongsService();
  final musicService = MusicLibraryService();
  late final List<LikedSong> songs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    songs = likedService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LikedSong>>(
      stream: likedService.watchAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingView();
        }

        if (snapshot.hasError) {
          return _buildErrorView();
        }

        final songs = snapshot.data!;

        if (songs.isEmpty) {
          return _buildEmptyView();
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 110,left: 10, right: 10, bottom: 160),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final likedSong = songs[index];
            return _buildSongTile(likedSong: likedSong);
          },
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.favorite_border_rounded,
        color: Colors.red,
        size: 28,
      ),
    );
  }


  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF342E1B)),
          ),
          const SizedBox(height: 24),
          Text(
            'Scanning for music files...',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF342E1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Color(0xFF342E1B).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.heart_broken_rounded,
              size: 64,
              color: Color(0xFF342E1B).withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No music found',
              style: GoogleFonts.rubik(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF342E1B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Like some songs and refresh',
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Color(0xFF342E1B).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongTile({
    required LikedSong likedSong,
  }) {
    {
      return Consumer<MusicController>(
          builder: (context, musicController, child) {
            final song = Song(
                filePath: likedSong.filePath,
                title: likedSong.title,
                fileName: likedSong.title,
                fileSize: likedSong.fileSize
            );
            final isCurrentSong =
                musicController.currentSong?.filePath == likedSong.filePath;
            final isActuallyPlaying =
                isCurrentSong && musicController.isPlaying;
            return Dismissible(
              key: ValueKey(likedSong.id),
              direction: isActuallyPlaying
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              background: _buildDismissBackground(),
              onDismissed: (_) {
                likedService.removeSong(likedSong.filePath);
                HapticFeedback.mediumImpact();
                final messenger = ScaffoldMessenger.of(context);

                messenger.hideCurrentSnackBar(); // 👈 THIS is the missing piece

                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Removed from liked songs'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        likedService.addSong(likedSong);
                      },
                    ),
                  ),
                );
                Future.delayed(Duration(seconds: 2),() => messenger.hideCurrentSnackBar());
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () {
                      if (isCurrentSong) {
                        musicController.togglePlayPause();
                      } else {
                        musicController.playSong(
                          song,
                          newQueue: likedService.getAllAsSongs(),
                          startIndex: likedService.indexOf(likedSong.filePath),
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10, top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipPath(
                              clipper: SquircleClipper(20),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Color(0xFF342E1B),
                                child: AlbumArtwork(
                                  song: song,
                                  size: 60,
                                  borderRadius: BorderRadius.circular(8),
                                  backgroundColor: const Color(0xFF342E1B),
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
                                      color: isActuallyPlaying
                                          ? Colors.orange
                                          : const Color(0xFF342E1B),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    musicService.getFormattedFileSize(song.fileSize),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isActuallyPlaying
                                          ? Colors.orange
                                          : const Color(0xFF342E1B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 15,),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    AddToPlaylistSheet.show(context, song: song);
                                  },
                                  child: Center(
                                    child: Icon(
                                      Icons.playlist_add,
                                      color: Color(0xFF342E1B),
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (isCurrentSong) {
                                        musicController.togglePlayPause();
                                      } else {
                                        musicController.playSong(
                                          song,
                                          newQueue: likedService.getAllAsSongs(),
                                          startIndex: likedService.indexOf(
                                              likedSong.filePath),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF342E1B).withValues(alpha: 0.5),
                                      ),
                                      child: Icon(
                                        isCurrentSong ? (isActuallyPlaying ? Icons.pause : Icons.play_arrow) : Icons.play_arrow_rounded,
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
                  ),
                ),
              ),
            );
          }
      );
    }
  }
}
