import 'package:flutter/material.dart';
import 'package:louderspacemobile/services/station_service.dart';
import 'package:provider/provider.dart';
import 'client/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/station_provider.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StationProvider(StationService(ApiClient()))),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Louderspace',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: authProvider.isAuthenticated ? HomeScreen() : LoginScreen(),
            routes: {
              '/login': (context) => LoginScreen(),
              '/home': (context) => HomeScreen(),
              '/register': (context) => RegistrationScreen(),
            },
          );
        },
      ),
    );
  }
}
