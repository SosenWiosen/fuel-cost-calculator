import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/person_provider.dart';
import 'providers/route_provider.dart';
import 'screens/route_screen.dart';
import 'screens/summary_screen.dart';

void main() {
  runApp(MyApp());
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
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
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
