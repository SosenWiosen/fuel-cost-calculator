import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RouteProvider with ChangeNotifier {
  DateTime _routeStart;
  DateTime _routeEnd;
  bool isActive = false;
  List<Position> _positionsList = [];

  double getTotalDistance(){
    //TODO: IMPLEMENT CALCULATING TOTAL DISTANCE
    return 0;
  }

  void fetchAndSetPositions() async {
    //TODO: IMPLEMENT FETCHING OF COORDINATES FROM SQL DATABASE
  }
  void toggleRoute()
  {
    if(!isActive)
      startRoute();
    else
      endRoute();
    notifyListeners();

  }

  void startRoute() {
    isActive=true;
    _routeStart = DateTime.now();
  }

  void endRoute() {
    isActive=false;
    _routeEnd = DateTime.now();
  }
}
