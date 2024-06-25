import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:louderspacemobile/models/station.dart';

import '../client/api_client.dart';

class StationService {
  final ApiClient _apiClient;

  StationService(this._apiClient);

  Future<List<Station>> getStations() async {
    final response = await _apiClient.get('/stations');
    print('stations: ${response.data}');

    // Decode the response data to ensure it's a list of maps
    final List<dynamic> data = jsonDecode(response.data) as List<dynamic>;
    return data.map((station) => Station.fromJson(station as Map<String, dynamic>)).toList();
  }


  Future<Station> createStation(String name, List<String> tags) async {
    final response = await _apiClient.post('/admin/stations', data: {'name': name, 'tags': tags});
    return Station.fromJson(response.data);
  }

  Future<Station> updateStation(int id, String name, List<String> tags) async {
    final response = await _apiClient.put('/admin/stations/$id', data: {'name': name, 'tags': tags});
    return Station.fromJson(response.data);
  }

  Future<void> deleteStation(int id) async {
    await _apiClient.delete('/admin/stations/$id');
  }
}
