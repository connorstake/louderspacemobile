import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'media_player_provider.dart';

class PomodoroProvider with ChangeNotifier {
  Timer? _timer;
  Duration _duration = Duration(minutes: 25); // Default Pomodoro duration
  Duration _remainingTime = Duration(minutes: 25);
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isZero = false;
  final MediaPlayerProvider mediaPlayerProvider;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  PomodoroProvider(this.mediaPlayerProvider);

  Duration get duration => _duration;
  Duration get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isZero => _isZero;

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
    _isZero = false;
    notifyListeners();
  }

  void startTimer() {
    if (_isRunning) return;
    if (_isZero) {
      resetTimer();
    }
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
        _isZero = true;
        notifyListeners();
        _scheduleAlarm();
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
    _isZero = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (_isPaused) {
      startTimer();
    }
  }

  Future<void> _scheduleAlarm() async {
    await mediaPlayerProvider.pauseSong(); // Pause the music

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Pomodoro Complete',
      'The Pomodoro session has ended.',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)), // Schedule to ring in 5 seconds for testing
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          // Use the default notification sound
          sound: RawResourceAndroidNotificationSound('default'),
        ),
        iOS: IOSNotificationDetails(
          // Use the default notification sound
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void stopAlarm() {
    flutterLocalNotificationsPlugin.cancel(0);
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
      stopAlarm();
    });
  }
}
