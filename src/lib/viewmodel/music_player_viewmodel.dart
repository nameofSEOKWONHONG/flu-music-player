import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class MusicPlayerViewModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Metadata? _metadata;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false; // 재생 상태 추가
  String? _trackName2;

  Metadata? get metadata => _metadata;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _isPlaying;
  String? get trackName2 => _trackName2;

  final List<File> _playlist = [];
  List<File> get playlist => _playlist;
  int _currentIndex = 0;

  MusicPlayerViewModel() {
    _player.onPlayerComplete.listen((event) {
      next();
    });
    _player.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners(); // 상태 변경 알림
    });

    _player.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners(); // 상태 변경 알림
    });

    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners(); // 재생 상태 변경 알림
    });
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple:true);

    if (result != null) {
      List<PlatformFile> files = result.files;
      List<File> playlistFiles = [];
      for(var file in files) {
        String? filePath = file.path;
        if (filePath != null) {
          File file = File(filePath); // 선택된 파일 경로로 File 생성
          playlistFiles.add(file);
        }
      }

      if(playlistFiles.isNotEmpty) {
        addFileToPlaylist(playlistFiles);
        final metadata = await _getMp3Metadata(playlistFiles.first.path);
        _metadata = metadata;
        if (metadata != null) {
          await play();
        }
      }
    }
  }

  Future<void> play() async {
    if (_metadata?.filePath != null) {
      _trackName2 = _metadata?.trackName;
      if(_trackName2.isNullOrEmpty == true) {
        _trackName2 = path.basenameWithoutExtension(_metadata!.filePath!);
      }
      _isPlaying = true;
      await _player.play(DeviceFileSource(_metadata!.filePath!));
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentPosition = Duration.zero;
    notifyListeners(); // 상태 변경 알림
  }

  Future<void> next() async {
    if(_playlist.isEmpty) return;

    _currentIndex+=1;
    if(_currentIndex > _playlist.length - 1) _currentIndex = 0;
    await playSelectedFile(_currentIndex);
  }

  Future<void> previous() async {
    if(_playlist.isEmpty) return;

    _currentIndex-=1;
    if(_currentIndex < 0) _currentIndex = _playlist.length - 1;
    await playSelectedFile(_currentIndex);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<Metadata?> _getMp3Metadata(String filePath) async {
    try {
      final file = File(filePath);
      final metadata = await MetadataRetriever.fromFile(file);
      return metadata;
    } catch (e) {
      print("Error retrieving metadata: $e");
      return null;
    }
  }

  void addFileToPlaylist(List<File> files) {
    for(var file in files) {
      _playlist.add(file);
    }
    notifyListeners();
  }

  Future<void> playSelectedFile(int index) async {
    _currentIndex = index;
    var file = _playlist[index];
    _metadata = await _getMp3Metadata(file.path);
    if (metadata != null) {
      await play();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}