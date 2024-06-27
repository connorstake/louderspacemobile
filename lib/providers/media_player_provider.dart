import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MediaPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentPosition = Duration.zero;
  Duration _songDuration = Duration.zero;
  bool _isPlaying = false;
  String? _currentSongUrl;
  List<String> _playlist = [];
  int _currentIndex = 0;

  MediaPlayerProvider() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.PLAYING;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _songDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onAudioPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerCompletion.listen((event) {
      playNextSong();
    });
  }

  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get songDuration => _songDuration;
  String? get currentSongUrl => _currentSongUrl;

  set playlist(List<String> songs) {
    _playlist = songs;
    _currentIndex = 0;
    _currentSongUrl = _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
    notifyListeners();
  }

  Future<void> playSong(String url) async {
    _currentSongUrl = url;
    int result = await _audioPlayer.play(url);
    if (result == 1) {
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> pauseSong() async {
    int result = await _audioPlayer.pause();
    if (result == 1) {
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> resumeSong() async {
    int result = await _audioPlayer.resume();
    if (result == 1) {
      _isPlaying = true;
      notifyListeners();
    }
  }

  void playNextSong() {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
      playSong(_playlist[_currentIndex]);
    }
  }

  void playPreviousSong() {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      playSong(_playlist[_currentIndex]);
    }
  }

  void seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
