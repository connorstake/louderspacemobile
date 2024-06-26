import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/feedback_service.dart';
import '../services/song_service.dart';

class SongProvider with ChangeNotifier {
  final SongService _songService;
  final FeedbackService _feedbackService;
  List<Song> _songs = [];
  int _currentSongIndex = 0;
  bool _loading = false;

  SongProvider(this._songService, this._feedbackService);

  List<Song> get songs => _songs;
  Song? get currentSong => _songs.isNotEmpty ? _songs[_currentSongIndex] : null;
  bool get loading => _loading;

  String get currentSongUrl => 'https://cdn1.suno.ai/${currentSong?.sunoId}.mp3';

  Future<void> fetchSongsForStation(int stationId, int userId) async {
    _loading = true;
    notifyListeners();
    try {
      _songs = await _songService.getSongsForStation(stationId, userId);
      _currentSongIndex = 0;
      notifyListeners();
    } catch (error) {
      print('Error fetching songs: $error');
    }
    _loading = false;
    notifyListeners();
  }

  void playNextSong() {
    if (_songs.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex + 1) % _songs.length;
      notifyListeners();
    }
  }

  void playPreviousSong() {
    if (_songs.isNotEmpty) {
      _currentSongIndex = (_currentSongIndex - 1 + _songs.length) % _songs.length;
      notifyListeners();
    }
  }

  Future<void> toggleLikeSong(int userId, Song song) async {
    print('FeedbackService: ${_feedbackService}');
    try {
      if (song.liked) {
        await _feedbackService.deleteFeedback(userId, song.id);
      } else {
        await _feedbackService.createFeedback(userId, song.id, true);
      }
      song.liked = !song.liked;
      notifyListeners();
    } catch (error) {
      print('Error liking/unliking song: $error');
    }
  }
}
