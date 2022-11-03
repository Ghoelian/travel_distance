import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseModel extends ChangeNotifier {
  static Database? database;

  static Future<void> init() async {
    database = await openDatabase(
        join(await getDatabasesPath(), 'journeys_database.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE journeys(id INTEGER PRIMARY KEY AUTOINCREMENT, start INTEGER, end INTEGER, coordinates TEXT, distance REAL)');
      await db.execute('ALTER TABLE journeys ADD COLUMN usage REAL');
      await db.execute(
          'CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT)');
      return await db.execute(
          'INSERT INTO settings (key, value) VALUES (\'efficiency\', \'14\'), (\'efficiencyType\', \'kilometresPerLitre\')');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      debugPrint('Updgading db from $oldVersion to $newVersion');

      if (newVersion == 2) {
        await db.execute('ALTER TABLE journeys ADD COLUMN usage REAL');
        await db.execute(
            'CREATE TABLE settings(id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT)');
        return await db.execute(
            'INSERT INTO settings (key, value) VALUES (\'efficiency\', \'14\'), (\'efficiencyType\', \'kilometresPerLitre\')');
      }
    }, version: 2);
  }
}
