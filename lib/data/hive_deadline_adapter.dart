import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/deadline.dart';

/// Hive adapter for Deadline model.
/// Stores deadlines as JSON strings to avoid Hive type conversion issues.
class HiveDeadlineAdapter {
  static const String boxName = 'deadlines_v2';

  static Future<Box<String>> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<String>(boxName);
    }
    return Hive.box<String>(boxName);
  }

  static Deadline fromHiveValue(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Deadline.fromJson(json);
  }

  static String toHiveValue(Deadline deadline) {
    return jsonEncode(deadline.toJson());
  }
}
