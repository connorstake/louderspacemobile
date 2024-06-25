class Station {
  final int id;
  final String name;
  final List<String> tags;

  Station({required this.id, required this.name, required this.tags});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      tags: List<String>.from(json['tags']),
    );
  }
}
