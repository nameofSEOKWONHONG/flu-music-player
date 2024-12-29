import 'package:flutter/material.dart';
import 'package:music_player/playlist_screen.dart';
import 'package:music_player/settings_screen.dart';
import 'package:music_player/viewmodel/music_player_viewmodel.dart';
import 'package:provider/provider.dart';
import 'about_screen.dart';
import 'music_player.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MusicPlayerViewModel(),
      child: const MusicPlayerApp(),
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MusicPlayerScreen(),
      routes: {
        '/settings': (context) => SettingsScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}