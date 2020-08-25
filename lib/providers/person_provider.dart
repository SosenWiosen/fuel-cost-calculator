import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class PersonProvider with ChangeNotifier {
  PersonProvider(this._positions,
      this._persons,);

  List<Position> _positions;
  List<Person> _persons = [];

  double get totalDistanceByAllPersons {
    var sum = 0.0;
    _persons.forEach((element) {
      sum += element.metersDriven;
    });
    return sum;
  }

  List<Person> get persons {
    return [..._persons];
  }

  Person getPerson(String id) {
    return _persons
        .where((element) => element.id == id)
        .first;
  }

  Future<double> getDistance(List<Position> points) async {
    double distanceInMeters = 0;
    //sorts by timestamp
    points.sort((position1, position2) =>
        position1.timestamp.compareTo(position2.timestamp));
    // print("getting distąs");
    //print(points.length);
    //calculates
    for (int i = 1; i < points.length; i++) {
      // print(i);
      //print(points[i].latitude);
      distanceInMeters += await Geolocator().distanceBetween(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude);
      /*print(
        " distans in iteration$i is${distanceInMeters*/ /*await Geolocator().distanceBetween(points[i - 1].latitude, points[i - 1].longitude, points[i].latitude, points[i].longitude)*/ /*}",
      );*/
    }
    return distanceInMeters;
  }

  Future<void> setPersonsDistance() async {
    double personDistanceInMeters = 0.0;

    _persons.forEach((person) async {
//      print(person.drivingTimes.toString());
      person.drivingTimes.forEach((drivingTime) async {
        //gets points in given drivingTime and calculates the distance
        List<Position> pointsWhileDriving = _positions
            .where(
              (position) =>
          (position.timestamp.isAfter(drivingTime.startedDriving) &&
              position.timestamp.isBefore(drivingTime.stoppedDriving)),
        )
            .toList();
//        print("calculating distęs");
        //adds distance for a given points between a given timestamp
        person.metersDriven += await getDistance(pointsWhileDriving);
        //print(" this is inside the function${person.metersDriven}");
      }); /**/

      /*print(
          "printing person distance $personDistanceInMeters of ${person.name}");*/

      // print(person.metersDriven);
      notifyListeners();
    });
    //calculates distance for each drivingTime,
  }

  void stopDrivingAll() {
    _persons.forEach((element) {
      if (element.isDriving) {
        element.toggleIsDriving();
      }
    });
  }

  void addPerson(String name) {
    _persons.add(Person(name, DateTime.now().toString()));
    notifyListeners();
  }

  void deletePerson(String id) {
    _persons.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  int getPersonCount() {
    return _persons.length;
  }
}

class Person with ChangeNotifier {
  bool isDriving = false;
  String id;
  String name = "";
  DateTime _lastStart;
  double metersDriven = 0;

  Person(this.name, this.id);

  List<DrivingDateTime> _drivingTimes = [];

  List<DrivingDateTime> get drivingTimes {
    return [..._drivingTimes];
  }

  void toggleIsDriving() {
    if (isDriving == false) {
      print(isDriving);
      final currDateTime = DateTime.now();
      _drivingTimes.add(DrivingDateTime(currDateTime));

      _lastStart = currDateTime;
      isDriving = !isDriving;
      notifyListeners();
      return;
    }

    final drivingTime = _drivingTimes
        .where((element) => element.startedDriving == _lastStart)
        .first;
    drivingTime.stoppedDriving = DateTime.now();
    isDriving = !isDriving;
    notifyListeners();
  }
}

class DrivingDateTime {
  DateTime startedDriving;
  DateTime stoppedDriving;

  DrivingDateTime(this.startedDriving);
}
