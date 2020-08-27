import 'package:flutter/foundation.dart';
import 'package:fuel_cost_calculator/helpers/db_helper.dart';
import 'package:fuel_cost_calculator/helpers/mapping_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteProvider with ChangeNotifier {
  bool isActive = false;
  List<Position> _positions = [];
  var totalDistance = 0.0;

  List<Position> get positions {
    return [..._positions];
  }

  Future<void> addPoint() async {
    final currPos = await Geolocator().getCurrentPosition();
    _positions.add(currPos);
    await DBHelper.insert(
        DBHelper.gpsPointsTableName, MappingHelper.mapPosition(currPos));
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

  Future<void> fetchAndSetPositions() async {
    final dataList = await DBHelper.getData(DBHelper.gpsPointsTableName);
    _positions =
        dataList.map((map) => MappingHelper.convertMapToPosition(map)).toList();
  }

  void toggleRoute(Function function) {
    if (!isActive)
      startRoute();
    else
      endRoute(function);
    notifyListeners();
  }

  Future<void> fetchAndSetIsActiveStatus() async {
    print("nigga?");
    final prefs = await SharedPreferences.getInstance();
    isActive = prefs.getBool("isActive") ?? false;
  }

  void startRoute() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isActive", true);
    //start gps tracker
    final db = await DBHelper.database();
    db.delete(DBHelper.gpsPointsTableName);
    isActive = true;
  }

  void endRoute(Function function) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isActive", false);
    isActive = false;

    function();

    //clear database
  }
}
