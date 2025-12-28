import 'dart:typed_data';
import 'package:objectbox/objectbox.dart';

@Entity()
class LikedSong {
  int id;

  String filePath;
  String title;
  String artist;
  Uint8List? artwork;

  LikedSong({
    this.id = 0,
    required this.filePath,
    required this.title,
    required this.artist,
    this.artwork,
  });
}
