import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

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

Future<double> getDistance(List<Position> points) async {
  double distanceInMeters = 0;
  points.sort((position1, position2) =>
      position1.timestamp.compareTo(position2.timestamp));
  for (int i = 1; i < points.length; i++) {
    final Distance distance = new Distance();
    distanceInMeters += distance(
        LatLng(points[i - 1].latitude, points[i - 1].longitude),
        LatLng(points[i].latitude, points[i].longitude));
  }
  return distanceInMeters;
}