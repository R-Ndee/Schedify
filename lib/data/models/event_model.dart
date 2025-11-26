import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const EventModel._();
  
  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    @Default('Personal') String category,
    @Default('#2196F3') String color,
    @Default(false) bool isCompleted,
    // ✅ TAMBAHAN: Reminder settings
    @Default(true) bool hasReminder,
    @Default(15) int reminderMinutes, // 0=none, 5, 15, 30, 60
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
  
  // Custom getters
  String get duration {
    final diff = endTime.difference(startTime);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Reminder time
  DateTime get reminderTime {
    return startTime.subtract(Duration(minutes: reminderMinutes));
  }
  
  // Reminder text
  String get reminderText {
    if (!hasReminder || reminderMinutes == 0) {
      return 'No reminder';
    }
    
    if (reminderMinutes < 60) {
      return '$reminderMinutes minutes before';
    } else {
      final hours = reminderMinutes ~/ 60;
      return '$hours hour${hours > 1 ? 's' : ''} before';
    }
  }
}