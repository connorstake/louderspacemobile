import 'package:flutter/material.dart';
import 'package:louderspacemobile/providers/feedback_provider.dart';
import 'package:louderspacemobile/services/feedback_service.dart';
import 'package:provider/provider.dart';
import 'client/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/station_provider.dart';
import 'providers/song_provider.dart';
import 'services/auth_service.dart';
import 'services/station_service.dart';
import 'services/song_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

void main() {
  final apiClient = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StationProvider(StationService(apiClient))),
        ChangeNotifierProvider(create: (_) => SongProvider(SongService(apiClient))),
        ChangeNotifierProvider(create: (_) => FeedbackProvider(FeedbackService(apiClient))),
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
            return HomeScreen();
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
