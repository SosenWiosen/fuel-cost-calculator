import 'package:geolocator/geolocator.dart';

class MappingHelper {
  static Map<String, dynamic> mapPosition(Position position) {
    return {
      "timestamp": position.timestamp.toIso8601String(),
      "loc_lat": position.latitude,
      "loc_lng": position.longitude,
    };
  }

  static Position convertMapToPosition(Map<String, dynamic> positionMap) {
    return Position(
        timestamp: DateTime.parse(positionMap["timestamp"]),
        latitude: positionMap["loc_lat"],
        longitude: positionMap["loc_lng"]);
  }
}
