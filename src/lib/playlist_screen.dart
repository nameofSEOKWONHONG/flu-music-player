
import 'package:flutter/material.dart';
import 'package:music_player/utils/extionsions.dart';
import 'package:music_player/viewmodel/music_player_viewmodel.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist')),
      body: Consumer<MusicPlayerViewModel>(
        builder: (context, viewModel, child) {
          final playlist = viewModel.playlist;

          if (playlist.isEmpty) {
            return const Center(child: Text('No files added to playlist'));
          }

          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final file = playlist[index];
              return ListTile(
                leading: file.albumArt != null
                    ? Image.memory(file.albumArt!, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.music_note, size: 50),
                title: file.trackName.isNullOrEmpty == false
                    ? Text(file.trackName!)
                    : Text(file.filePath!.split('/').last),
                onTap: () {
                  // 선택한 트랙 재생
                  viewModel.playSelectedFile(index);
                  Navigator.pop(context); // 재생 후 플레이어 화면으로 돌아가기
                },
              );
            },
          );
        },
      ),
    );
  }
}