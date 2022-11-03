class Settings {
  double? efficiency;
  EfficiencyType? efficiencyType;

  Map<EfficiencyType, Map<String, String>> efficiencyStrings = {
    EfficiencyType.litresPer100Kilometres: {
      'long': 'litres per 100 kilometres',
      'short': 'l/100km'
    },
    EfficiencyType.kilometresPerLitre: {
      'long': 'kilometres per litre',
      'short': 'km/l'
    }
  };

  get getEfficiency => efficiency;
  get getEfficiencyType => efficiencyType;
  get getEfficiencyStrings => efficiencyStrings;

  Settings({this.efficiency, this.efficiencyType});
}

enum EfficiencyType {
  litresPer100Kilometres,
  kilometresPerLitre
}
