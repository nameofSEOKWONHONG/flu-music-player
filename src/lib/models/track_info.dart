import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class TrackInfo {
  final Metadata metadata;
  final bool isPlaying;

  TrackInfo(this.metadata, this.isPlaying);
}