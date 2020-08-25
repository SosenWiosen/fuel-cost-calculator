import 'package:flutter/material.dart';
import 'package:fuel_cost_calculator/provider/person_provider.dart';
import 'package:fuel_cost_calculator/provider/route_provider.dart';
import 'package:fuel_cost_calculator/widgets/main_drawer.dart';
import 'package:fuel_cost_calculator/widgets/person_input.dart';
import 'package:fuel_cost_calculator/widgets/route_person.dart';
import 'package:provider/provider.dart';

class RouteScreen extends StatefulWidget {
  static const routeName = "/route";

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  @override
  Widget build(BuildContext context) {
    final persons = Provider.of<PersonProvider>(context).persons;
    final routes = Provider.of<RouteProvider>(context);
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("Current route"),
        actions: [
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: routes.toggleRoute,
          )
        ],
      ),
      body: Column(
        children: [
          !routes.isActive
              ? PersonInput()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Route in progress!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
          Expanded(
            child: ListView.builder(
              itemCount: persons.length,
              itemBuilder: (ctx, index) => RoutePerson(persons[index].id),
            ),
          ),
        ],
      ),
    );
  }
}
