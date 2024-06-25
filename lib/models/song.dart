import 'dart:ffi';

class Song {
  final int id;
  final String title;
  final String artist;
  final String genre;
  final String sunoId;
  final bool liked;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.sunoId,
    required this.liked,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      genre: json['genre'],
      sunoId: json['suno_id'],
      liked: json['liked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genre': genre,
      'suno_id': sunoId,
      'liked': liked,
    };
  }
}
