import 'dart:io';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';

import 'providers/person_provider.dart';
import 'providers/route_provider.dart';
import 'screens/route_screen.dart';
import 'screens/summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final int pointAdderId = 0;
  await AndroidAlarmManager.initialize();
  if ((await LocationPermissions().requestPermissions()) == PermissionStatus.granted) {
    runApp(MyApp());
    await AndroidAlarmManager.oneShot(
        Duration.zero, pointAdderId, RouteProvider.startLocationService);
  } else
    exit(0);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RouteProvider(),
        ),
        ChangeNotifierProxyProvider<RouteProvider, PersonProvider>(
          create: (_) => null,
          update: (ctx, routes, previousPerson) => PersonProvider(
              routes.positions,
              previousPerson == null ? [] : previousPerson.persons),
        ),
      ],
      child: MaterialApp(
        title: 'Fuel Cost Calculator',
        theme: ThemeData(
          iconTheme: IconThemeData(color: Colors.white),
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          accentColor: Colors.pinkAccent,
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        home: RouteScreen(),
        routes: {
          RouteScreen.routeName: (ctx) => RouteScreen(),
          SummaryScreen.routeName: (ctx) => SummaryScreen(),
        },
      ),
    );
  }
}
