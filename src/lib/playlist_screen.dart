
import 'package:flutter/material.dart';
import 'package:music_player/viewmodel/music_player_viewmodel.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Playlist')),
      body: Consumer<MusicPlayerViewModel>(
        builder: (context, viewModel, child) {
          final playlist = viewModel.playlist;

          if (playlist.isEmpty) {
            return Center(child: Text('No files added to playlist'));
          }

          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final file = playlist[index];
              return ListTile(
                leading: Icon(Icons.music_note),
                title: Text(file.path.split('/').last), // 파일 이름 표시
                onTap: () {
                  // 선택한 트랙 재생
                  viewModel.playSelectedFile(file.path);
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