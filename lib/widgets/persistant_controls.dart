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
                  child: ListTile(
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
                          Icons.local_fire_department,
                          color: Colors.white,
                        ),
                      )
                          : Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                      ),
                      onPressed: () => songProvider.toggleLikeSong(
                          Provider.of<AuthProvider>(context, listen: false).user!.id, currentSong),
                    )
                        : null,
                    title: Text(
                    songProvider.currentSong != null ? songProvider.currentSong!.title : 'Unknown Song',
                      // currentStation?.name ?? 'Unknown Station',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      mediaPlayer.isPlaying ? 'Playing' : 'Paused',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                ),
              // Uncomment and style the Pomodoro timer if needed
              // if (pomodoro.remainingTimeString.isNotEmpty)
              //   Container(
              //     decoration: BoxDecoration(
              //       color: Colors.black87,
              //       borderRadius: BorderRadius.circular(20.0),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black54,
              //           blurRadius: 10.0,
              //           offset: Offset(0, 5),
              //         ),
              //       ],
              //     ),
              //     child: ListTile(
              //       title: Text(
              //         'Pomodoro Timer',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //       subtitle: Text(
              //         pomodoro.remainingTimeString,
              //         style: TextStyle(color: Colors.white70),
              //       ),
              //       trailing: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           IconButton(
              //             icon: Icon(Icons.pause, color: Colors.white),
              //             onPressed: pomodoro.pauseTimer,
              //           ),
              //           IconButton(
              //             icon: Icon(Icons.play_arrow, color: Colors.white),
              //             onPressed: pomodoro.startTimer,
              //           ),
              //           IconButton(
              //             icon: Icon(Icons.stop, color: Colors.white),
              //             onPressed: pomodoro.resetTimer,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }
}
