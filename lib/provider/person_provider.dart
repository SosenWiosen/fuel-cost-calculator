import 'package:flutter/foundation.dart';

class PersonProvider with ChangeNotifier {
  List<Person> _persons = [];

  List<Person> get persons {
    return [..._persons];
  }

  Person getPerson(String id) {
    return _persons.where((element) => element.id == id).first;
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
  double kmDriven = 0;

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
