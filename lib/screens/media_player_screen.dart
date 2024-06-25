import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:louderspacemobile/models/song.dart';

import '../providers/song_provider.dart';

class MediaPlayerScreen extends StatefulWidget {
  final int stationId;

  const MediaPlayerScreen({Key? key, required this.stationId}) : super(key: key);

  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  late AudioPlayer _audioPlayer;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _fetchSongsAndPlay();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchSongsAndPlay() async {
    await Provider.of<SongProvider>(context, listen: false).fetchSongsForStation(widget.stationId);
    _playSong();
  }

  void _playSong() async {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    if (songProvider.songs.isNotEmpty && _currentSongIndex < songProvider.songs.length) {
      Song currentSong = songProvider.songs[_currentSongIndex];
      await _audioPlayer.setUrl('https://cdn1.suno.ai/${currentSong.sunoId}.mp3');
      _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _skipToNext();
        }
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _skipToNext() {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    if (_currentSongIndex < songProvider.songs.length - 1) {
      setState(() {
        _currentSongIndex++;
      });
      _playSong();
    }
  }

  void _skipToPrevious() {
    if (_currentSongIndex > 0) {
      setState(() {
        _currentSongIndex--;
      });
      _playSong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    if (songProvider.loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Media Player')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(songProvider.songs.isNotEmpty
            ? songProvider.songs[_currentSongIndex].title
            : 'Media Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (songProvider.songs.isNotEmpty)
              Column(
                children: [
                  Text(songProvider.songs[_currentSongIndex].artist,
                      style: TextStyle(fontSize: 24)),
                  Text(songProvider.songs[_currentSongIndex].title,
                      style: TextStyle(fontSize: 20)),
                ],
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: _skipToPrevious,
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: _skipToNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
