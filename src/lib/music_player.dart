import 'package:flutter/material.dart';
import 'package:music_player/playlist_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodel/music_player_viewmodel.dart';

class MusicPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('Now Playing')),
        body: Consumer<MusicPlayerViewModel>(
          builder: (context, viewModel, child) {
            final metadata = viewModel.metadata;
            final position = viewModel.currentPosition;
            final duration = viewModel.totalDuration;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 기존 코드 유지
                Container(
                  margin: EdgeInsets.all(20),
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: metadata?.albumArt != null
                        ? DecorationImage(
                      image: MemoryImage(metadata!.albumArt!),
                      fit: BoxFit.cover,
                    )
                        : const DecorationImage(
                      image: AssetImage('assets/album_art.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  viewModel.trackName2 ?? 'Empty',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  metadata?.albumArtistName ?? 'Empty',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 40),
                      onPressed: () => viewModel.previous(),
                    ),
                    IconButton(
                      icon: Icon(
                        viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 60,
                      ),
                      onPressed: () {
                        if (viewModel.isPlaying) {
                          viewModel.pause();
                        } else {
                          viewModel.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop, size: 60),
                      onPressed: () => viewModel.stop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 40),
                      onPressed: () => viewModel.next(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_open, size: 40),
                      onPressed: () => viewModel.pickFile(),
                    ),
                  ],
                ),
                Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) =>
                      viewModel.seek(Duration(seconds: value.toInt())),
                ),
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlaylistScreen()),
            );
          },
          child: const Icon(Icons.queue_music),
        ),
      );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}

