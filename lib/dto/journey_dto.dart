import 'dart:convert';

import 'package:intl/intl.dart';

class Journey {
  final List<Coordinate> coordinates;
  final double distance;
  final DateTime date;
  final DateFormat formatter = DateFormat('d/M/y HH:mm');

  Journey(
      {required this.coordinates, required this.date, required this.distance});

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'coordinates': jsonEncode(coordinates.map((e) => e.toJson()).toList()),
      'distance': distance
    };
  }
}

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
