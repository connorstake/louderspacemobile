import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));

  Future<Response> login(String username, String password) async {
    return _dio.post('/login', data: {'username': username, 'password': password});
  }

  Future<Response> register(String username, String password, String email, String role) async {
    return _dio.post('/register', data: {
      'username': username,
      'password': password,
      'email': email,
      'role': role,
    });
  }

  Future<Response> getStations() async {
    return _dio.get('/stations');
  }


// Add other API methods here
}
