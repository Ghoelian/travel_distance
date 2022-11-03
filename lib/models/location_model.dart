import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class LocationModel extends ChangeNotifier {
  final Location _location = Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;

  get permissionGranted => _permissionGranted;
  get serviceEnabled => _serviceEnabled;

  bool hasPermissionAndService() {
    return ((_serviceEnabled ?? false) && (_permissionGranted == PermissionStatus.granted));
  }

  Future<bool> checkLocationPermissions() async {
    _serviceEnabled = await _location.serviceEnabled();

    if (!_serviceEnabled!) {
      _serviceEnabled = await _location.requestService();

      if (!_serviceEnabled!) {
        notifyListeners();
        return Future.value(false);
      }
    }

    _permissionGranted = await _location.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        notifyListeners();
        return Future.value(false);
      }
    }

    notifyListeners();
    return Future.value(true);
  }
}
