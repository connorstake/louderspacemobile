import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/media_player_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/song_provider.dart';
import '../providers/station_provider.dart';
import '../providers/auth_provider.dart';

class PersistentControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer4<MediaPlayerProvider, PomodoroProvider, StationProvider, SongProvider>(
      builder: (context, mediaPlayer, pomodoro, stationProvider, songProvider, child) {
        final currentSongUrl = mediaPlayer.currentSongUrl;
        final currentStationId = mediaPlayer.stationId;
        final currentStation = currentStationId != null
            ? stationProvider.stations.firstWhere(
              (station) => station.id == currentStationId,
          orElse: () => Station(id: -1, name: 'Unknown', tags: []),
        )
            : null;
        final currentSong = songProvider.currentSong;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentSongUrl != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: currentSong != null
                            ? IconButton(
                          icon: currentSong.liked
                              ? ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [Colors.red, Colors.orange],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds);
                            },
                            child: Icon(
                              size: 40,
                              Icons.local_fire_department,
                              color: Colors.white,
                            ),
                          )
                              : Icon(
                            size: 40,
                            Icons.local_fire_department,
                            color: Colors.white,
                          ),
                          onPressed: () => songProvider.toggleLikeSong(
                              Provider.of<AuthProvider>(context, listen: false).user!.id, currentSong),
                        )
                            : null,
                        title: Text(
                          currentStation?.name ?? 'Unknown Station',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          mediaPlayer.isPlaying ? 'Playing' : 'Paused',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: mediaPlayer.playPreviousSong,
                            ),
                            IconButton(
                              icon: Icon(
                                mediaPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: mediaPlayer.isPlaying
                                  ? mediaPlayer.pauseSong
                                  : mediaPlayer.resumeSong,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              onPressed: mediaPlayer.playNextSong,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Slider(
                          value: mediaPlayer.currentPosition.inSeconds.toDouble(),
                          max: mediaPlayer.songDuration.inSeconds.toDouble(),
                          onChanged: mediaPlayer.seek,
                          activeColor: Colors.white,
                          inactiveColor: Colors.blueGrey,
                          thumbColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
