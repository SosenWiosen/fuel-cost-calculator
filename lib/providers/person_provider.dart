import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuel_cost_calculator/helpers/db_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:min_id/min_id.dart';
import 'package:sqflite/sqflite.dart';

class PersonProvider with ChangeNotifier {
  PersonProvider(
    this._positions,
    this._persons,
  );

  List<Position> _positions;
  List<Person> _persons = [];

  double get totalDistanceByAllPersons {
    var sum = 0.0;
    _persons.forEach((element) {
      sum += element.metersDriven;
    });
    return sum;
  }

  void addPerson(String name) {
    //print("fuick");
    Person person = Person(name,
        DateTime.now().toString().replaceAll(" ", "").replaceAll(":", ""));
    //print(person.id);
    _persons.add(person);
    notifyListeners();
    DBHelper.insert(DBHelper.personsTableName, person.toMap());
  }

  void removePerson(String id) async {
    _persons.removeWhere((element) => element.id == id);
    final db = await DBHelper.database();
    await db.delete(DBHelper.personsTableName, where: "id=?", whereArgs: [id]);
  }

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

    _persons.forEach((person) async {
//      print(person.drivingTimes.toString());
      person.drivingTimes.forEach((drivingTime) async {
        print("printig da driving times ${drivingTime.startedDriving} ${drivingTime.stoppedDriving}");
        //gets points in given drivingTime and calculates the distance
        print("dose are positions ${_positions}");
        List<Position> pointsWhileDriving = _positions
            .where(
              (position) {
                print("Checking this position: ${position.timestamp} with ${drivingTime.id}");
                print((position.timestamp.isAfter(drivingTime.startedDriving) &&
                    position.timestamp.isBefore(drivingTime.stoppedDriving)));
                return (position.timestamp.isAfter(drivingTime.startedDriving) &&
                    position.timestamp.isBefore(drivingTime.stoppedDriving));
              }

            )
            .toList();
        print("poinds $pointsWhileDriving");
        print("calculating distęs");
        //adds distance for a given points between a given timestamp
        person.metersDriven += await getDistance(pointsWhileDriving);

        //print(" this is inside the function${person.metersDriven}");
      }); /**/

      print(
          "printing person distance ${person.metersDriven} of ${person.name}");

      // print(person.metersDriven);
    });
    notifyListeners();
    //calculates distance for each drivingTime,
  }

  void stopDrivingAll() {
    _persons.forEach((element) {
      if (element.isDriving) {
        element.toggleIsDriving();
      }
    });
  }

  int getPersonCount() {
    return _persons.length;
  }

  Future<void> fetchAndSetPersons() async {
    final personDataList = await DBHelper.getData(DBHelper.personsTableName);
    final drivingTimesDataList =
        await DBHelper.getData(DBHelper.drivingTimesTableName);
    final drivingTimesList = drivingTimesDataList
        .map((drivingTimes) => DrivingDateTime.fromMap(drivingTimes));

    var personsTemp = personDataList
        .map(
          (personMap) => Person.fromMapAndDateTimeList(
            personMap,
            drivingTimesList
                .where((element) => element.userId == personMap["id"])
                .toList(),
          ),
        )
        .toList();

    _persons = personsTemp;
    /*_persons = personDataList.map(
      (personMap) => Person.fromMapAndDateTimeList(
        personMap,
        drivingTimesList
            .where((element) => element.id == personMap["id"])
            .toList(),
      ),
    );*/
  }
}

class Person with ChangeNotifier {
  bool isDriving = false;
  String id;
  String name = "";
  double metersDriven = 0;

  Person(this.name, this.id);

  Person.fromMapAndDateTimeList(Map<String, dynamic> personMap,
      List<DrivingDateTime> drivingDateTimeList) {
    id = personMap["id"];
    name = personMap["name"];
    isDriving = personMap["is_driving"] == "true" ? true : false;
    drivingDateTimeList.sort(
      (drivingDateTime1, drivingDateTime2) => drivingDateTime2.startedDriving
              .isAfter(drivingDateTime1.startedDriving)
          ? 1
          : -1,
    );
    _drivingTimes = drivingDateTimeList;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "is_driving": isDriving.toString(),
    };
  }

  List<DrivingDateTime> _drivingTimes = [];

  List<DrivingDateTime> get drivingTimes {
    return [..._drivingTimes];
  }

  void toggleIsDriving() async {
    if (isDriving == false) {
      var currDrivingTime = DrivingDateTime(DateTime.now(), id);
      _drivingTimes.add(currDrivingTime);
      await DBHelper.insert(
          DBHelper.drivingTimesTableName, currDrivingTime.toMap());

      isDriving = !isDriving;
      notifyListeners();
      print("startin mah drive");
      return;
    }

    final drivingTime = _drivingTimes.last;
    final db = await DBHelper.database();
    drivingTime.stoppedDriving = DateTime.now();
    isDriving = !isDriving;
    print(drivingTime.id);
    db.update(DBHelper.drivingTimesTableName, drivingTime.toMap(),
        where: "id=?",
        whereArgs: [drivingTime.id],
        conflictAlgorithm: ConflictAlgorithm.replace);

    notifyListeners();
    print(isDriving);
  }
}

class DrivingDateTime {
  String id;
  String userId;
  DateTime startedDriving;
  DateTime stoppedDriving;

  Map<String, dynamic> toMap() {
    final stoppedDrivingTemp =
        stoppedDriving == null ? "" : stoppedDriving.toIso8601String();
    return {
      "id": id,
      "user_id": userId,
      "started_driving": startedDriving.toIso8601String(),
      "stopped_driving": stoppedDrivingTemp,
    };
  }

  DrivingDateTime.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    userId = map["user_id"];
    startedDriving = DateTime.parse(map["started_driving"]);
    stoppedDriving =
        (map["stopped_driving"] == null || map["stopped_driving"] == "")
            ? null
            : DateTime.parse(map["stopped_driving"]);
  }

  DrivingDateTime(this.startedDriving, this.userId) {
    id = MinId.getId();
    print("uwuL: $id");
  }
}
