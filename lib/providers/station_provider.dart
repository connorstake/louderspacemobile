import 'package:flutter/material.dart';
import 'package:louderspacemobile/models/station.dart';
import 'package:louderspacemobile/services/api_client.dart';

class StationProvider with ChangeNotifier {
  final ApiClient apiClient;

  StationProvider(this.apiClient);

  Future<List<Station>> fetchStations() async {
    final response = await apiClient.getStations();
    final List<dynamic> data = response.data;
    return data.map((json) => Station.fromJson(json)).toList();
  }
}
