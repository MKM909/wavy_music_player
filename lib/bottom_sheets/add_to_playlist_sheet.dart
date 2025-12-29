import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/bottom_sheets/playlist_creation_sheet.dart';
import '../clippers/squircle_clipper.dart';
import '../controllers/music_controller.dart';
import '../model/playlist.dart';
import '../model/song.dart';
import '../services/playlist_service.dart';
import '../widgets/album_artwork.dart';

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
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE695),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _handle(),
                  const SizedBox(height: 15),
                  _title(),
                  const SizedBox(height: 12),
                  _buildLoadingView(),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE695),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _handle(),
                  const SizedBox(height: 15),
                  _title(),
                  const SizedBox(height: 12),
                  _buildErrorView(),
                ],
              ),
            );
          }

          final songs = snapshot.data!;

          if (songs.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE695),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _handle(),
                  const SizedBox(height: 15),
                  _title(),
                  const SizedBox(height: 12),
                  _buildEmptyView(),
                ],
              ),
            );
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
              const SizedBox(height: 20),
              _handle(),
              const SizedBox(height: 15),
              _title(),
              const SizedBox(height: 12),
              Expanded(
                child: playlists.isEmpty
                    ? _empty(context)
                    : ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];

                    return _buildPlaylistTile(
                      playlist: playlist,
                      song: widget.song,
                      onTap: () {
                        final service = playlistService;

                        final isInPlaylist = service.containsSong(
                          playlist.id,
                          widget.song.filePath,
                        );

                        if (isInPlaylist) {
                          service.removeSongFromPlaylist(
                            playlist.id,
                            widget.song.filePath,
                          );
                        } else {
                          service.addSongToPlaylist(
                            playlist.id,
                            widget.song,
                          );
                        }

                        setState(() {}); // force UI refresh
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

  Widget _buildPlaylistTile({
    required Playlist playlist,
    required VoidCallback onTap,
    required Song song
  }) {
    return Consumer<MusicController>(
        builder: (context, controller, _) {

          final isInPlaylist =
                  playlistService.containsSong(
                    playlist.id,
                    song.filePath,
                  );

          final songs = playlistService.getSongs(playlist.id);

          final songCount = songs.length;
          Song firstSong = Song(filePath: '', title: '', fileName: '');
          if(songs.isNotEmpty){
            firstSong = Song(filePath: songs[0].filePath, title: songs[0].title, fileName: songs[0].title);
          }

          return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Color(0xFF342E1B).withValues(alpha: 0.2),
            focusColor: Color(0xFF342E1B).withValues(alpha: 0.2),
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: Color(0xFFFFE695)
              ),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    ClipPath(
                      clipper: SquircleClipper(10),
                      child: Container(
                        width: 55,
                        height: 55,
                        color: Color(0xFF342E1B),
                        child: AlbumArtwork(
                          song: firstSong,
                          size: 50,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: const Color(0xFF342E1B),
                        ),
                      ),
                    ),

                    SizedBox(width: 15,),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF342E1B),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            '$songCount songs',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF342E1B).withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15,),
                    Icon(
                      isInPlaylist ? Icons.check_circle : Icons.add_circle_outline_sharp,
                      color: Color(0xFF342E1B),
                      size: 25,
                    ),
                    SizedBox(width: 6,),
                  ],
                ),
              ),
            ),
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
          Text(
            'Scanning for Playlists...',
            style: GoogleFonts.rubik(
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
              Icons.playlist_play_sharp,
              size: 64,
              color: Color(0xFF342E1B).withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Playlist found',
              style: GoogleFonts.rubik(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF342E1B),
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
                        'Add Playlist',
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
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Row(
      children: [
        Text(
          'Add to playlist',
          style: GoogleFonts.rubik(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF342E1B),
          ),
        ),
        const Spacer(),
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => PlaylistCreationSheet.show(context),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: Color(0xFF342E1B),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10,),
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.chevron_down,
                  size: 24,
                  color: Color(0xFF342E1B),
                ),
              ),
            ),
          ),
        )
      ],
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
