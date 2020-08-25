import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RouteProvider with ChangeNotifier {
  DateTime _routeStart;
  DateTime _routeEnd;
  List<Position> _positionsList = [];

  void fetchAndSetPositions() async {
    //TODO: IMPLEMENT FETCHING OF COORDINATES FROM SQL DATABASE
  }

  void startRoute() {
    _routeStart = DateTime.now();
  }

  void endRoute() {
    _routeEnd = DateTime.now();
  }
}
