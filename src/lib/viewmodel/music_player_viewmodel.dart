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


  MusicPlayerViewModel() {
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
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        final metadata = await _getMp3Metadata(filePath);
        _metadata = metadata;
        File file = File(result.files.single.path!); // 선택된 파일 경로로 File 생성
        addFileToPlaylist(file);
        if (metadata != null) {
          await play();
        }
      }
    }
  }

  Future<void> play() async {
    if (_metadata?.filePath != null) {
      if(_metadata?.trackName.isNullOrEmpty == true) {
        _trackName2 = path.basenameWithoutExtension(_metadata!.filePath!);
      }
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

  List<File> _playlist = [];
  List<File> get playlist => _playlist;

  void addFileToPlaylist(File file) {
    _playlist.add(file);
    notifyListeners();
  }

  Future<void> playSelectedFile(String path) async {
    _isPlaying = true;
    final metadata = await _getMp3Metadata(path);
    _metadata = metadata;
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