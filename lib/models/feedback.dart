// lib/models/feedback.dart

class Feedback {
  final int id;
  final int userId;
  final int songId;
  final bool liked;

  Feedback({
    required this.id,
    required this.userId,
    required this.songId,
    required this.liked,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      userId: json['user_id'],
      songId: json['song_id'],
      liked: json['liked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'song_id': songId,
      'liked': liked,
    };
  }
}
