import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../client/api_client.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  final AuthService _authService = AuthService(ApiClient());

  User? get user => _user;
  bool get isAuthenticated => _user != null;


  Future<void> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      print('Raw Response: ${response}');

      final Map<String, dynamic> responseData = jsonDecode(response);
      print('Parsed Response: $responseData');

      if (responseData.containsKey('token') && responseData.containsKey('user')) {
        _token = responseData['token'] as String?;
        print('Token: $_token');

        final userMap = responseData['user'];
        if (userMap is Map<String, dynamic>) {
          _user = User.fromJson(userMap);
          print('User: $_user');

          // Store token in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
        } else {
          throw Exception('Invalid user data');
        }

        notifyListeners();
      } else {
        throw Exception('Invalid login response');
      }
    } catch (e) {
      print('Error in login: $e');
      throw Exception('Login failed');
    }
  }

  Future<void> register(String username, String password, String email, String role) async {
    try {
      final response = await _authService.register(username, password, email, role);
      _token = response['token'];
      _user = User.fromJson(response['user']);

      // Store token in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;

    // Remove token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return;
    }

    final token = prefs.getString('token');
    if (token != null) {
      try {
        final userData = await _authService.getUserDetails(token);
        _user = User.fromJson(userData);
        _token = token;
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }
}
