import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'package:path/path.dart' as p;

class MusicPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}
class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _player = AudioPlayer();
  Metadata _metadata = Metadata();

  Duration _totalDuration = Duration.zero; // Total duration of the song
  Duration _currentPosition = Duration.zero; // Current playback position

  @override
  void initState() {
    super.initState();

    // Listen to duration changes
    _player.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Listen to position changes
    _player.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text('Player'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.featured_play_list),
              title: Text('Playlist'),
              onTap: () {
                Navigator.popAndPushNamed(context, '/playlist'); // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.popAndPushNamed(context, '/settings'); // Navigate to Settings
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.popAndPushNamed(context, '/about'); // Navigate to About
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Container(
            margin: EdgeInsets.all(20),
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _metadata.albumArt != null ? DecorationImage(
                image: MemoryImage(_metadata.albumArt!),
                fit: BoxFit.cover,
              )
                  : DecorationImage(
                image: AssetImage('assets/album_art.png'), // 기본 이미지
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Song Title
          Text(
            _metadata.trackName == null ? 'Empty' : _metadata.trackName!,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Artist Name
          Text(
            _metadata.albumArtistName == null ? 'Empty' : _metadata.albumArtistName!,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 30),
          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, size: 40),
                onPressed: () {
                  // Handle previous song action
                },
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, size: 60),
                onPressed: () async {
                  if(this._metadata.filePath != null) {
                    _player.play(DeviceFileSource(this._metadata.filePath!));
                  }
                  // Handle play action
                  _player.onDurationChanged.listen((Duration d) {
                    print('Max duration: $d');
                  });
                  _player.onPositionChanged.listen((Duration  p) {
                    print('Current position: $p');
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.stop, size: 60),
                onPressed: () async {
                  this._player.stop();
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, size: 40),
                onPressed: () {
                  // Handle next song action
                },
              ),
              IconButton(
                icon: Icon(Icons.file_open, size: 40),
                onPressed: () {
                  pickFile();
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          // Progress Bar
          Slider(
            value: _currentPosition.inSeconds.toDouble(),
            min: 0,
            max: _totalDuration.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _player.seek(Duration(seconds: value.toInt()));
              });
            },
            activeColor: Colors.blue,
            inactiveColor: Colors.grey,
          ),
          SizedBox(height: 10),
          // Current Position and Total Duration
          Text(
            '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      // Access the selected file
      String? filePath = result.files.single.path;
      var metadata = await getMp3Metadata(filePath!);
      if(metadata != null) {
        setState(() {
          _metadata = metadata;
        });
        await _player.play(DeviceFileSource(filePath));
      }
      print("Selected file path: $filePath");
    } else {
      // User canceled the picker
      print("File selection canceled");
    }
  }

  Future<Metadata?> getMp3Metadata(String filePath) async {
    try {
      final File file = File(filePath);
      final metadata = await MetadataRetriever.fromFile(file);

      print("Title: ${metadata.trackName}");
      print("Artist: ${metadata.albumArtistName}");
      print("Album: ${metadata.albumName}");
      print("Genre: ${metadata.genre}");
      print("Duration: ${metadata.trackDuration} ms");

      if (metadata.albumArt != null) {
        print("Album Art is available");
      } else {
        print("No Album Art");
      }

      return metadata;
    } catch (e) {
      print("Error reading metadata: $e");
    }

    return null;
  }


  // Helper function to format Duration to mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}