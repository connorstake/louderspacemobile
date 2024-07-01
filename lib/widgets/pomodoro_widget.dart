import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroTimerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomodoroProvider, child) {
        return GestureDetector(
          onTap: () {
            if (pomodoroProvider.isRunning) {
              _showPauseDialog(context, pomodoroProvider);
            } else {
              _showDurationPicker(context, pomodoroProvider);
            }
          },
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.8),
            ),
            child: Center(
              child: Text(
                pomodoroProvider.remainingTimeString == '00:00' ? 'Start' : pomodoroProvider.remainingTimeString,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDurationPicker(BuildContext context, PomodoroProvider pomodoroProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Pomodoro Duration'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _durationButton(context, pomodoroProvider, 5),
            _durationButton(context, pomodoroProvider, 10),
            _durationButton(context, pomodoroProvider, 25),
          ],
        ),
      ),
    );
  }

  Widget _durationButton(BuildContext context, PomodoroProvider pomodoroProvider, int minutes) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        pomodoroProvider.startTimerWithDuration(minutes);
      },
      child: Text('$minutes min'),
    );
  }

  void _showPauseDialog(BuildContext context, PomodoroProvider pomodoroProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pomodoro Timer'),
        content: Text('Timer is paused. Would you like to continue or reset the timer?'),
        actions: [
          TextButton(
            onPressed: () {
              pomodoroProvider.startTimer();
              Navigator.of(context).pop();
            },
            child: Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              pomodoroProvider.resetTimer();
              Navigator.of(context).pop();
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}
