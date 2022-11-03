import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_distance/models/database_model.dart';
import 'package:travel_distance/models/journeys_model.dart';
import 'package:travel_distance/models/location_model.dart';
import 'package:travel_distance/screens/fix_permission.dart';
import 'package:travel_distance/screens/journey_details.dart';
import 'package:travel_distance/screens/journeys.dart';
import 'package:travel_distance/screens/tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseModel.init();

  runApp(const TravelDistance());
}

class TravelDistance extends StatelessWidget {
  const TravelDistance({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => JourneysModel()),
          ChangeNotifierProvider(create: (context) => LocationModel())
        ],
        child: MaterialApp(
          title: 'Travel Distance',
          initialRoute: '/',
          routes: {
            '/': (context) => const Journeys(),
            '/details': (context) => const JourneyDetails(),
            '/tracker': (context) => const Tracker(),
            '/fix-permissions': (context) => const FixPermission()
          },
          theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff792bff))
                    .copyWith(primary: const Color(0xff792bff)),
          ),
        ));
  }
}
