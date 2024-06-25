import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/auth_provider.dart';
import '../providers/song_provider.dart';

class MediaPlayerScreen extends StatefulWidget {
  final int stationId;

  MediaPlayerScreen({required this.stationId});

  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  late AudioPlayer _audioPlayer;
  Duration _currentPosition = Duration.zero;
  Duration _songDuration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.PLAYING;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _songDuration = duration;
      });
      print('Duration changed: $duration');
    });

    _audioPlayer.onAudioPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
      print('Position changed: $position');
    });

    _audioPlayer.onPlayerCompletion.listen((event) {
      _skipToNextSong();
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    if (authProvider.user != null) {
      final userId = authProvider.user!.id;
      songProvider.fetchSongsForStation(widget.stationId, userId).then((_) {
        if (songProvider.currentSong != null) {
          _playSong(songProvider.currentSongUrl);
        }
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong(String url) async {
    print('Playing song: $url');
    int result = await _audioPlayer.play(url);
    if (result == 1) {
      setState(() {
        _isPlaying = true;
      });
      print('Song is playing');
    } else {
      print('Error playing song');
    }
  }

  void _pauseSong() async {
    int result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() {
        _isPlaying = false;
      });
      print('Song is paused');
    } else {
      print('Error pausing song');
    }
  }

  void _resumeSong() async {
    int result = await _audioPlayer.resume();
    if (result == 1) {
      setState(() {
        _isPlaying = true;
      });
      print('Song is resumed');
    } else {
      print('Error resuming song');
    }
  }

  void _skipToNextSong() {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.playNextSong();
    if (songProvider.currentSong != null) {
      _playSong(songProvider.currentSongUrl);
    }
  }

  void _skipToPreviousSong() {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.playPreviousSong();
    if (songProvider.currentSong != null) {
      _playSong(songProvider.currentSongUrl);
    }
  }

  void _onSeek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Player')),
      body: Consumer<SongProvider>(
        builder: (context, songProvider, child) {
          final currentSong = songProvider.currentSong;
          if (currentSong == null) {
            return Center(child: CircularProgressIndicator());
          }
          print('Current song URL: ${songProvider.currentSongUrl}');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentSong.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(currentSong.artist),
                SizedBox(height: 20),
                Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _songDuration.inSeconds.toDouble(),
                  onChanged: _onSeek,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_currentPosition)),
                    Text(_formatDuration(_songDuration)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: _skipToPreviousSong,
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _isPlaying ? _pauseSong : _resumeSong,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: _skipToNextSong,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
