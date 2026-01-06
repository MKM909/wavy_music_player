import 'package:wavy_muic_player/model/song.dart';

class Album {
  final String name;
  final String artist;
  final List<Song> songs;

  Album({
    required this.name,
    required this.artist,
    required this.songs,
  });
}
