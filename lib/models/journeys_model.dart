import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_distance/dto/new_journey_dto.dart';
import 'package:travel_distance/models/database_model.dart';

import '../dto/coordinates_dto.dart';
import '../dto/db_journey_dto.dart';

class JourneysModel extends ChangeNotifier {
  List<DbJourney> _journeys = [];
  final List<NewJourney> _newJourneys = [];

  List<DbJourney> get journeys => _journeys;

  List<NewJourney> get newJourneys => _newJourneys;

  Future<void> getFromDb() async {
    _journeys = [];

    final db = DatabaseModel.database;

    final List<Map<String, dynamic>>? maps = await db?.query('journeys');
    print(maps![0]['usage']);

    if (maps != null && maps.isNotEmpty) {
      _journeys = List.generate(maps.length, (index) {
        List<dynamic> coordinates = jsonDecode(maps[index]['coordinates']);
        List<Coordinate> coordinatesObject = [];

        for (var element in coordinates) {
          coordinatesObject.add(Coordinate.fromJson(element));
        }

        var journey = DbJourney(
            id: maps[index]['id'],
            coordinates: coordinatesObject,
            start: (DateTime.fromMillisecondsSinceEpoch(maps[index]['start'])),
            end: (DateTime.fromMillisecondsSinceEpoch(maps[index]['end'])),
            distance: maps[index]['distance'],
            usage: double.tryParse(maps[index]['usage'].toString()) ?? 0);

        return journey;
      });
    }

    notifyListeners();
  }

  void addJourney(NewJourney journey) {
    _newJourneys.add(journey);

    notifyListeners();
  }

  Future<void> saveToStorage() async {
    final db = DatabaseModel.database;

    for (var e in _newJourneys) {
      await db?.insert('journeys', e.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    }
  }

  Future<void> deleteAll() async {
    final db = DatabaseModel.database;

    await db?.delete('journeys');
    _journeys = [];

    notifyListeners();
  }

  Future<void> deleteOne(DbJourney journey) async {
    final db = DatabaseModel.database;

    await db?.delete('journeys', where: 'id = ?', whereArgs: [journey.id]);

    getFromDb();

    notifyListeners();
  }
}
