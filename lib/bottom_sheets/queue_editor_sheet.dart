import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../clippers/squircle_clipper.dart';
import '../controllers/music_controller.dart';
import '../model/song.dart';
import '../widgets/album_artwork.dart';

class QueueEditorSheet extends StatelessWidget {
  const QueueEditorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return  Consumer<MusicController>(
        builder: (context, controller, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE695),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _handle(),
              _header(context,controller),
              SizedBox(height: 1,),
              _buildCurrentSongTile(
                  song: controller.currentSong!,
                  onTap: () {
                    controller.togglePlayPause();
                  },
                  musicController: controller,
              ),
              Expanded(
                  child: Stack(
                children: [
                  const _QueueList(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [

                            const Color(0xFFFFE695).withValues(alpha: 0.01),
                            const Color(0xFFFFE695).withValues(alpha: 0.1),
                            const Color(0xFFFFE695).withValues(alpha: 0.5),
                            const Color(0xFFFFE695),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              _buildBottom(musicController: controller),
            ],
          ),
        );
      }
    );
  }

  Widget _buildCurrentSongTile({
    required Song song,
    required VoidCallback onTap,
    required MusicController musicController,
  }) {
    final isCurrentSong = musicController.currentSong?.filePath == song.filePath;
    final isActuallyPlaying = isCurrentSong && musicController.isPlaying;
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
                      song: song,
                      size: 55,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: const Color(0xFF342E1B),
                    ),
                  ),
                ),

                SizedBox(width: 15,),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '...${song.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
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
                          color: Colors.orange.withValues(alpha: 0.5),
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
                        onTap: onTap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF342E1B).withValues(alpha: 0.5),
                          ),
                          child: Icon(
                            isActuallyPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _handle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Color(0xFF342E1B),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, MusicController musicController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Queue',
                  style: GoogleFonts.rubik(
                    color: const Color(0xFF342E1B),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  'Currently : ${musicController.currentSong!.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    color: const Color(0xFF342E1B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30,),
        ],
      ),
    );
  }

  Widget _buildBottom({required MusicController musicController}){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 25, right: 25),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 70,
              width: 150,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF342E1B).withValues(alpha: 0.95),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Shuffle',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Container(
              height: 70,
              width: 150,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF342E1B).withValues(alpha: 0.95),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Repeat',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Container(
              height: 70,
              width: 150,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF342E1B).withValues(alpha: 0.95),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Timer',
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _QueueList extends StatelessWidget {
  const _QueueList();

  int realIndex(int uiIndex, int currentIndex, int queueLength) {
    return (currentIndex + uiIndex) % queueLength;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, controller, _) {
        final queue = controller.queue;
        final currentIndex = controller.currentIndex;

        if (queue.isEmpty) {
          return const Center(
            child: Text('Queue is empty', style: TextStyle(color: Colors.white54)),
          );
        }

        // 🔥 Rotated view starting from current song
        final rotatedQueue = [
          ...queue.sublist(currentIndex),
          ...queue.sublist(0, currentIndex),
        ];

        return ReorderableListView.builder(
          itemCount: rotatedQueue.length,
          onReorder: (oldUi, newUi) {
            if (oldUi < newUi) newUi--;

            final oldReal = realIndex(oldUi, currentIndex, queue.length);
            final newReal = realIndex(newUi, currentIndex, queue.length);

            controller.reorderQueue(oldReal, newReal);
          },
          padding: const EdgeInsets.only(bottom: 24),
          itemBuilder: (context, uiIndex) {
            final song = rotatedQueue[uiIndex];
            final realIdx = realIndex(uiIndex, currentIndex, queue.length);
            final isCurrent = realIdx == currentIndex;

            return Dismissible(
              key: ValueKey(song.filePath),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                controller.removeFromQueue(realIdx);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.redAccent,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: _buildSongTile(
                  song: song,
                  onTap: () {
                    if(controller.currentSong == song){
                      controller.togglePlayPause();
                    }else {
                      controller.playSong(
                        song,
                        newQueue: controller.queue,
                        startIndex: realIdx,
                      );
                    }
                  },
                  musicController: controller,
                  isCurrent: isCurrent
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSongTile({
    required Song song,
    required VoidCallback onTap,
    required MusicController musicController,
    required bool isCurrent
  }) {
    return isCurrent ? Container() : Material(
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
                      song: song,
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
                        song.title,
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
                        song.artist,
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
                  Icons.menu,
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

}

