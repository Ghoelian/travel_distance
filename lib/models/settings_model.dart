import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:travel_distance/dto/settings_dto.dart';
import 'package:travel_distance/models/database_model.dart';

class SettingsModel extends ChangeNotifier {
  static final Settings _settings = Settings();

  get settings => _settings;

  static Future<void> init() async {
    final db = DatabaseModel.database;

    final List<Map<String, dynamic>>? settings = await db?.query('settings');

    if (settings != null && settings.isNotEmpty) {
      for (var setting in settings) {
        String key = setting['key'];

        switch (key) {
          case 'efficiency':
            _settings.efficiency = double.tryParse(setting['value']);
            break;
          case 'efficiencyType':
            switch (setting['value']) {
              case 'kilometresPerLitre':
                _settings.efficiencyType = EfficiencyType.kilometresPerLitre;
                break;
              case 'litresPerKilometre':
                _settings.efficiencyType = EfficiencyType.litresPer100Kilometres;
                break;
            }
            break;
        }
      }
    }
  }

  void changeEfficiency(double efficiency, EfficiencyType type) {
    _settings.efficiency = efficiency;
    _settings.efficiencyType = type;

    notifyListeners();
  }
}