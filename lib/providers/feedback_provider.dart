// lib/providers/feedback_provider.dart

import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService;
  bool? _liked;

  FeedbackProvider(this._feedbackService);

  bool? get liked => _liked;

  Future<void> createFeedback(int userId, int songId, bool liked) async {
    await _feedbackService.createFeedback(userId, songId, liked);
    _liked = liked;
    notifyListeners();
  }

  Future<void> deleteFeedback(int userId, int songId) async {
    await _feedbackService.deleteFeedback(userId, songId);
    _liked = null;
    notifyListeners();
  }

  Future<void> getFeedback(int userId, int songId) async {
    final feedback = await _feedbackService.getFeedback(userId, songId);
    _liked = feedback['liked'] as bool?;
    notifyListeners();
  }
}
