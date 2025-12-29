import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavy_muic_player/widgets/mini_player.dart';

import '../../bottom_sheets/music_player_sheet.dart';
import '../../clippers/squircle_clipper.dart';
import '../../widgets/continous_wave.dart';

class PlaylistViewingPage extends StatefulWidget {
  const PlaylistViewingPage({super.key});

  @override
  State<PlaylistViewingPage> createState() => _PlaylistViewingPageState();
}

class _PlaylistViewingPageState extends State<PlaylistViewingPage> with TickerProviderStateMixin {
  int? _currentlyPlaying;
  late AnimationController _vinylController;
  late ScrollController _scrollController;
  bool isLiked = false;

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
    return Scaffold(
      backgroundColor: const Color(0xFF342E1B),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              _buildSliverHeader(),
              _buildSliverSongList(),
            ],
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

          // Pinned FAB
          Positioned(
            top: 55,
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
                          setState(() {
                            _vinylController.repeat();
                            MusicPlayerSheet.show(context);
                          });
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
  

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 275.0,
      collapsedHeight: 60,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFFFE695),
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCircularButton(CupertinoIcons.back, () => Navigator.pop(context)),
            SizedBox(width: 20,),
            const Text(
              'EVOL • FUTURE',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Color(0xFF342E1B),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double top = constraints.biggest.height;
            double collapsePercent = ((top - kToolbarHeight) / (250.0 - kToolbarHeight)).clamp(0.0, 1.0);

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
                      child: _buildAlbumCard(),
                    ),
                  ),
                ),
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

  Widget _buildSliverSongList() {
    final songs = [
      {'title': 'Ain\'t No Time', 'artist': 'Future'},
      {'title': 'In Her Mouth', 'artist': 'Future'},
      {'title': 'Low Life', 'artist': 'Future • The Weeknd'},
      {'title': 'Xanny Family', 'artist': 'Future'},
      {'title': 'Lil Haiti Baby', 'artist': 'Future'},
      {'title': 'Photo Copied', 'artist': 'Future'},
      {'title': 'Seven Rings', 'artist': 'Future'},
      {'title': 'Lie To Me', 'artist': 'Future'},
      {'title': 'Lie To Me', 'artist': 'Future'},
      {'title': 'Lie To Me', 'artist': 'Future'},
      {'title': 'Lie To Me', 'artist': 'Future'},
      {'title': 'Lie To Me', 'artist': 'Future'},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final song = songs[index];
          final isPlaying = _currentlyPlaying == index;

          return _buildSongTile(
            title: song['title']!,
            artist: song['artist']!,
            isPlaying: isPlaying,
            onTap: () {
              setState(() {
                _currentlyPlaying = isPlaying ? null : index;
                isPlaying
                    ? _vinylController.stop()
                    : _vinylController.repeat();
                MusicPlayerSheet.show(context);
              });
            },
          );
        },
        childCount: songs.length,
      ),
    );
  }


  Widget _buildAlbumCard() {
    return Transform.rotate(
      angle: 0.02,
      child: Container(
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
                    child: RotationTransition(
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
    required String title,
    required String artist,
    required bool isPlaying,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                  color: Color(0xFFFFE695),
                ),
              ),

              SizedBox(width: 15,),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.rubik(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: isPlaying ? Color(0xFFFBBF24) : Colors.white,
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    artist,
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isPlaying ? Color(0xFFFBBF24) : Colors.white,
                    ),
                  ),
                ],
              ),

              Spacer(),

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
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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

