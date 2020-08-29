import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/person_provider.dart';
import '../providers/route_provider.dart';
import '../widgets/main_drawer.dart';
import '../widgets/person_input.dart';
import '../widgets/route_person.dart';

class RouteScreen extends StatefulWidget {
  static const routeName = "/route";

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<RouteProvider>(context, listen: false)
          .fetchAndSetIsActiveStatus();
      await Provider.of<PersonProvider>(context, listen: false)
          .fetchAndSetPersons();
      setState(() {
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

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
            onPressed: () {
              routes.toggleRoute(
                Provider.of<PersonProvider>(context, listen: false)
                    .stopDrivingAll,
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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
                  child: persons.isEmpty
                      ? Center(
                          child: Text("No persons currently added!"),
                        )
                      : ListView.builder(
                          itemCount: persons.length,
                          itemBuilder: (ctx, index) =>
                              RoutePerson(persons[index].id),
                        ),
                ),
              ],
            ),
    );
  }
}
