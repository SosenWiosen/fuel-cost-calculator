import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/person_provider.dart';

class RoutePerson extends StatefulWidget {
  final String id;

  RoutePerson(this.id);

  @override
  _RoutePersonState createState() => _RoutePersonState();
}

class _RoutePersonState extends State<RoutePerson> {
  @override
  Widget build(BuildContext context) {
    final currentPerson =
        Provider.of<PersonProvider>(context).getPerson(widget.id);
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          child: Row(
            children: [
              Checkbox(
                  value: currentPerson.isDriving,
                  onChanged: (val) {
                    setState(() {
                      currentPerson.toggleIsDriving(val);
                    });
                  }),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  currentPerson.name,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
