import 'package:flutter/material.dart';
import 'package:louderspacemobile/models/user.dart';
import 'package:louderspacemobile/services/api_client.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient;
  User? _user;

  AuthProvider(this.apiClient);

  User? get user => _user;

  Future<void> login(String username, String password) async {
    final response = await apiClient.login(username, password);
    _user = User.fromJson(response.data['user']);
    notifyListeners();
  }

  Future<void> register(String username, String password, String email, String role) async {
    final response = await apiClient.register(username, password, email, role);
    _user = User.fromJson(response.data['user']);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
