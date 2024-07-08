import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'song_provider.dart';

class MediaPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _songDuration = Duration.zero;
  bool _isPlaying = false;
  String? _currentSongUrl;
  List<String> _playlist = [];
  int _currentSongIndex = 0;
  SongProvider? _songProvider;
  int? _stationId;

  MediaPlayerProvider() {
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _songDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      if (playerState.processingState == ProcessingState.completed) {
        playNextSong();
      }
      notifyListeners();
    });
  }

  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get songDuration => _songDuration;
  String? get currentSongUrl => _currentSongUrl;
  List<String> get playlist => _playlist;
  int? get stationId => _stationId;

  set playlist(List<String> urls) {
    _playlist = urls;
    _currentSongIndex = 0;
    if (_playlist.isNotEmpty) {
      playSong(_playlist[_currentSongIndex]);
    }
    notifyListeners();
  }

  void setSongProvider(SongProvider songProvider) {
    _songProvider = songProvider;
  }

  Future<void> playSong(String url) async {
    _currentSongUrl = url;
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          album: "Album",
          title: _songProvider?.currentSong?.title ?? "Title",
          artist: _songProvider?.currentSong?.artist ?? "Artist",
          artUri: Uri.parse("https://example.com/album.jpg"),
        ),
      ));
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  Future<void> pauseSong() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeSong() async {
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  void playNextSong() {
    if (_playlist.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex + 1) % _playlist.length;
      playSong(_playlist[_currentSongIndex]);
      _songProvider?.playNextSong();
    }
  }

  void playPreviousSong() {
    if (_playlist.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex - 1 + _playlist.length) % _playlist.length;
      playSong(_playlist[_currentSongIndex]);
      _songProvider?.playPreviousSong();
    }
  }

  void seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  void setStationId(int stationId) {
    if (_stationId != stationId) {
      _stationId = stationId;
      notifyListeners();
    }
  }

  bool isPlayingStation(int stationId) {
    return _stationId == stationId;
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
