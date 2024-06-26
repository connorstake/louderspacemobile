import 'dart:convert';

import 'package:dio/dio.dart';
import '../client/api_client.dart';
import '../models/song.dart';

class SongService {
  final ApiClient _apiClient;

  SongService(this._apiClient);

  Future<List<Song>> getSongsForStation(int stationId, int userId) async {
    final response = await _apiClient.get('/stations/$stationId/songs',  queryParameters: {'user_id': userId});
    final List<dynamic> data = jsonDecode(response.data) as List<dynamic>;
    print('decoded songs: $data');
    return data.map((song) => Song.fromJson(song as Map<String, dynamic>)).toList();
  }
}
