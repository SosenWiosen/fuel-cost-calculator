import 'package:flutter/material.dart';

import '../widgets/main_drawer.dart';

class SummaryScreen extends StatefulWidget {
  static const routeName = "/summary";

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("Summary!"),
      ),
    );
  }
}
