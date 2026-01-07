import 'package:wavy_muic_player/model/song.dart';

class Artist {
  final String name;
  final List<Song> songs;

  Artist({
    required this.name,
    required this.songs,
  });
}
