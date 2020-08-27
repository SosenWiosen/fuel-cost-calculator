import 'package:flutter/material.dart';
import 'package:fuel_cost_calculator/providers/person_provider.dart';
import 'package:fuel_cost_calculator/providers/route_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/main_drawer.dart';

class SummaryScreen extends StatefulWidget {
  static const routeName = "/summary";

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  var fuelCost = 0.0;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<RouteProvider>(context, listen: false)
          .fetchAndSetPositions();
      await Provider.of<RouteProvider>(context, listen: false)
          .setTotalDistance();
      await Provider.of<PersonProvider>(context, listen: false)
          .setPersonsDistance();
      setState(() {
        _isLoading=false;
      });
      /*Provider.of<RouteProvider>(context, listen: false)
          .fetchAndSetPositions()
          .then((value) {
        Provider.of<RouteProvider>(context, listen: false)
            .setTotalDistance()
            .then((_) {
          Provider.of<PersonProvider>(context, listen: false)
              .setPersonsDistance()
              .then((_) {
            setState(() {
              _isLoading = false;
            });
          });
        });
      });*/
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final persons = Provider.of<PersonProvider>(context).persons;
    final totalDistance =
        Provider.of<PersonProvider>(context).totalDistanceByAllPersons;
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("Summary"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          decoration:
                              InputDecoration(labelText: "Total fuel cost"),
                          onChanged: (val) {
                            try {
                              fuelCost = double.tryParse(val.trim());
                            } catch (error) {
                              return;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          Text("Person:"),
                          Text("Distance Driven: "),
                          Text("Cost:"),
                        ],
                      ),
                      ...persons.map((person) {
//                        print("ehh$totalDistance");
                        return TableRow(
                          children: [
                            Text(person.name),
                            Text("${person.metersDriven.toStringAsFixed(0)}m"),
                            Text(
                              totalDistance == 0.0
                                  ? "0 zł"
                                  : "${(fuelCost * person.metersDriven / totalDistance).toStringAsFixed(0)} zł",
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
