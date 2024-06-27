import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroProvider with ChangeNotifier {
  Timer? _timer;
  Duration _remainingTime = Duration(minutes: 1); // Default Pomodoro duration
  bool _isRunning = false;

  Duration get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;

  String get remainingTimeString {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= Duration(seconds: 1);
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _remainingTime = Duration(minutes: 1); // Reset to default duration
    _isRunning = false;
    notifyListeners();
  }
}

