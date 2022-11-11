import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:travel_distance/models/location_model.dart';
import 'package:url_launcher/url_launcher.dart';

class FixPermission extends StatelessWidget {
  const FixPermission({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationModel>(builder: (context, locationModel, child) {
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  textAlign: TextAlign.center,
                  'This app collects location data to enable journey tracking even when the app is closed or not in use.'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  textAlign: TextAlign.center,
                  'See our Privacy Policy for more details.'),
            ),
            ElevatedButton(
                onPressed: () async {
                  debugPrint('Parsing url');
                  var url = Uri.parse(
                      'https://github.com/Ghoelian/travel_distance/blob/master/PRIVACY_POLICY.md');

                  debugPrint('Checking if can launch');
                  if (await canLaunchUrl(url)) {
                    debugPrint('Can launch');
                    await launchUrl(url);
                  } else {
                    debugPrint('Couldn\'t open url');
                  }
                },
                child: const Text('Privacy policy')),
            Builder(builder: (context) {
              switch (locationModel.permissionGranted) {
                case PermissionStatus.deniedForever:
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            textAlign: TextAlign.center,
                            'You have declined the location permissions.'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            locationModel.checkLocationPermissions();
                          },
                          child: const Text('Fix in settings'))
                    ],
                  );
                case PermissionStatus.grantedLimited:
                  return const Text('Limited');
                case PermissionStatus.granted:
                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            textAlign: TextAlign.center,
                            'Location permission granted'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).popAndPushNamed('/tracker');
                          },
                          child: const Text('Return to journey'))
                    ],
                  );
                case PermissionStatus.denied:
                default:
                  return ElevatedButton(
                      onPressed: () {
                        locationModel.checkAndAskPermissions();
                      },
                      child: const Text('Request permission'));
              }
            })
          ],
        )),
      );
    });
  }
}
