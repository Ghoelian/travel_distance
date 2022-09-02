import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../arguments/journey_details.dart';
import '../models/journeys_model.dart';

class Journeys extends StatefulWidget {
  const Journeys({Key? key}) : super(key: key);

  @override
  State<Journeys> createState() => _JourneysState();
}

class _JourneysState extends State<Journeys> {
  @override
  void initState() {
    super.initState();

    JourneysModel journeys = Provider.of<JourneysModel>(context, listen: false);
    journeys.getFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JourneysModel>(builder: (context, journeys, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Journeys'),
          actions: [
            IconButton(onPressed: () {
              journeys.deleteAll();
            }, icon: const Icon(Icons.delete_forever))
          ],
        ),
        body: Center(
            child: ListView.builder(
                itemCount: journeys.journeys.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/details',
                          arguments:
                              JourneyDetailsArguments(journeys.journeys[i]));
                    },
                    title: Text(journeys.journeys[i].formatter
                        .format(journeys.journeys[i].date)),
                    subtitle: Text(
                        '${NumberFormat.decimalPattern().format(journeys.journeys[i].distance / 1000)}km'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  );
                })),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/tracker');
          },
          tooltip: 'Start recording journey',
          child: const Icon(Icons.navigation),
        ),
      );
    });
  }
}
