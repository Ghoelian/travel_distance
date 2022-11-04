import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_distance/dto/settings_dto.dart';
import 'package:travel_distance/models/settings_model.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    Future<int?> efficiencySetting(SettingsModel settings) async {
      final controller = TextEditingController();
      controller.value =
          TextEditingValue(text: settings.settings.efficiency.toString());
      EfficiencyType? efficiencyType = settings.settings.efficiencyType;

      return (await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Efficiency'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Changing this setting will only affect future journeys.'),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onSubmitted: (value) {
                      settings.changeEfficiency(
                          double.tryParse(controller.text) ?? 0,
                          efficiencyType ?? EfficiencyType.kilometresPerLitre);
                      Navigator.of(context).pop();
                    },
                  )
                  // Expanded(
                  //     child: DropdownButton(
                  //       value: efficiencyType,
                  //       items: [
                  //         DropdownMenuItem(
                  //             value: EfficiencyType.litresPer100Kilometres,
                  //             child: Text(settings.settings.efficiencyStrings[
                  //             EfficiencyType.litresPer100Kilometres]['short'])),
                  //         DropdownMenuItem(
                  //             value: EfficiencyType.kilometresPerLitre,
                  //             child: Text(settings.settings.efficiencyStrings[
                  //             EfficiencyType.kilometresPerLitre]['short']))
                  //       ],
                  //       onChanged: (value) {
                  //         setState(() {
                  //           efficiencyType = value;
                  //           print(efficiencyType);
                  //         });
                  //       },
                  //     ))
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      settings.changeEfficiency(
                          double.tryParse(controller.text) ?? 0,
                          efficiencyType ?? EfficiencyType.kilometresPerLitre);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'))
              ],
            );
          }));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Consumer<SettingsModel>(
          builder: (context, settings, child) {
            return ListView(
              children: [
                ListTile(
                  onTap: () {
                    efficiencySetting(settings);
                  },
                  title: const Text('Efficiency'),
                  subtitle: Text(
                      '${settings.settings.efficiency} ${settings.settings.efficiencyStrings[settings.settings.efficiencyType]['long']}'),
                )
              ],
            );
          },
        ));
  }
}
