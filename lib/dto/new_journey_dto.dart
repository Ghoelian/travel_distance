import 'dart:convert';

import 'package:intl/intl.dart';

import 'coordinates_dto.dart';

class NewJourney {
  final List<Coordinate> coordinates;
  final double distance;
  final DateTime start;
  final DateTime end;
  final DateFormat formatter = DateFormat('d/M/y HH:mm');

  NewJourney(
      {required this.coordinates, required this.start, required this.end, required this.distance});

  Map<String, dynamic> toMap() {
    return {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'coordinates': jsonEncode(coordinates.map((e) => e.toJson()).toList()),
      'distance': distance
    };
  }
}
