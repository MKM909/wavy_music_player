import 'package:flutter/material.dart';
import 'package:wavy_muic_player/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:wavy_muic_player/services/liked_song_service.dart';
import 'package:wavy_muic_player/services/object_box_service.dart';
import 'controllers/music_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObjectBoxService().init(); // 🔑 only store open
  await LikedSongsService().init();    // uses same store

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicController(),
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