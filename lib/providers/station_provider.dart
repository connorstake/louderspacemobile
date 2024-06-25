import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/station_service.dart';

class StationProvider with ChangeNotifier {
  final StationService _stationService;
  List<Station> _stations = [];
  bool _loading = false;

  StationProvider(this._stationService);

  List<Station> get stations => _stations;
  bool get loading => _loading;

  Future<void> fetchStations() async {
    _loading = true;
    notifyListeners();

    try {
      _stations = await _stationService.getStations();
      print('Stations: $_stations');
    } catch (error) {
      print('Error fetching stations: $error');
      _stations = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> createStation(String name, List<String> tags) async {
    try {
      final newStation = await _stationService.createStation(name, tags);
      _stations.add(newStation);
      notifyListeners();
    } catch (error) {
      print('Error creating station: $error');
    }
  }

  Future<void> updateStation(int id, String name, List<String> tags) async {
    try {
      final updatedStation = await _stationService.updateStation(id, name, tags);
      final index = _stations.indexWhere((station) => station.id == id);
      if (index != -1) {
        _stations[index] = updatedStation;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating station: $error');
    }
  }

  Future<void> deleteStation(int id) async {
    try {
      await _stationService.deleteStation(id);
      _stations.removeWhere((station) => station.id == id);
      notifyListeners();
    } catch (error) {
      print('Error deleting station: $error');
    }
  }
}
