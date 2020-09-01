import 'dart:async';

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

  static void startLocationService() {
    Timer.periodic(
      Duration(seconds: 2),
      (timer) {
        addPoint();
      },
    );
  }

  static void addPoint() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    if (prefs.getBool("isActive") ?? false) {
      var currPos = await getCurrentPosition();
      print('debug');
      await DBHelper.insert(
          DBHelper.gpsPointsTableName, MappingHelper.mapPosition(currPos));
    }
  }

  Future<void> setTotalDistance() async {
    totalDistance = await getDistance(positions);
  }

  Future<void> fetchAndSetPositions() async {
    final dataList = await DBHelper.getData(DBHelper.gpsPointsTableName);
    _positions =
        dataList.map((map) => MappingHelper.convertMapToPosition(map)).toList();
    notifyListeners();
  }

  void toggleRoute(Function function) {
    if (!isActive)
      startRoute();
    else
      endRoute(function);
    notifyListeners();
  }

  Future<void> fetchAndSetIsActiveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isActive = prefs.getBool("isActive") ?? false;
  }

  void startRoute() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isActive", true);
    final db = await DBHelper.database();
    isActive = true;
  }

  void endRoute(Function function) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isActive", false);
    print(prefs.getBool("isActive"));
    isActive = false;
    function();
  }
}
