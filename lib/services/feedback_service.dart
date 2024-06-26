// lib/services/feedback_service.dart

import '../client/api_client.dart';

class FeedbackService {
  final ApiClient _apiClient;

  FeedbackService(this._apiClient);

  Future<void> createFeedback(int userId, int songId, bool liked) async {
    print('FeedbackService: Creating feedback for song: $songId, liked: $liked for user: $userId');
   final response = await _apiClient.post('/feedback', data: {'user_id': userId, 'song_id': songId, 'liked': liked});
   print('Feedback created: ${response.data}');
  }

  Future<void> deleteFeedback(int userId, int songId) async {
    await _apiClient.delete(
      '/feedback',
      queryParameters: {'user_id': userId, 'song_id': songId},
    );
  }

  Future<Map<String, dynamic>> getFeedback(int userId, int songId) async {
    final response = await _apiClient.get('/feedback', queryParameters: {'user_id': userId, 'song_id': songId});
    return response.data;
  }
}
