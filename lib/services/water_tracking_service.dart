import 'package:hive/hive.dart';
import '../models/drink_entry.dart';

class WaterTrackingService {
  static const String boxName = 'water_entries';

  Box get _box => Hive.box(boxName);

  // Add drink entry
  Future<void> addDrinkEntry(DrinkEntry entry) async {
    // Always store timestamp as local
    final localEntry = entry.copyWith(timestamp: entry.timestamp.toLocal());
    await _box.put(localEntry.id, localEntry.toJson());
  }

  // Get drink entries for a specific date
  Future<List<DrinkEntry>> getDrinkEntriesForDate(DateTime date) async {
    try {
      final localDate = date.toLocal();
      final rawList = _box.values.where((e) => e is Map).toList();
      
      final entries = <DrinkEntry>[];
      for (final rawEntry in rawList) {
        try {
          // Safe casting with null checks
          final Map<String, dynamic> safeMap = _castToStringDynamicMap(rawEntry);
          final entry = DrinkEntry.fromJson(safeMap);
          
          final t = entry.timestamp.toLocal();
          final match = t.year == localDate.year && t.month == localDate.month && t.day == localDate.day;
          
          if (!match) {
            print('Entry not matched: entry=${t.toIso8601String()} query=${localDate.toIso8601String()}');
          } else {
            print('Entry matched: entry=${t.toIso8601String()} query=${localDate.toIso8601String()}');
            entries.add(entry);
          }
        } catch (e) {
          print('Error parsing entry: $e');
          print('Raw entry data: $rawEntry');
          // Skip this entry and continue with others
          continue;
        }
      }
      
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      print('Error in getDrinkEntriesForDate: $e');
      return [];
    }
  }

  // Get drink entries for a date range
  Future<List<DrinkEntry>> getDrinkEntriesForRange(DateTime startDate, DateTime endDate) async {
    try {
      final rawList = _box.values.where((e) => e is Map).toList();
      
      final entries = <DrinkEntry>[];
      for (final rawEntry in rawList) {
        try {
          final Map<String, dynamic> safeMap = _castToStringDynamicMap(rawEntry);
          final entry = DrinkEntry.fromJson(safeMap);
          
          if (entry.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) && 
              entry.timestamp.isBefore(endDate)) {
            entries.add(entry);
          }
        } catch (e) {
          print('Error parsing entry in range: $e');
          continue;
        }
      }
      
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      print('Error in getDrinkEntriesForRange: $e');
      return [];
    }
  }

  // Helper method to safely cast Map to Map<String, dynamic>
  Map<String, dynamic> _castToStringDynamicMap(dynamic rawMap) {
    if (rawMap is Map<String, dynamic>) {
      return rawMap;
    } else if (rawMap is Map) {
      // Convert all keys to strings and handle nested maps if needed
      final result = <String, dynamic>{};
      rawMap.forEach((key, value) {
        final stringKey = key.toString();
        if (value is Map && value is! Map<String, dynamic>) {
          result[stringKey] = _castToStringDynamicMap(value);
        } else {
          result[stringKey] = value;
        }
      });
      return result;
    } else {
      throw ArgumentError('Expected Map, got ${rawMap.runtimeType}');
    }
  }

  // Update drink entry
  Future<void> updateDrinkEntry(String entryId, DrinkEntry updatedEntry) async {
    await _box.put(entryId, updatedEntry.toJson());
  }

  // Delete drink entry
  Future<void> deleteDrinkEntry(String entryId) async {
    await _box.delete(entryId);
  }

  // Delete all drink entries for a specific date
  Future<void> deleteDrinkEntriesForDate(DateTime date) async {
    final entries = await getDrinkEntriesForDate(date);
    for (final entry in entries) {
      await _box.delete(entry.id);
    }
  }

  // Get daily total for a specific date
  Future<double> getDailyTotal(DateTime date) async {
    final entries = await getDrinkEntriesForDate(date);
    double total = 0.0;
    for (DrinkEntry entry in entries) {
      total += entry.effectiveVolumeMl;
    }
    return total;
  }

  // Get weekly total
  Future<double> getWeeklyTotal(DateTime startOfWeek) async {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final entries = await getDrinkEntriesForRange(startOfWeek, endOfWeek);
    double total = 0.0;
    for (DrinkEntry entry in entries) {
      total += entry.effectiveVolumeMl;
    }
    return total;
  }

  // Get monthly total
  Future<double> getMonthlyTotal(DateTime startOfMonth) async {
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 1);
    final entries = await getDrinkEntriesForRange(startOfMonth, endOfMonth);
    double total = 0.0;
    for (DrinkEntry entry in entries) {
      total += entry.effectiveVolumeMl;
    }
    return total;
  }

  // Get streak count
  Future<int> getCurrentStreak() async {
    DateTime currentDate = DateTime.now();
    int streak = 0;
    while (true) {
      double dailyTotal = await getDailyTotal(currentDate);
      if (dailyTotal > 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // Get drink type statistics
  Future<Map<String, int>> getDrinkTypeStats(DateTime startDate, DateTime endDate) async {
    final entries = await getDrinkEntriesForRange(startDate, endDate);
    Map<String, int> stats = {};
    for (DrinkEntry entry in entries) {
      stats[entry.drinkType] = (stats[entry.drinkType] ?? 0) + 1;
    }
    return stats;
  }
}