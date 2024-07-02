import 'package:flutter/material.dart';
import 'package:louderspacemobile/screens/media_player_screen.dart';
import 'package:louderspacemobile/widgets/persistant_controls.dart';
import 'package:louderspacemobile/widgets/pomodoro_widget.dart';
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
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  final apiClient = ApiClient();
  final feedbackService = FeedbackService(apiClient);
  final mediaPlayerProvider = MediaPlayerProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StationProvider(StationService(apiClient))),
        ChangeNotifierProvider(create: (_) => SongProvider(SongService(apiClient), feedbackService, mediaPlayerProvider)),
        ChangeNotifierProvider(create: (_) => FeedbackProvider(feedbackService)),
        ChangeNotifierProvider(create: (_) => mediaPlayerProvider),
        ChangeNotifierProvider(create: (_) => PomodoroProvider(mediaPlayerProvider)), // Pass the mediaPlayerProvider here
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

class MainAppStructure extends StatefulWidget {
  @override
  _MainAppStructureState createState() => _MainAppStructureState();
}

class _MainAppStructureState extends State<MainAppStructure> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      final mediaPlayerProvider = Provider.of<MediaPlayerProvider>(context, listen: false);
      mediaPlayerProvider.setSongProvider(songProvider);
    });
  }

  @override
  void dispose() {
    final mediaPlayerProvider = Provider.of<MediaPlayerProvider>(context, listen: false);
    mediaPlayerProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Navigator(
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/login':
                  page = LoginScreen();
                  break;
                case '/register':
                  page = RegistrationScreen();
                  break;
                case '/home':
                  page = HomeScreen();
                  break;
                case '/media_player':
                  page = MediaPlayerScreen(stationId: settings.arguments as int, animationFilePath: '',);
                  break;
                default:
                  page = HomeScreen();
                  break;
              }
              return MaterialPageRoute(builder: (context) => page);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PersistentControls(),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PomodoroTimerWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
