import 'package:flutter/material.dart';
import 'package:music_player/play_list.dart';
import 'package:music_player/settings_screen.dart';
import 'about_screen.dart';
import 'music_player.dart';

void main() {
  runApp(MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MusicPlayerScreen(),
      routes: {
        '/playlist': (context) => PlayList(),
        '/settings': (context) => SettingsScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}