import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'media_player_provider.dart';

class PomodoroProvider with ChangeNotifier {
  Timer? _timer;
  Duration _duration = Duration(minutes: 25); // Default Pomodoro duration
  Duration _remainingTime = Duration(minutes: 25);
  bool _isRunning = false;
  bool _isPaused = false;
  final MediaPlayerProvider mediaPlayerProvider;
  final AudioPlayer _alarmPlayer = AudioPlayer();

  PomodoroProvider(this.mediaPlayerProvider);

  Duration get duration => _duration;
  Duration get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  String get remainingTimeString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void setDuration(Duration duration) {
    pauseTimer();
    _duration = duration;
    _remainingTime = duration;
    notifyListeners();
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _isPaused = false;
    notifyListeners();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= Duration(seconds: 1);
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        _isPaused = false;
        notifyListeners();
        _playAlarm();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _remainingTime = _duration; // Reset to default duration
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (_isPaused) {
      startTimer();
    }
  }

  Future<void> _playAlarm() async {
    await mediaPlayerProvider.pauseSong(); // Pause the music
    int result = await _alarmPlayer.play('https://cdn.pixabay.com/download/audio/2022/06/12/audio_eb85589880.mp3?filename=oversimplified-alarm-clock-113180.mp3', volume: 0.5);
    if (result == 1) {
      // success
      print("Alarm started playing successfully.");
    } else {
      // failure
      print("Failed to play alarm.");
    }
  }

  void stopAlarm() {
    _alarmPlayer.stop();
    if (mediaPlayerProvider.isPlaying) {
      mediaPlayerProvider.resumeSong();
    }
  }

  void showAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pomodoro Complete'),
          content: Text('The Pomodoro session has ended.'),
          actions: [
            TextButton(
              onPressed: () {
                stopAlarm();
                Navigator.of(context).pop();
              },
              child: Text('Stop Alarm'),
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure the music does not resume if the dialog is dismissed
      _alarmPlayer.stop();
      mediaPlayerProvider.pauseSong();
    });
  }
}
