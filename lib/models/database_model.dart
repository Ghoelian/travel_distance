import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseModel extends ChangeNotifier {
  static Future<Database>? database;

  static void init() async {
    database =
        openDatabase(join(await getDatabasesPath(), 'journeys_database.db'),
            onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE journeys(id INTEGER PRIMARY KEY AUTOINCREMENT, date INTEGER, coordinates TEXT, distance REAL)');
    }, version: 1);
  }
}
