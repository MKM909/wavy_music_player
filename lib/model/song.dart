import 'dart:typed_data';

class Song {
  final String filePath;
  final String title;
  final String fileName;
  final int? fileSize;
  Uint8List? albumArt;

  final String album;
  final String artist;

  Song({
    required this.filePath,
    required this.title,
    required this.fileName,
    this.fileSize,
    this.albumArt,
    this.album = 'Unknown Album',
    this.artist = 'Unknown Artist',
  });


  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'title': title,
    'fileName': fileName,
    'fileSize': fileSize,
    'album': album,
    'artist': artist,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    filePath: json['filePath'],
    title: json['title'],
    fileName: json['fileName'],
    fileSize: json['fileSize'],
    album: json['album'],
    artist: json['artist'],
  );


}
