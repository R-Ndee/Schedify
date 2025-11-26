import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_provider.g.dart';

// Selected Date Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Calendar Format Provider
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) {
  return CalendarFormat.month;
});

// Focused Day Provider
final focusedDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Simple Calendar State Data Model (without Freezed)
class CalendarStateData {
  final DateTime selectedDate;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  
  CalendarStateData({
    required this.selectedDate,
    required this.focusedDay,
    required this.calendarFormat,
  });
  
  CalendarStateData copyWith({
    DateTime? selectedDate,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarStateData(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDay: focusedDay ?? this.focusedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }
}

// Calendar Page Controller State
@riverpod
class CalendarState extends _$CalendarState {
  @override
  CalendarStateData build() {
    return CalendarStateData(
      selectedDate: DateTime.now(),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
    );
  }
  
  void updateSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
  
  void updateFocusedDay(DateTime date) {
    state = state.copyWith(focusedDay: date);
  }
  
  void updateCalendarFormat(CalendarFormat format) {
    state = state.copyWith(calendarFormat: format);
  }
  
  void reset() {
    state = CalendarStateData(
      selectedDate: DateTime.now(),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
    );
  }
}