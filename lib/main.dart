import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:louderspacemobile/services/api_client.dart';
import 'package:louderspacemobile/providers/auth_provider.dart';
import 'package:louderspacemobile/providers/station_provider.dart';
import 'package:louderspacemobile/screens/login_screen.dart';
import 'package:louderspacemobile/screens/registration_screen.dart';
import 'package:louderspacemobile/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient = ApiClient();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => StationProvider(apiClient)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}
