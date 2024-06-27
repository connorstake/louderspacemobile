import 'package:flutter/material.dart';
import 'package:louderspacemobile/widgets/persistant_controls.dart';
import 'package:provider/provider.dart';
import 'client/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/media_player_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/song_provider.dart';
import 'providers/station_provider.dart';
import 'services/feedback_service.dart';
import 'services/song_service.dart';
import 'services/station_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

void main() {
  final apiClient = ApiClient();
  final feedbackService = FeedbackService(apiClient);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StationProvider(StationService(apiClient))),
        ChangeNotifierProvider(create: (_) => SongProvider(SongService(apiClient), feedbackService)),
        ChangeNotifierProvider(create: (_) => FeedbackProvider(feedbackService)),
        ChangeNotifierProvider(create: (_) => MediaPlayerProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Louderspace',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            return MainAppStructure();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegistrationScreen(),
      },
    );
  }
}

class MainAppStructure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/home':
              page = HomeScreen();
              break;
            case '/register':
              page = RegistrationScreen();
              break;
            case '/login':
              page = LoginScreen();
              break;
            default:
              page = HomeScreen();
              break;
          }
          return MaterialPageRoute(builder: (context) => page);
        },
      ),
      bottomNavigationBar: PersistentControls(),
    );
  }
}
