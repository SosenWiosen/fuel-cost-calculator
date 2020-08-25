import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class PersonProvider with ChangeNotifier {
  PersonProvider(
    this._positions,
    this._persons,
  );

  List<Position> _positions;
  List<Person> _persons = [];

  List<Person> get persons {
    return [..._persons];
  }

  Person getPerson(String id) {
    return _persons.where((element) => element.id == id).first;
  }

  Future<double> getDistance(List<Position> points) async {
    double distanceInMeters = 0;
    //sorts by timestamp
    points.sort((position1, position2) =>
        position1.timestamp.compareTo(position2.timestamp));
    print("getting distąs");
    //calculates
    for (int i = 1; i < points.length; i++) {
      distanceInMeters += await Geolocator().distanceBetween(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude);
    }
    return distanceInMeters;
  }

  Future<void> setPersonsDistance() async {
    double personDistanceInMeters = 0;

    _persons.forEach((person) {
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
        personDistanceInMeters += await getDistance(pointsWhileDriving);
      }); /**/
      /*print(
          "printing person distance $personDistanceInMeters of ${person.name}");*/
      person.metersDriven = personDistanceInMeters;
      notifyListeners();
    });
    //calculates distance for each drivingTime,
  }

  void stopDrivingAll() {
    _persons.forEach((element) {
      element.isDriving = false;
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

  void toggleIsDriving(bool val) {
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
    print(drivingTime);
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
