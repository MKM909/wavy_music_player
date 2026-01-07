import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/bottom_sheets/add_to_playlist_sheet.dart';

import '../../clippers/squircle_clipper.dart';
import '../../controllers/music_controller.dart';
import '../../model/song.dart';
import '../../services/music_library_service.dart';
import '../../widgets/album_artwork.dart';
import '../../widgets/spring_popup_menu.dart';


class DownloadedSongs extends StatefulWidget {
  const DownloadedSongs({super.key});

  @override
  State<DownloadedSongs> createState() => _DownloadedSongsState();
}

class _DownloadedSongsState extends State<DownloadedSongs> {
  final MusicLibraryService _musicService = MusicLibraryService();
  List<Song> songs = [];
  bool isLoading = false;
  bool isScanning = false;
  int scanProgress = 0;
  int scanTotal = 0;
  String? errorMessage;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _loadMusicFast();
  }

  Future<void> _loadMusicFast() async {
    // Try cached data first (instant)
    final cached = _musicService.getCachedSongs();
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        songs = cached;
      });
      return;
    }

    // No cache, do full load
    await _loadMusicFull();
  }

  Future<void> _loadMusicFull({bool forceRefresh = false, bool isBackground = false}) async {
    setState(() {
      isLoading = true;
      isScanning = !isBackground;
      errorMessage = null;
      scanProgress = 0;
      scanTotal = 0;
    });

    try {
      final hasPermission = await _musicService.requestMusicPermission();

      if (hasPermission) {
        final allSongs = await _musicService.getAllSongs(
          forceRefresh: forceRefresh,
          onProgress: (current, total) {
            setState(() {
              scanProgress = current;
              scanTotal = total;
            });
          },
        );

        setState(() {
          songs = allSongs;
          isLoading = false;
          isScanning = false;
        });

        if (songs.isEmpty) {
          setState(() {
            errorMessage = 'No music files found on your device';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Permission denied. Please grant storage access in settings.';
          isLoading = false;
          isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading music: $e';
        isLoading = false;
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isScanning
        ? _buildLoadingView()
        : errorMessage != null
        ? _buildErrorView()
        : songs.isEmpty
        ? _buildEmptyView()
        : RefreshIndicator(
      displacement: 110,
        backgroundColor: Color(0xFF342E1B),
        color: Color(0xFFFFE695),
        onRefresh: () { _loadMusicFull(forceRefresh: true, isBackground: true); return Future.delayed(Duration(seconds: 1)); },
        child: _buildSongList()
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
          if (scanTotal > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Checking $scanProgress of $scanTotal locations',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  color: Color(0xFF342E1B).withOpacity(0.6),
                ),
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
            const SizedBox(height: 24),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 16,
                color: Color(0xFF342E1B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadMusicFull(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF342E1B),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.rubik(
                    fontSize: 16,
                    color: Color(0xFFFFE695)
                ),
              ),
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
              Icons.music_off_rounded,
              size: 64,
              color: Color(0xFF342E1B).withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No music found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF342E1B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some music files to your device and refresh',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF342E1B).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: songs.length,
      padding: EdgeInsets.only(top: 110,left: 10, right: 10, bottom: 160),
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildSongTile(
          song: song,
        );
      },
    );
  }

  Widget _buildSongTile({
    required Song song,
  }) {
    return Consumer<MusicController>(
        builder: (context, musicController, child) {
          final isCurrentSong = musicController.currentSong?.filePath == song.filePath;
          final isActuallyPlaying = isCurrentSong && musicController.isPlaying;
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () {
                  if(musicController.currentSong == song){
                    musicController.togglePlayPause();
                  }else{
                    // Play this song with full queue
                    musicController.playSong(
                      song,
                      newQueue: songs,
                      startIndex: songs.indexOf(song),
                    );
                  }
                },
                onTapDown: (details) {
                  _tapPosition = details.globalPosition;
                },
                onLongPress: () {
                  if (_tapPosition == null) return;
                  showSpringPopupMenu(
                    context: context,
                    position: _tapPosition!,
                    items: [
                      SpringMenuItem(
                        icon: Icons.play_arrow,
                        label: 'Play',
                        onTap: () {
                          musicController.playSong(
                            song,
                            newQueue: songs,
                            startIndex: songs.indexOf(song),
                          );
                        },
                      ),
                      SpringMenuItem(
                        icon: Icons.playlist_add,
                        label: 'Add to Playlist',
                        onTap: () {
                          AddToPlaylistSheet.show(context, song: song);
                        },
                      ),
                      SpringMenuItem(
                        icon: Icons.add_to_queue_rounded,
                        label: 'Add to queue',
                        onTap: () async {
                          await musicController.addToQueueNext(song);
                        },
                      ),
                    ],
                  );
                },
                splashColor: Color(0xFF342E1B).withValues(alpha: 0.2),
                focusColor: Color(0xFF342E1B).withValues(alpha: 0.2),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10, top: 10),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24)
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
                                _musicService.getFormattedFileSize(song.fileSize),
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
                                  Icons.playlist_add_rounded,
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
                                  if(musicController.currentSong == song){
                                    musicController.togglePlayPause();
                                  }else{
                                    // Play this song with full queue
                                    musicController.playSong(
                                      song,
                                      newQueue: songs,
                                      startIndex: songs.indexOf(song),
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
          );
        }
    );
  }
}
