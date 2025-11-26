import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
import '../../core/services/notification_service.dart'; // ✅ Import notification service
import 'dart:developer' as developer;

part 'event_provider.g.dart';

// Repository Provider (Singleton)
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// ✅ Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

@riverpod
class EventList extends _$EventList {
  @override
  Future<List<EventModel>> build() async {
    final repository = ref.read(eventRepositoryProvider);
    return await repository.getAllEvents();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(eventRepositoryProvider);
    state = await AsyncValue.guard(() async {
      return await repository.getAllEvents();
    });
  }

  Future<void> addEvent(EventModel event) async {
    final repository = ref.read(eventRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      // ✅ Save to database
      final savedEvent = await repository.createEvent(event);
      
      // ✅ Schedule notification
      if (savedEvent.hasReminder) {
        await notificationService.scheduleEventNotification(savedEvent);
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      return await repository.getAllEvents();
    });
  }

  Future<void> updateEvent(EventModel event) async {
    final repository = ref.read(eventRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // ✅ Update database
      final updatedEvent = await repository.updateEvent(event);
      
      // ✅ Cancel old notification and schedule new one
      await notificationService.cancelEventNotification(event.id);
      if (updatedEvent.hasReminder) {
        await notificationService.scheduleEventNotification(updatedEvent);
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      return await repository.getAllEvents();
    });
  }

  Future<void> deleteEvent(String id) async {
    final repository = ref.read(eventRepositoryProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // ✅ Cancel notification
      await notificationService.cancelEventNotification(id);
      
      // ✅ Delete from database
      await repository.deleteEvent(id);
      
      await Future.delayed(const Duration(milliseconds: 300));
      return await repository.getAllEvents();
    });
  }
  
  Future<void> toggleComplete(EventModel event) async {
    final updatedEvent = event.copyWith(isCompleted: !event.isCompleted);
    await updateEvent(updatedEvent);
  }
}

// Get events by selected date - Simple Provider
@riverpod
Future<List<EventModel>> eventsByDate(
  EventsByDateRef ref,
  DateTime date,
) async {
  final repository = ref.read(eventRepositoryProvider);
  try {
    return await repository.getEventsByDate(date);
  } catch (e) {
    developer.log('Error loading events by date: $e', name: 'EventProvider');
    return [];
  }
}

// Get events for date range
@riverpod
Future<List<EventModel>> eventsByDateRange(
  EventsByDateRangeRef ref,
  DateTime start,
  DateTime end,
) async {
  final repository = ref.read(eventRepositoryProvider);
  try {
    return await repository.getEventsByDateRange(start, end);
  } catch (e) {
    developer.log('Error loading events by date range: $e', name: 'EventProvider');
    return [];
  }
}

// Get single event by ID
@riverpod
Future<EventModel?> eventById(
  EventByIdRef ref,
  String id,
) async {
  final repository = ref.read(eventRepositoryProvider);
  try {
    return await repository.getEventById(id);
  } catch (e) {
    developer.log('Error loading event by ID: $e', name: 'EventProvider');
    return null;
  }
}