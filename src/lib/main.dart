import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MusicPlayerApp());
}

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
  final player = AudioPlayer();
  Duration _totalDuration = Duration.zero; // Total duration of the song
  Duration _currentPosition = Duration.zero; // Current playback position

  @override
  void initState() {
    super.initState();

    // Listen to duration changes
    player.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // Listen to position changes
    player.onPositionChanged.listen((Duration position) {
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
              image: DecorationImage(
                image: AssetImage('assets/album_art.png'), // Add your image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Song Title
          Text(
            'Song Title',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Artist Name
          Text(
            'Artist Name',
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
                  // Handle play action
                  await player.play(UrlSource('https://nameofseokwonhong.github.io/mp3/Adam_MacDougall.mp3'));
                  player.onDurationChanged.listen((Duration d) {
                    print('Max duration: $d');
                  });
                  player.onPositionChanged.listen((Duration  p) {
                    print('Current position: $p');
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, size: 40),
                onPressed: () {
                  // Handle next song action
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
                player.seek(Duration(seconds: value.toInt()));
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

  // Helper function to format Duration to mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}