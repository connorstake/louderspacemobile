import 'package:dio/dio.dart';

import '../client/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<dynamic> login(String username, String password) async {
    final response = await _apiClient.post(
      '/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    return response.data;
  }

  Future<dynamic> register(String username, String password, String email, String role) async {
    final response = await _apiClient.post(
      '/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
        'role': role,
      },
    );
    return response.data;
  }

  Future<dynamic> getUserDetails(String token) async {
    final response = await _apiClient.get(
      '/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data;
  }
}
