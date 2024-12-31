import 'package:flutter/material.dart';
import 'package:music_player/playlist_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodel/music_player_viewmodel.dart';
import 'about_screen.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(title: const Text('Solo Music Player')),
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
                  margin: const EdgeInsets.all(20),
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
                        size: 40,
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
                      icon: const Icon(Icons.stop, size: 40),
                      onPressed: () => viewModel.stop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 40),
                      onPressed: () => viewModel.next(),
                    ),
                    if(viewModel.repeatMode == 0)
                    IconButton(
                      icon:
                      const Icon(
                          Icons.repeat
                          , size: 40),
                      onPressed: () => viewModel.setRepeatMode(),
                    ),
                    if(viewModel.repeatMode == 1)
                      IconButton(
                        icon:
                        const Icon(
                            Icons.repeat_one
                            , size: 40),
                        onPressed: () => viewModel.setRepeatMode(),
                      ),
                    if(viewModel.repeatMode == 2)
                      IconButton(
                        icon:
                        const Icon(
                            Icons.repeat_on
                            , size: 40),
                        onPressed: () => viewModel.setRepeatMode(),
                      ),
                    IconButton(
                      icon: const Icon(
                          Icons.file_open_rounded, size: 30),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop
      );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Home selected')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings selected')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}