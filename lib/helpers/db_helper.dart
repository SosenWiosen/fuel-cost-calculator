import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBHelper {
  static const String personsTableName = "persons";
  static const String drivingTimesTableName = "driving_times";
  static const String gpsPointsTableName = "gps_points";

  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, "fuel_Cost.db"),
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE $drivingTimesTableName(id TEXT PRIMARY KEY, user_id TEXT, started_driving INT, stopped_driving INT)");
        await db.execute(
            "CREATE TABLE $gpsPointsTableName(timestamp TEXT PRIMARY KEY, loc_lat REAL, loc_lng REAL)");
        return await db.execute(
            "CREATE TABLE $personsTableName(id TEXT PRIMARY KEY, name TEXT, is_driving TEXT)");
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, Object>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }
}
