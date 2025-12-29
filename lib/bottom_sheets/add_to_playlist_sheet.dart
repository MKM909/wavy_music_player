import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/bottom_sheets/playlist_creation_sheet.dart';
import '../model/playlist.dart';
import '../model/song.dart';
import '../services/playlist_service.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  static void show(BuildContext context, {required Song song}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {

  PlaylistService playlistService = PlaylistService();

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

          return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE695),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _handle(),
              _title(),
              Expanded(
                child: playlists.isEmpty
                    ? _empty(context)
                    : ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(
                        playlist.name,
                        style: GoogleFonts.rubik(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle:
                      Text('${PlaylistService().getSongs(playlist.id).length} songs'),
                      onTap: () {
                        PlaylistService()
                            .addSongToPlaylist(playlist.id, widget.song);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
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

  Widget _handle() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: const Color(0xFF342E1B),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  Widget _title() => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      'Add to playlist',
      style: GoogleFonts.rubik(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF342E1B),
      ),
    ),
  );

  Widget _empty(BuildContext context) => Center(
    child: TextButton.icon(
      onPressed: () {
        Navigator.pop(context);
        PlaylistCreationSheet.show(context);
      },
      icon: const Icon(Icons.add),
      label: const Text('Create playlist'),
    ),
  );
}
