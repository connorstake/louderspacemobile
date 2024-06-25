import 'package:flutter/material.dart';
import 'package:louderspacemobile/models/song.dart';
import 'package:louderspacemobile/services/song_service.dart';

class SongProvider with ChangeNotifier {
  final SongService _songService;
  List<Song> _songs = [];
  bool _loading = false;

  SongProvider(this._songService);

  List<Song> get songs => _songs;
  bool get loading => _loading;

  Future<void> fetchSongsForStation(int stationId) async {
    _loading = true;
    notifyListeners();

    try {
      _songs = await _songService.getSongsForStation(stationId);
    } catch (error) {
      print('Error fetching songs: $error');
      _songs = [];
    }

    _loading = false;
    notifyListeners();
  }
}
