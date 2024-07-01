import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
    _stationId = stationId;
    notifyListeners();
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
