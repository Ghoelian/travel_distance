import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_distance/arguments/journey_details.dart';
import 'package:travel_distance/models/journeys_model.dart';

class Journeys extends StatelessWidget {
  const Journeys({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journeys'),
      ),
      body: Center(
        child: Consumer<JourneysModel>(builder: (context, journeys, child) {
          journeys.getFromDb();

          return ListView.builder(
              itemCount: journeys.journeys.length,
              itemBuilder: (context, i) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/details',
                        arguments: JourneyDetailsArguments(journeys.journeys[i]));
                  },
                  title: Text(journeys.journeys[i].formatter
                      .format(journeys.journeys[i].date)),
                  subtitle: Text(
                      '${NumberFormat.decimalPattern().format(journeys.journeys[i].distance / 1000)}km'),
                );
              });
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/tracker');
        },
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
