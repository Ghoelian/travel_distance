import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:travel_distance/dto/journey_dto.dart';
import 'package:travel_distance/models/journeys_model.dart';

class Tracker extends StatefulWidget {
  const Tracker({Key? key}) : super(key: key);

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final List<Coordinate> _journey = [];
  bool? _serviceEnabled;
  final Map<PolylineId, Polyline> _polyLines = {};
  int _polyLineIdCounter = 1;
  PermissionStatus? _permissionGranted;
  final Location _location = Location();
  late StreamSubscription _locationStream;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      checkLocationPermissions().then((hasPermission) async {
        if (hasPermission) {
          _location.enableBackgroundMode(enable: true);

          LocationData locationData = await _location.getLocation();

          setState(() {
            _journey.add(Coordinate(
                latitude: locationData.latitude!,
                longitude: locationData.longitude!));
          });

          _locationStream =
              _location.onLocationChanged.listen((LocationData location) {
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
                  latitude: location.latitude!,
                  longitude: location.longitude!));

              _polyLines[polylineId] = polyline;
            });
          });
        } else {
          Navigator.of(context).pushNamed('/fix-permissions');
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _locationStream.cancel();
  }

  void stopRecording() {
    JourneysModel journeys = Provider.of<JourneysModel>(context, listen: false);
    double totalDistance = 0;
    Coordinate? previous;

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

    Journey journey = Journey(
        coordinates: _journey, date: DateTime.now(), distance: totalDistance);
    journeys.addJourney(journey);
    journeys.saveToStorage();

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Journey saved')));
  }

  Future<bool> checkLocationPermissions() async {
    _serviceEnabled = await _location.serviceEnabled();

    if (!_serviceEnabled!) {
      _serviceEnabled = await _location.requestService();

      if (!_serviceEnabled!) {
        return Future.value(false);
      }
    }

    _permissionGranted = await _location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return Future.value(false);
      }
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_serviceEnabled != null &&
        _serviceEnabled! &&
        _permissionGranted == PermissionStatus.granted &&
        _journey.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Journey'),
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          myLocationEnabled: true,
          compassEnabled: true,
          polylines: Set<Polyline>.of(_polyLines.values),
          initialCameraPosition: CameraPosition(
              target: LatLng(_journey[0].latitude, _journey[0].longitude),
              zoom: 15),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            stopRecording();
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.stop),
        ),
      );
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
