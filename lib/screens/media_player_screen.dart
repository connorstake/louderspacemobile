import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/song_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/media_player_provider.dart';

class MediaPlayerScreen extends StatefulWidget {
  final int stationId;

  MediaPlayerScreen({required this.stationId});

  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final mediaPlayerProvider = Provider.of<MediaPlayerProvider>(context, listen: false);

    if (authProvider.user != null) {
      final userId = authProvider.user!.id;
      songProvider.fetchSongsForStation(widget.stationId, userId).then((_) {
        if (songProvider.currentSong != null) {
          mediaPlayerProvider.playSong(songProvider.currentSongUrl);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaPlayerProvider = Provider.of<MediaPlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Media Player')),
      body: Consumer2<AuthProvider, SongProvider>(
        builder: (context, authProvider, songProvider, child) {
          final currentSong = songProvider.currentSong;
          if (currentSong == null) {
            return Center(child: CircularProgressIndicator());
          }
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
                IconButton(
                  icon: Icon(
                    currentSong.liked ? Icons.favorite : Icons.favorite_border,
                    color: currentSong.liked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => songProvider.toggleLikeSong(authProvider.user!.id, currentSong),
                ),
                SizedBox(height: 20),
                Slider(
                  value: mediaPlayerProvider.currentPosition.inSeconds.toDouble(),
                  max: mediaPlayerProvider.songDuration.inSeconds.toDouble(),
                  onChanged: mediaPlayerProvider.seek,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(mediaPlayerProvider.formatDuration(mediaPlayerProvider.currentPosition)),
                    Text(mediaPlayerProvider.formatDuration(mediaPlayerProvider.songDuration)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: () {
                        songProvider.playPreviousSong();
                      },
                    ),
                    IconButton(
                      icon: Icon(mediaPlayerProvider.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: mediaPlayerProvider.isPlaying ? mediaPlayerProvider.pauseSong : mediaPlayerProvider.resumeSong,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        songProvider.playNextSong();
                      },
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
}
