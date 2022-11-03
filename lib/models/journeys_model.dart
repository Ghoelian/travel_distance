import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_distance/models/database_model.dart';

import '../dto/journey_dto.dart';

class JourneysModel extends ChangeNotifier {
  List<Journey> _journeys = [];

  final FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  List<Journey> get journeys => _journeys;

  Future<void> getFromDb() async {
    _journeys = [];

    final db = await DatabaseModel.database;

    final List<Map<String, dynamic>>? maps = await db?.query('journeys');

    if (maps != null && maps.isNotEmpty) {
      _journeys = List.generate(maps.length, (index) {
        List<dynamic> coordinates = jsonDecode(maps[index]['coordinates']);
        List<Coordinate> coordinatesObject = [];

        for (var element in coordinates) {
          coordinatesObject.add(Coordinate.fromJson(element));
        }

        var journey = Journey(
            coordinates: coordinatesObject,
            start: (DateTime.fromMillisecondsSinceEpoch(maps[index]['start'])),
            end: (DateTime.fromMillisecondsSinceEpoch(maps[index]['end'])),
            distance: maps[index]['distance']);

        return journey;
      });
    }

    notifyListeners();
  }

  void addJourney(Journey journey) {
    _journeys.add(journey);

    notifyListeners();
  }

  Future<void> saveToStorage() async {
    final db = await DatabaseModel.database;

    journeys.forEach((e) async {
      await db?.insert('journeys', e.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    });
  }

  void deleteAll() async {
    final db = await DatabaseModel.database;

    await db?.delete('journeys');
    _journeys = [];

    notifyListeners();
  }
}
