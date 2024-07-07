import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'http://localhost:8080',
      baseUrl:  'https://louderspace-5cc5cf5b293d.herokuapp.com',
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); //continue
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
}
