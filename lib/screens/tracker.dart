import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:travel_distance/dto/new_journey_dto.dart';
import 'package:travel_distance/dto/settings_dto.dart';
import 'package:travel_distance/models/journeys_model.dart';
import 'package:travel_distance/models/location_model.dart';
import 'package:travel_distance/models/settings_model.dart';

import '../dto/coordinates_dto.dart';

class Tracker extends StatefulWidget {
  const Tracker({Key? key}) : super(key: key);

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final Location _location = Location();
  final List<Coordinate> _journey = [];
  final Map<PolylineId, Polyline> _polyLines = {};
  final Completer<GoogleMapController> _controller = Completer();
  int _polyLineIdCounter = 1;
  StreamSubscription? _locationStream;
  final DateTime start = DateTime.now();
  late DateTime end;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      var locationModel = Provider.of<LocationModel>(context, listen: false);

      var hasPermission = locationModel.hasPermissionAndService();

      if (hasPermission) {
        _location.enableBackgroundMode(enable: true);
        _location.changeSettings(interval: 500);

        _location.getLocation().then((locationData) => {
              setState(() {
                _journey.add(Coordinate(
                    latitude: locationData.latitude!,
                    longitude: locationData.longitude!));
              })
            });

        _locationStream =
            _location.onLocationChanged.listen((LocationData location) async {
          final GoogleMapController controller = await _controller.future;

          controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(location.latitude!, location.longitude!),
                  zoom: 18.0)));

          final String polylineIdval = 'polyline_id_$_polyLineIdCounter';
          _polyLineIdCounter++;
          final PolylineId polylineId = PolylineId(polylineIdval);

          final Polyline polyline = Polyline(
              polylineId: polylineId,
              consumeTapEvents: true,
              color: Colors.red,
              width: 5,
              points: [
                LatLng(_journey[_journey.length - 1].latitude,
                    _journey[_journey.length - 1].longitude),
                LatLng(location.latitude!, location.longitude!)
              ]);

          setState(() {
            _journey.add(Coordinate(
                latitude: location.latitude!, longitude: location.longitude!));

            _polyLines[polylineId] = polyline;
          });
        });
      } else {
        Navigator.of(context).popAndPushNamed('/fix-permissions');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    print('Disposing');

    _locationStream?.cancel();
  }

  void stopRecording() {
    JourneysModel journeys = Provider.of<JourneysModel>(context, listen: false);
    double totalDistance = 0;
    Coordinate? previous;

    end = DateTime.now();

    for (var locationData in _journey) {
      if (previous == null) {
        previous = locationData;
        continue;
      }

      double lat1 = previous.latitude;
      double lat2 = locationData.latitude;
      double lon1 = previous.longitude;
      double lon2 = locationData.longitude;

      double R = 6378e3;
      double phi1 = lat1 * pi / 180;
      double phi2 = lat2 * pi / 180;
      double deltaPhi = (lat2 - lat1) * pi / 180;
      double deltaLambda = (lon2 - lon1) * pi / 180;

      double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
          cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double d = R * c; // Metres

      totalDistance += d;

      previous = locationData;
    }

    SettingsModel settings = Provider.of<SettingsModel>(context, listen: false);
    double usage;

    switch (settings.settings.efficiencyType) {
      case EfficiencyType.kilometresPerLitre:
        usage = (totalDistance / 100) / settings.settings.efficiency;
        break;
      case EfficiencyType.litresPer100Kilometres:
        usage = (totalDistance / 100) / 100 * 14;
        break;
      default:
        usage = 0;
        break;
    }

    NewJourney journey = NewJourney(
        coordinates: _journey,
        start: start,
        end: end,
        distance: totalDistance,
        usage: usage);

    journeys.addJourney(journey);
    journeys.saveToStorage();
  }

  @override
  Widget build(BuildContext context) {
    var locationModel = Provider.of<LocationModel>(context, listen: false);

    Future<bool> showExitPopup() async {
      return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: const Text('Save and stop recording?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No')),
                  TextButton(
                      onPressed: () {
                        stopRecording();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Yes'))
                ],
              ));
    }

    if (locationModel.hasPermissionAndService() && _journey.isNotEmpty) {
      return WillPopScope(
          onWillPop: showExitPopup,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Journey'),
            ),
            body: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              mapType: MapType.normal,
              myLocationEnabled: true,
              compassEnabled: true,
              polylines: Set<Polyline>.of(_polyLines.values),
              initialCameraPosition: CameraPosition(
                  target: LatLng(_journey[0].latitude, _journey[0].longitude),
                  zoom: 18.0),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: FloatingActionButton(
              tooltip: 'Stop recording',
              onPressed: () {
                showExitPopup()
                    .then((value) => {if (value) Navigator.of(context).pop()});
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            ),
          ));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Journey'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ));
    }
  }
}
