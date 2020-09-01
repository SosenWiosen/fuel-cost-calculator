import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuel_cost_calculator/helpers/db_helper.dart';
import 'package:fuel_cost_calculator/helpers/mapping_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
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
    Person person = Person(name,
        DateTime.now().toString().replaceAll(" ", "").replaceAll(":", ""));
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

  Future<void> setPersonsDistance() async {
    await fetchAndSetPersons();
    _persons.forEach((person) async {
      person.drivingTimes.forEach((drivingTime) async {
        List<Position> pointsWhileDriving = _positions.where((position) {
          print(
              "Checking this position: ${position.timestamp} with ${drivingTime.id}");
          return (position.timestamp.toUtc().millisecondsSinceEpoch >
                  drivingTime.startedDriving &&
              (drivingTime.stoppedDriving == null
                  ? true
                  : position.timestamp.toUtc().millisecondsSinceEpoch <
                      drivingTime.stoppedDriving));
        }).toList();
        person.metersDriven += await getDistance(pointsWhileDriving);
      });
      print(
          "printing person distance ${person.metersDriven} of ${person.name}");
    });
    notifyListeners();
  }

  void stopDrivingAll() {
//    _persons.forEach((element) {
//      element.toggleIsDriving();
//    });
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
      (drivingDateTime1, drivingDateTime2) =>
          drivingDateTime2.startedDriving > (drivingDateTime1.startedDriving)
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
    final db = await DBHelper.database();
    if (isDriving == false) {
      var currDrivingTime =
          DrivingDateTime(DateTime.now().toUtc().millisecondsSinceEpoch, id);
      _drivingTimes.add(currDrivingTime);
      await DBHelper.insert(
          DBHelper.drivingTimesTableName, currDrivingTime.toMap());
      isDriving = true;
      db.update(DBHelper.personsTableName, toMap(),
          where: "id=?",
          whereArgs: [id],
          conflictAlgorithm: ConflictAlgorithm.replace);
      notifyListeners();
      return;
    }
    isDriving = false;
    db.update(DBHelper.personsTableName, toMap(),
        where: "id=?",
        whereArgs: [id],
        conflictAlgorithm: ConflictAlgorithm.replace);
    var drivingTimesDataList =
        await DBHelper.getData(DBHelper.drivingTimesTableName);
    var drivingTimesList = drivingTimesDataList
        .map((drivingTimes) => DrivingDateTime.fromMap(drivingTimes));
//    try {
    var drivingTime = drivingTimesList.last;
    drivingTime.stoppedDriving = DateTime.now().toUtc().millisecondsSinceEpoch;
    db.update(DBHelper.drivingTimesTableName, drivingTime.toMap(),
        where: "id=?",
        whereArgs: [drivingTime.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
//    } catch (err) {}
    notifyListeners();
    print(isDriving);
  }
}

class DrivingDateTime {
  String id;
  String userId;
  int startedDriving;
  int stoppedDriving;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "user_id": userId,
      "started_driving": startedDriving,
      "stopped_driving": stoppedDriving,
    };
  }

  DrivingDateTime.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    userId = map["user_id"];
    try {
      startedDriving = int.parse(map["started_driving"].toString());
    } catch (err) {}
    try {
      stoppedDriving = int.parse(map["stopped_driving"].toString());
    } catch (err) {}
  }

  DrivingDateTime(this.startedDriving, this.userId) {
    id = MinId.getId();
  }
}
