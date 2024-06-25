import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'client/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/station_provider.dart';
import 'services/station_service.dart';
import 'services/song_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => StationProvider(
            StationService(context.read<ApiClient>()),
          ),
        ),
        Provider(create: (context) => SongService(context.read<ApiClient>())),
      ],
      child: MaterialApp(
        title: 'Louderspace',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
          ),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
        },
      ),
    );
  }
}
