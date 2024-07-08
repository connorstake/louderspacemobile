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
              left: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        _durationButton(context, pomodoroProvider, 5),
                        SizedBox(width: 5),
                        _durationButton(context, pomodoroProvider, 10),
                        SizedBox(width: 5),
                        _durationButton(context, pomodoroProvider, 25),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        pomodoroProvider.isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        if (pomodoroProvider.isRunning) {
                          pomodoroProvider.pauseTimer();
                        } else {
                          pomodoroProvider.startTimer();
                        }
                      },
                    ),
                    Spacer(),
                    Container(
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: Text(
                          pomodoroProvider.remainingTimeString,
                          key: ValueKey(pomodoroProvider.remainingTimeString),
                          style: TextStyle(
                            color: pomodoroProvider.isZero ? Colors.red : Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _durationButton(BuildContext context, PomodoroProvider pomodoroProvider, int minutes) {
    final bool isSelected = pomodoroProvider.duration.inMinutes == minutes;

    return GestureDetector(
      onTap: () {
        if (pomodoroProvider.isRunning || (pomodoroProvider.isPaused && pomodoroProvider.remainingTime < pomodoroProvider.duration)) {
          _showResetDialog(context, pomodoroProvider, minutes);
        } else {
          pomodoroProvider.setDuration(Duration(minutes: minutes));
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isSelected ? Colors.white : Colors.grey,
        child: Text(
          '$minutes',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, PomodoroProvider pomodoroProvider, int minutes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pomodoro Timer'),
        content: Text('Timer is running. Would you like to reset the timer to $minutes minutes?'),
        actions: [
          TextButton(
            onPressed: () {
              pomodoroProvider.setDuration(Duration(minutes: minutes));
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }
}
