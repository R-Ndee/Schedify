import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/event_model.dart';
import 'dart:developer' as developer;

class EventRepository {
  final AppDatabase _database = AppDatabase.instance;
  final _uuid = const Uuid();

  // ✅ Helper method untuk normalisasi tanggal yang konsisten
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final db = await _database.database;
      final results = await db.query(
        AppDatabase.tableEvents,
        orderBy: 'date DESC, startTime DESC',
      );
      
      developer.log('getAllEvents: Found ${results.length} events', name: 'EventRepository');
      
      if (results.isEmpty) return [];
      
      return results.map((map) {
        try {
          final event = EventModel.fromJson(_parseMap(map));
          developer.log('Parsed event: ${event.title} on ${event.date}', name: 'EventRepository');
          return event;
        } catch (e) {
          developer.log('Error parsing event: $e', name: 'EventRepository');
          developer.log('Map data: $map', name: 'EventRepository');
          rethrow;
        }
      }).toList();
    } catch (e) {
      developer.log('Error in getAllEvents: $e', name: 'EventRepository');
      return [];
    }
  }

  Future<List<EventModel>> getEventsByDate(DateTime date) async {
    try {
      final db = await _database.database;
      
      // ✅ FIX CRITICAL: Normalisasi tanggal dan gunakan format yang konsisten
      final normalizedDate = _normalizeDate(date);
      
      // Simpan tanggal sebagai string tanpa waktu (YYYY-MM-DD)
      final dateStr = '${normalizedDate.year.toString().padLeft(4, '0')}-'
                     '${normalizedDate.month.toString().padLeft(2, '0')}-'
                     '${normalizedDate.day.toString().padLeft(2, '0')}';
      
      developer.log('Searching events for date: $dateStr (from $date)', name: 'EventRepository');
      
      // ✅ Query menggunakan LIKE untuk mencocokkan tanggal saja (tanpa waktu)
      final results = await db.query(
        AppDatabase.tableEvents,
        where: "date LIKE ?",
        whereArgs: ['$dateStr%'],
        orderBy: 'startTime ASC',
      );
      
      developer.log('getEventsByDate: Found ${results.length} events for $dateStr', name: 'EventRepository');
      
      if (results.isEmpty) return [];
      
      return results.map((map) {
        try {
          return EventModel.fromJson(_parseMap(map));
        } catch (e) {
          developer.log('Error parsing event by date: $e', name: 'EventRepository');
          rethrow;
        }
      }).toList();
    } catch (e) {
      developer.log('Error in getEventsByDate: $e', name: 'EventRepository');
      return [];
    }
  }
  
  Future<List<EventModel>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await _database.database;
      
      // Normalize dates
      final normalizedStart = _normalizeDate(start);
      final normalizedEnd = _normalizeDate(end);
      
      final results = await db.query(
        AppDatabase.tableEvents,
        where: 'date >= ? AND date <= ?',
        whereArgs: [
          normalizedStart.toIso8601String(),
          normalizedEnd.toIso8601String(),
        ],
        orderBy: 'date ASC, startTime ASC',
      );
      
      if (results.isEmpty) return [];
      
      return results.map((map) {
        try {
          return EventModel.fromJson(_parseMap(map));
        } catch (e) {
          developer.log('Error parsing event by date range: $e', name: 'EventRepository');
          rethrow;
        }
      }).toList();
    } catch (e) {
      developer.log('Error in getEventsByDateRange: $e', name: 'EventRepository');
      return [];
    }
  }

  Future<EventModel?> getEventById(String id) async {
    try {
      final db = await _database.database;
      
      final results = await db.query(
        AppDatabase.tableEvents,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      
      return EventModel.fromJson(_parseMap(results.first));
    } catch (e) {
      developer.log('Error in getEventById: $e', name: 'EventRepository');
      return null;
    }
  }

  Future<EventModel> createEvent(EventModel event) async {
    try {
      final db = await _database.database;
      
      // ✅ Normalisasi tanggal dengan benar
      final normalizedDate = _normalizeDate(event.date);
      
      final newEvent = event.copyWith(
        id: event.id.isEmpty ? _uuid.v4() : event.id,
        date: normalizedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final mapData = _toMap(newEvent);
      developer.log('Creating event with data: $mapData', name: 'EventRepository');
      
      await db.insert(
        AppDatabase.tableEvents,
        mapData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      developer.log('Event created successfully: ${newEvent.title} on ${newEvent.date}', name: 'EventRepository');
      
      return newEvent;
    } catch (e) {
      developer.log('Error in createEvent: $e', name: 'EventRepository');
      throw Exception('Failed to create event: $e');
    }
  }

  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final db = await _database.database;
      
      // Normalize the date
      final normalizedDate = _normalizeDate(event.date);
      
      final updatedEvent = event.copyWith(
        date: normalizedDate,
        updatedAt: DateTime.now(),
      );
      
      final count = await db.update(
        AppDatabase.tableEvents,
        _toMap(updatedEvent),
        where: 'id = ?',
        whereArgs: [event.id],
      );
      
      if (count == 0) {
        throw Exception('Event not found');
      }
      
      developer.log('Event updated successfully: ${updatedEvent.title}', name: 'EventRepository');
      
      return updatedEvent;
    } catch (e) {
      developer.log('Error in updateEvent: $e', name: 'EventRepository');
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      final db = await _database.database;
      
      final count = await db.delete(
        AppDatabase.tableEvents,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count == 0) {
        throw Exception('Event not found');
      }
      
      developer.log('Event deleted successfully: $id', name: 'EventRepository');
    } catch (e) {
      developer.log('Error in deleteEvent: $e', name: 'EventRepository');
      throw Exception('Failed to delete event: $e');
    }
  }
  
  // ✅ Method _toMap yang diperbaiki
  Map<String, dynamic> _toMap(EventModel event) {
  final normalizedDate = _normalizeDate(event.date);
  
  return {
    'id': event.id,
    'title': event.title,
    'description': event.description,
    'date': normalizedDate.toIso8601String(),
    'startTime': event.startTime.toIso8601String(),
    'endTime': event.endTime.toIso8601String(),
    'category': event.category,
    'color': event.color,
    'isCompleted': event.isCompleted ? 1 : 0,
    // ✅ TAMBAHKAN INI:
    'hasReminder': event.hasReminder ? 1 : 0,
    'reminderMinutes': event.reminderMinutes,
    'createdAt': event.createdAt?.toIso8601String(),
    'updatedAt': event.updatedAt?.toIso8601String(),
  };
}
  
  Map<String, dynamic> _parseMap(Map<String, Object?> map) {
  final parsed = <String, dynamic>{};
  
  parsed['id'] = map['id'] as String? ?? _uuid.v4();
  parsed['title'] = map['title'] as String? ?? '';
  parsed['description'] = map['description'] as String? ?? '';
  parsed['category'] = map['category'] as String? ?? 'Personal';
  parsed['color'] = map['color'] as String? ?? '#2196F3';
  
  // Parse booleans
  parsed['isCompleted'] = (map['isCompleted'] as int? ?? 0) == 1;
  // ✅ TAMBAHKAN INI:
  parsed['hasReminder'] = (map['hasReminder'] as int? ?? 1) == 1;
  parsed['reminderMinutes'] = map['reminderMinutes'] as int? ?? 15;
  
  final dateValue = map['date'];
  if (dateValue is String && dateValue.isNotEmpty) {
    try {
      final parsedDate = DateTime.parse(dateValue);
      final normalized = _normalizeDate(parsedDate);
      parsed['date'] = normalized.toIso8601String();
    } catch (e) {
      developer.log('Error parsing date: $e, value: $dateValue', name: 'EventRepository');
      parsed['date'] = _normalizeDate(DateTime.now()).toIso8601String();
    }
  } else {
    parsed['date'] = _normalizeDate(DateTime.now()).toIso8601String();
  }
  
  final startTimeValue = map['startTime'];
  if (startTimeValue is String && startTimeValue.isNotEmpty) {
    try {
      parsed['startTime'] = DateTime.parse(startTimeValue).toIso8601String();
    } catch (e) {
      parsed['startTime'] = DateTime.now().toIso8601String();
    }
  } else {
    parsed['startTime'] = DateTime.now().toIso8601String();
  }
  
  final endTimeValue = map['endTime'];
  if (endTimeValue is String && endTimeValue.isNotEmpty) {
    try {
      parsed['endTime'] = DateTime.parse(endTimeValue).toIso8601String();
    } catch (e) {
      parsed['endTime'] = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
    }
  } else {
    parsed['endTime'] = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
  }
  
  final createdAtValue = map['createdAt'];
  if (createdAtValue is String && createdAtValue.isNotEmpty) {
    try {
      parsed['createdAt'] = DateTime.parse(createdAtValue).toIso8601String();
    } catch (e) {
      developer.log('Error parsing createdAt: $e', name: 'EventRepository');
    }
  }
  
  final updatedAtValue = map['updatedAt'];
  if (updatedAtValue is String && updatedAtValue.isNotEmpty) {
    try {
      parsed['updatedAt'] = DateTime.parse(updatedAtValue).toIso8601String();
    } catch (e) {
      developer.log('Error parsing updatedAt: $e', name: 'EventRepository');
    }
  }
  
  return parsed;
}
  
  // Debug method to check all events in database
  Future<void> debugPrintAllEvents() async {
    try {
      final db = await _database.database;
      final results = await db.query(AppDatabase.tableEvents);
      
      developer.log('========== ALL EVENTS IN DATABASE ==========', name: 'EventRepository');
      developer.log('Total events: ${results.length}', name: 'EventRepository');
      for (var map in results) {
        developer.log('---', name: 'EventRepository');
        developer.log('ID: ${map['id']}', name: 'EventRepository');
        developer.log('Title: ${map['title']}', name: 'EventRepository');
        developer.log('Date: ${map['date']}', name: 'EventRepository');
        developer.log('Start: ${map['startTime']}', name: 'EventRepository');
        developer.log('End: ${map['endTime']}', name: 'EventRepository');
      }
      developer.log('============================================', name: 'EventRepository');
    } catch (e) {
      developer.log('Error in debugPrintAllEvents: $e', name: 'EventRepository');
    }
  }
}