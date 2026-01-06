import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wavy_muic_player/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/services/liked_song_service.dart';
import 'package:wavy_muic_player/services/object_box_service.dart';
import 'package:wavy_muic_player/services/playlist_service.dart';
import 'controllers/music_controller.dart';
import 'handlers/wavy_audio_handler.dart';

late final WavyAudioHandler audioHandler;
late final MusicController musicController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  final objectBox = ObjectBoxService();

  if (!objectBox.isInitialized) {
    try {
      await objectBox.init();
      debugPrint('MYAPP: init -> ✅ ObjectBox initialized successfully');
    } catch (e) {
      debugPrint('MYAPP: init -> ❌ ObjectBox init error: $e');
    }
  }

  if (objectBox.isInitialized) {
    try {
      LikedSongsService().init(objectBox.store);
      PlaylistService().init(objectBox.store);
      debugPrint('✅ Services initialized');
    } catch (e) {
      debugPrint('MYAPP: init -> ❌ Service init error: $e');
    }
  }

  musicController = MusicController();

  // 🔥 THIS WAS MISSING
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: musicController, // ✅ same instance
      child: MaterialApp(
        title: 'Wavy Music Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          useMaterial3: true,
        ),
        home: const Home(),
      ),
    );
  }
}
