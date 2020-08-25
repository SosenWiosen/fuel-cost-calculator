import 'package:flutter/material.dart';
import 'package:fuel_cost_calculator/provider/person_provider.dart';
import 'package:fuel_cost_calculator/provider/route_provider.dart';
import 'package:fuel_cost_calculator/screens/route_screen.dart';
import 'package:fuel_cost_calculator/screens/summary_screen.dart';
import 'package:provider/provider.dart';

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
          create: (_) => PersonProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RouteProvider(),
        )
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
