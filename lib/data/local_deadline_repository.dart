import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/deadline.dart';
import 'hive_deadline_adapter.dart';

/// Local-first deadline storage using Hive.
/// Stores deadlines as JSON strings for reliable serialization.
/// Falls back gracefully if Hive is unavailable (e.g. Incognito mode).
class LocalDeadlineRepository {
  Box<String>? _box;
  bool _boxFailed = false;

  Future<Box<String>?> get box async {
    if (_boxFailed) return null;
    try {
      _box ??= await HiveDeadlineAdapter.openBox();
      return _box;
    } catch (e) {
      debugPrint('Failed to open Hive box: $e');
      _boxFailed = true;
      return null;
    }
  }

  Future<List<Deadline>> getAll() async {
    final b = await box;
    if (b == null) return [];
    final deadlines = <Deadline>[];
    for (final value in b.values) {
      try {
        deadlines.add(HiveDeadlineAdapter.fromHiveValue(value));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return deadlines;
  }

  Future<Deadline?> getById(String id) async {
    final b = await box;
    if (b == null) return null;
    final value = b.get(id);
    if (value == null) return null;
    try {
      return HiveDeadlineAdapter.fromHiveValue(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Deadline deadline) async {
    final b = await box;
    if (b == null) return;
    await b.put(deadline.id, HiveDeadlineAdapter.toHiveValue(deadline));
  }

  Future<void> saveAll(List<Deadline> deadlines) async {
    final b = await box;
    if (b == null) return;
    final entries = <String, String>{};
    for (final d in deadlines) {
      entries[d.id] = HiveDeadlineAdapter.toHiveValue(d);
    }
    await b.putAll(entries);
  }

  Future<void> delete(String id) async {
    final b = await box;
    if (b == null) return;
    await b.delete(id);
  }

  Future<void> deleteAll() async {
    final b = await box;
    if (b == null) return;
    await b.clear();
  }

  /// Migrate deadlines from SharedPreferences (old storage) to Hive.
  Future<void> migrateFromList(List<Deadline> deadlines) async {
    if (deadlines.isEmpty) return;
    final b = await box;
    if (b == null) return;
    if (b.isNotEmpty) return; // Already migrated
    await saveAll(deadlines);
  }
}
