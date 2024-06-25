import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/station.dart';
import '../models/song.dart';
import '../services/song_service.dart';

class MediaPlayerScreen extends StatefulWidget {
  final Station station;

  MediaPlayerScreen({required this.station});

  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _songs = [];
  Song? _currentSong;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    try {
      final songs = await Provider.of<SongService>(context, listen: false).getSongsForStation(widget.station.id);
      setState(() {
        _songs = songs;
        if (_songs.isNotEmpty) {
          _currentSong = _songs[0];
        }
      });
    } catch (e) {
      print('Error fetching songs: $e');
    }
  }

  void _playSong(Song song) async {
    await _audioPlayer.play('https://cdn1.suno.ai/${song.sunoId}.mp3');
    setState(() {
      _currentSong = song;
      _isPlaying = true;
    });
  }

  void _pauseSong() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _skipSong() {
    if (_songs.isNotEmpty) {
      final currentIndex = _songs.indexOf(_currentSong!);
      final nextIndex = (currentIndex + 1) % _songs.length;
      _playSong(_songs[nextIndex]);
    }
  }

  void _rewindSong() {
    if (_songs.isNotEmpty) {
      final currentIndex = _songs.indexOf(_currentSong!);
      final previousIndex = (currentIndex - 1 + _songs.length) % _songs.length;
      _playSong(_songs[previousIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
      ),
      body: _currentSong == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Text(
            _currentSong!.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(_currentSong!.artist),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous),
                onPressed: _rewindSong,
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _isPlaying ? _pauseSong : () => _playSong(_currentSong!),
              ),
              IconButton(
                icon: Icon(Icons.skip_next),
                onPressed: _skipSong,
              ),
            ],
          ),
          Spacer(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _songs.length,
            itemBuilder: (context, index) {
              final song = _songs[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () => _playSong(song),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
