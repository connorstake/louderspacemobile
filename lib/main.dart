import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio_background/just_audio_background.dart';
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
import 'package:timezone/data/latest.dart' as tz;


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.loudersapce.louderspace.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.speech());

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  const IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();

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
      theme: ThemeData(primarySwatch: Colors.blue,
        fontFamily: 'BeVietnamPro', // Use the Be Vietnam Pro font
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'BeVietnamPro'),
          bodyMedium: TextStyle(fontFamily: 'BeVietnamPro'),
          displayLarge: TextStyle(fontFamily: 'BeVietnamPro'),
          displayMedium: TextStyle(fontFamily: 'BeVietnamPro'),
          displaySmall: TextStyle(fontFamily: 'BeVietnamPro'),
          headlineMedium: TextStyle(fontFamily: 'BeVietnamPro'),
          headlineSmall: TextStyle(fontFamily: 'BeVietnamPro'),
          titleLarge: TextStyle(fontFamily: 'BeVietnamPro'),
          titleMedium: TextStyle(fontFamily: 'BeVietnamPro'),
          titleSmall: TextStyle(fontFamily: 'BeVietnamPro'),
          bodySmall: TextStyle(fontFamily: 'BeVietnamPro'),
          labelLarge: TextStyle(fontFamily: 'BeVietnamPro'),
          labelSmall: TextStyle(fontFamily: 'BeVietnamPro'),
        ),),
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
                  page = MediaPlayerScreen(stationId: settings.arguments as int, animationFilePath: '');
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
