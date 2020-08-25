import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RouteProvider with ChangeNotifier {
  bool isActive = false;
  List<Position> _positions = [];
  var totalDistance = 0.0;

  List<Position> get positions {
    return [..._positions];
  }

  Future<void> addPoint() async {
    _positions.add(await Geolocator().getCurrentPosition());
  }

  Future<double> getDistance(List<Position> points) async {
    double distanceInMeters = 0;
    //sorts by timestamp
    points.sort((position1, position2) =>
        position1.timestamp.compareTo(position2.timestamp));
    //calculates
    for (int i = 1; i < _positions.length; i++) {
      //print(i);
      distanceInMeters += await Geolocator().distanceBetween(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude);
    }
    return distanceInMeters;
  }

  Future<void> setTotalDistance() async {
    totalDistance = await getDistance(positions);
    print("total distąs $totalDistance");
  }

  void fetchAndSetPositions() async {
    //TODO: IMPLEMENT FETCHING OF COORDINATES FROM SQL DATABASE
  }

  void toggleRoute(Function function) {
    if (!isActive)
      startRoute();
    else
      endRoute(function);
    notifyListeners();
  }

  void startRoute() {
    //start gps tracker
    isActive = true;
  }

  void endRoute(Function function) {
    isActive = false;
    function();

    //clear database
  }
}
