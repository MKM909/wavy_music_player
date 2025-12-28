import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/items_layout/playlist_item_layout.dart';

import '../clippers/squircle_clipper.dart';
import '../controllers/music_controller.dart';
import '../model/music_tabs.dart';
import '../services/music_library_service.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {

  List<MusicTabs> musicTabs = [
    MusicTabs(title: 'All'),
    MusicTabs(title: 'Playlists',),
    MusicTabs(title: 'Liked Songs',),
    MusicTabs(title: 'Downloaded Songs',),
    MusicTabs(title: 'Albums',),
    MusicTabs(title: 'Artists',),
  ];

  List<Widget> tabs = [
    AllMusic(),
    Container(),
    Container(),
    DownloadedSongs(),
    Container(),
    Container(),
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 👇 Called when nav bar is tapped
  void _onTabBarTapped(int index) {
    setState(() {
      _currentPage = index;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE695),
      body: Padding(
        padding: const EdgeInsets.only(top: 40,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: _buildheader(),
            ),
            SizedBox(height: 20,),
            _buildTabs(),
            SizedBox(height: 20,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: IndexedStack(
                  index: _currentPage,
                  children: tabs,
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget _buildheader(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Music',
          style: GoogleFonts.rubik(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: Color(0xFF342E1B),
          ),
        ),
        Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){},
                splashColor: Colors.brown.withValues(alpha: 0.2),
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                child: Container(
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF342E1B).withValues(alpha: 0.35),
                  ),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            )
          ),
        )

      ],
    );

  }

  Widget _buildTabs(){
    return SizedBox(
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20, right: 20),
        itemCount: musicTabs.length,
        itemBuilder: (context, index){
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.clamp),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (){
                            _onTabBarTapped(index);
                          },
                          splashColor: Colors.brown.withValues(alpha: 0.2),
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            constraints: BoxConstraints(minWidth: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: index == _currentPage ? Color(0xFF342E1B) : Color(0xFF342E1B).withValues(alpha: 0.35),
                            ),
                            child: Center(
                              child: Text(
                                musicTabs[index].title,
                                style: GoogleFonts.rubik(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: index == _currentPage ? Colors.white : Color(0xFF342E1B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

class AllMusic extends StatefulWidget {
  const AllMusic({super.key});

  @override
  State<AllMusic> createState() => _AllMusicState();
}

class _AllMusicState extends State<AllMusic> with AutomaticKeepAliveClientMixin<AllMusic> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 65),
        itemCount: 10,
        itemBuilder: (context, index){
          return PlaylistItemLayout();
        }
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class DownloadedSongs extends StatefulWidget {
  const DownloadedSongs({super.key});

  @override
  State<DownloadedSongs> createState() => _DownloadedSongsState();
}

class _DownloadedSongsState extends State<DownloadedSongs> {
  final MusicLibraryService _musicService = MusicLibraryService();
  List<Song> songs = [];
  int? _currentlyPlaying;
  bool isLoading = false;
  bool isScanning = false;
  int scanProgress = 0;
  int scanTotal = 0;
  String? errorMessage;

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

  Future<void> _loadMusicFull({bool forceRefresh = false}) async {
    setState(() {
      isLoading = true;
      isScanning = true;
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
    : _buildSongList();
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
          if (scanTotal > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Checking $scanProgress of $scanTotal locations',
                style: TextStyle(
                  fontSize: 14,
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
              style: const TextStyle(
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
              child: const Text(
                'Try Again',
                style: TextStyle(color: Color(0xFFFFE695)),
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
      padding: EdgeInsets.zero,
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
          return InkWell(
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
            margin: EdgeInsets.only(bottom: 10, top: 10),
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
                      child: Icon(
                        Icons.music_note_rounded,
                        color: isActuallyPlaying
                            ? const Color(0xFFFFE695)
                            : Colors.white.withOpacity(0.5),
                        size: 24,
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
                            width: 50,
                            height: 50,
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
        );
      }
    );
  }

}