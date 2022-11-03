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
            journeys.journeys.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      journeys.deleteAll();
                    },
                    icon: const Icon(Icons.delete_forever))
                : Container(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
        ),
        body: Center(
            child: journeys.journeys.isNotEmpty
                ? ListView.builder(
                    itemCount: journeys.journeys.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed('/details',
                              arguments: JourneyDetailsArguments(
                                  journeys.journeys[i]));
                        },
                        title: Text(
                            '${journeys.journeys[i].formatter.format(journeys.journeys[i].start)} - ${journeys.journeys[i].end.difference(journeys.journeys[i].start).inMinutes} minutes'),
                        subtitle: Text(
                            '${NumberFormat.decimalPattern().format(journeys.journeys[i].distance / 1000)}km'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                        ),
                      );
                    })
                : const ListTile(
                    title: Text('You haven\'t recorded any journeys yet.'),
                    subtitle: Text(
                        'Start recording by tapping the button in the lower right corner.'),
                  )),
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
