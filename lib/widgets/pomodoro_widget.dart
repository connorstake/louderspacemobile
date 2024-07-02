import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';

class PomodoroTimerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, pomodoroProvider, child) {
        return Stack(
          children: [
            // Your main content goes here
            IgnorePointer(
              ignoring: true, // Ignore touch events for the underlying Scaffold
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Container(), // An empty container to maintain the structure
              ),
            ),
            // Floating Pomodoro control
            Positioned(
              top: 50, // Adjust the position as needed
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (pomodoroProvider.isRunning) {
                    _showPauseDialog(context, pomodoroProvider);
                  } else if (pomodoroProvider.isPaused) {
                    _showResumeDialog(context, pomodoroProvider); // Show resume dialog if paused
                  } else {
                    _showDurationPicker(context, pomodoroProvider);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pomodoro Timer',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        pomodoroProvider.remainingTimeString == '00:00' ? 'Start' : pomodoroProvider.remainingTimeString,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        content: Text('Timer is running. Would you like to pause or reset the timer?'),
        actions: [
          TextButton(
            onPressed: () {
              pomodoroProvider.pauseTimer();
              Navigator.of(context).pop();
            },
            child: Text('Pause'),
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

  void _showResumeDialog(BuildContext context, PomodoroProvider pomodoroProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pomodoro Timer'),
        content: Text('Timer is paused. Would you like to continue or reset the timer?'),
        actions: [
          TextButton(
            onPressed: () {
              pomodoroProvider.resumeTimer();
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
