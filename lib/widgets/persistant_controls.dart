import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/media_player_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/station_provider.dart';

class PersistentControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<MediaPlayerProvider, PomodoroProvider, StationProvider>(
      builder: (context, mediaPlayer, pomodoro, stationProvider, child) {


        final currentSongUrl = mediaPlayer.currentSongUrl;
        final currentStationId = mediaPlayer.stationId;
        final currentStation = currentStationId != null
            ? stationProvider.stations.firstWhere(
              (station) => station.id == currentStationId,
          orElse: () => Station(id: -1, name: 'Unknown', tags: []),
        )
            : null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentSongUrl != null)
              ListTile(
                title: Text(currentStation?.name ?? 'Unknown Station'), // Update this line to show the song name instead of URL
                subtitle: Text(mediaPlayer.isPlaying ? 'Playing' : 'Paused'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: mediaPlayer.playPreviousSong,
                    ),
                    IconButton(
                      icon: Icon(mediaPlayer.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: mediaPlayer.isPlaying ? mediaPlayer.pauseSong : mediaPlayer.resumeSong,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: mediaPlayer.playNextSong,
                    ),
                  ],
                ),
              ),
            if (pomodoro.remainingTimeString.isNotEmpty)
              ListTile(
                title: Text('Pomodoro Timer'),
                subtitle: Text(pomodoro.remainingTimeString),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: pomodoro.pauseTimer,
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: pomodoro.startTimer,
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: pomodoro.resetTimer,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
