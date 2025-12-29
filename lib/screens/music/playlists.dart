import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/screens/music/playlist_viewing_page.dart';

import '../../bottom_sheets/playlist_creation_sheet.dart';
import '../../clippers/squircle_clipper.dart';
import '../../controllers/music_controller.dart';
import '../../model/playlist.dart';
import '../../model/song.dart';
import '../../services/playlist_service.dart';
import '../../widgets/album_artwork.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {

  late PlaylistService playlistService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playlistService  = PlaylistService();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Playlist>>(
      stream: playlistService.watchPlaylists(),
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

        final playlists = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              return _buildPlaylistCard(playlists[index]);
            },
          ),
        );
      },
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
          const Text(
            'Scanning for music files...',
            style: TextStyle(
              fontSize: 16,
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

            SizedBox(height: 20,),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                color: const Color(0xFF342E1B),
                child: InkWell(
                  onTap: () => PlaylistCreationSheet.show(context),
                  splashColor:
                  Colors.white.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'Add',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return Consumer<MusicController>(
      builder: (context, controller, _) {
        final current = controller.currentSong;

        final isPlayingFromPlaylist =
            current != null &&
                PlaylistService().containsSong(
                  playlist.id,
                  current.filePath,
                );

        final songs = PlaylistService().getSongs(playlist.id);

        final songCount = songs.length;
        Song firstSong = Song(filePath: '', title: '', fileName: '');
        if(songs.isNotEmpty){
          firstSong = Song(filePath: songs[0].filePath, title: songs[0].title, fileName: songs[0].title);
        }


        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlaylistViewingPage(),
            ),
          ),
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
                    child: _buildPlaylistInfo(
                      playlist.name,
                      songCount,
                      isPlayingFromPlaylist,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistInfo(
      String name,
      int count,
      bool isPlaying,
      ) {
    return Container(
      height: 70,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00342E1B),
            Color(0x80342E1B),
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
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count songs',
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isPlaying)
            const Icon(
              Icons.equalizer,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }

}
