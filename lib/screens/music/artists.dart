import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/screens/music/artist_viewing_page.dart';

import '../../clippers/squircle_clipper.dart';
import '../../controllers/music_controller.dart';
import '../../model/artist.dart';
import '../../services/music_library_service.dart';
import '../../widgets/album_artwork.dart';

class Artists extends StatefulWidget {
  const Artists({super.key});

  @override
  State<Artists> createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  final MusicLibraryService _musicService = MusicLibraryService();

  List<Artist> artists = [];
  bool isScanning = false;
  int scanProgress = 0;
  int scanTotal = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArtistsFast();
  }

  Future<void> _loadArtistsFast() async {
    final cachedSongs = _musicService.getCachedSongs();
    if (cachedSongs != null && cachedSongs.isNotEmpty) {
      artists = _musicService
          .categorizeByArtist(cachedSongs)
          .values
          .toList();
      setState(() {});
      return;
    }
    await _loadArtistsFull();
  }

  Future<void> _loadArtistsFull({bool forceRefresh = false, bool background = false}) async {
    setState(() {
      if(background == true){
        isScanning = false;
        errorMessage = null;
      } else {
        isScanning = true;
        errorMessage = null;
      }
      scanProgress = 0;
      scanTotal = 0;
    });

    final hasPermission = await _musicService.requestMusicPermission();
    if (!hasPermission) {
      setState(() {
        isScanning = false;
        errorMessage = 'Storage permission denied';
      });
      return;
    }

    final songs = await _musicService.getAllSongs(
      forceRefresh: forceRefresh,
      onProgress: (current, total) {
        setState(() {
          scanProgress = current;
          scanTotal = total;
        });
      },
    );

    final artistMap = _musicService.categorizeByArtist(songs);

    setState(() {
      artists = artistMap.values.toList();
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isScanning) return _buildLoadingView();
    if (errorMessage != null) return _buildErrorView();
    if (artists.isEmpty) return _buildEmptyView();

    return RefreshIndicator(
      displacement: 110,
      backgroundColor: const Color(0xFF342E1B),
      color: const Color(0xFFFFE695),
      onRefresh: () async => _loadArtistsFull(forceRefresh: true, background: true),
      child: _buildArtistsList(),
    );
  }

  Widget _buildArtistsList() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: GridView.builder(
        padding: EdgeInsets.only(top: 110, bottom: 160),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return _buildArtistsCard(artists[index]);
        },
      ),
    );
  }


  Widget _buildArtistsCard(Artist artist) {
    return Consumer<MusicController>(
      builder: (context, controller, _) {
        final current = controller.currentSong;
        final firstSong = artist.songs.first;

        final isPlayingFromPlaylist =
            current != null &&
                artist.songs.contains(current);


        final songCount = artist.songs.length;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistViewingPage(artist: artist ,),
              ),
            );
          },
          child: ClipPath(
            clipper: SquircleClipper(40),
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF605535),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: songCount > 0 ? AlbumArtwork(
                        song: firstSong,
                        size: 150,
                        backgroundColor: const Color(0xFF342E1B),
                      ) : Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildArtistInfo(
                      artist.name,
                      songCount,
                      isPlayingFromPlaylist,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtistInfo(
      String name,
      int count,
      bool isPlaying,
      ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00342E1B),
            Color(0x3F342E1B),
            Color(0x78342E1B),
            Color(0xB3342E1B),
            Color(0xFF342E1B),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count songs',
                  style: GoogleFonts.rubik(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          if (isPlaying)
            const Icon(
              Icons.equalizer,
              color: Colors.green,
              size: 18,
            ),
        ],
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
              onPressed: () => _loadArtistsFull(forceRefresh: true),
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
              'No albums found',
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

}
