import 'package:flutter/material.dart';

import '../screens/route_screen.dart';
import '../screens/summary_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile({
    IconData icon,
    String text,
    Function onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: double.infinity,
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Calculate your costs!",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          buildListTile(
            icon: Icons.directions_car,
            text: "Current Route",
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(RouteScreen.routeName),
          ),
          buildListTile(
            icon: Icons.attach_money,
            text: "Summary",
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(SummaryScreen.routeName),
          ),
        ],
      ),
    );
  }
}
