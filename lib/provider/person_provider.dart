import 'package:flutter/foundation.dart';

class PersonProvider with ChangeNotifier {
  List<Person> _persons;

  List<Person> get persons {
    return [..._persons];
  }

  void addPerson(String name) {
    _persons.add(Person(name, DateTime.now().toString()));
    notifyListeners();
  }

  void deletePerson(String id) {
    _persons.removeWhere((element) => element.id == id);
  }

  void toggleIsDriving(String id) {
    _persons.where((element) => element.id == id).first.toggleIsDriving();
  }
}

class Person with ChangeNotifier {
  bool _isDriving = false;
  String id;
  String name = "";
  DateTime _lastStart;

  Person(this.name, this.id);

  List<DrivingDateTime> _drivingTimes = [];

  List<DrivingDateTime> get drivingTimes {
    return [..._drivingTimes];
  }

  void toggleIsDriving() {
    if (_isDriving == false) {
      final currDateTime = DateTime.now();
      _drivingTimes.add(DrivingDateTime(currDateTime));
      _lastStart = currDateTime;
    }
    final index = _drivingTimes
        .indexWhere((element) => element.startedDriving == _lastStart);
    _drivingTimes[index].stoppedDriving = DateTime.now();
  }
}

class DrivingDateTime {
  DateTime startedDriving;
  DateTime stoppedDriving;

  DrivingDateTime(this.startedDriving);
}
