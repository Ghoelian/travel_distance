class Coordinate {
  final double latitude;
  final double longitude;

  Coordinate({required this.latitude, required this.longitude});

  Map toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(latitude: json['latitude'], longitude: json['longitude']);
  }
}