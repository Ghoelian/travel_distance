import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../arguments/journey_details.dart';

class JourneyDetails extends StatefulWidget {
  const JourneyDetails({Key? key}) : super(key: key);

  @override
  State<JourneyDetails> createState() => _JourneyDetailsState();
}

class _JourneyDetailsState extends State<JourneyDetails> {
  int _polylineIdCounter = 1;
  final Map<PolylineId, Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as JourneyDetailsArguments;

    for (int i = 1; i < args.journey.coordinates.length; i++) {
      final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
      _polylineIdCounter++;
      final PolylineId polylineId = PolylineId(polylineIdVal);

      final Polyline polyline = Polyline(
          polylineId: polylineId,
          consumeTapEvents: true,
          color: Colors.red,
          width: 5,
          points: [
            LatLng(args.journey.coordinates[i - 1].latitude,
                args.journey.coordinates[i - 1].longitude),
            LatLng(args.journey.coordinates[i].latitude,
                args.journey.coordinates[i].longitude)
          ]);

      _polylines[polylineId] = polyline;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
        ),
        body: Column(
          children: [
            ListTile(
              title: Text(
                  'Total distance: ${NumberFormat.decimalPattern().format(args.journey.distance / 1000)}km'),
            ),
            ListTile(
              title: Text('Total petrol used: ${NumberFormat.decimalPattern().format(args.journey.usage)}L')
            ),
            ListTile(
              title: Text('Total time: ${args.journey.end.difference(args.journey.start).inMinutes} minutes'),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    zoom: 18.0,
                    target: LatLng(args.journey.coordinates[0].latitude,
                        args.journey.coordinates[0].longitude)),
                polylines: Set<Polyline>.of(_polylines.values),
              ),
            )
          ],
        ));
  }
}
