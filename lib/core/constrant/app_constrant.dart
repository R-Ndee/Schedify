class AppConstants {
  // Calendar
  static const int calendarFirstYear = 2020;
  static const int calendarLastYear = 2030;
  
  // Categories
  static const List<String> eventCategories = [
    'Personal',
    'Work',
    'Meeting',
    'Birthday',
    'Holiday',
    'Other',
  ];
  
  // Colors for categories
  static const Map<String, String> categoryColors = {
    'Personal': '#4CAF50',
    'Work': '#2196F3',
    'Meeting': '#FF9800',
    'Birthday': '#E91E63',
    'Holiday': '#9C27B0',
    'Other': '#607D8B',
  };
  
  // Time
  static const List<String> timeSlots = [
    '00:00', '00:30', '01:00', '01:30', '02:00', '02:30',
    '03:00', '03:30', '04:00', '04:30', '05:00', '05:30',
    '06:00', '06:30', '07:00', '07:30', '08:00', '08:30',
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
    '21:00', '21:30', '22:00', '22:30', '23:00', '23:30',
  ];
  
  // ✅ TAMBAHAN: Reminder Options
  static const Map<int, String> reminderOptions = {
    0: 'No reminder',
    5: '5 minutes before',
    15: '15 minutes before',
    30: '30 minutes before',
    60: '1 hour before',
    120: '2 hours before',
    1440: '1 day before',
  };
  
  // ✅ Helper: Get reminder text
  static String getReminderText(int minutes) {
    return reminderOptions[minutes] ?? '$minutes minutes before';
  }
  
  // ✅ Helper: Get all reminder values
  static List<int> getReminderValues() {
    return reminderOptions.keys.toList();
  }
}