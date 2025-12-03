class NotificationDebugLog {
  static final NotificationDebugLog _instance = NotificationDebugLog._internal();
  
  factory NotificationDebugLog() {
    return _instance;
  }
  
  NotificationDebugLog._internal();
  
  final List<String> _logs = [];
  
  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message';
    
    _logs.add(logEntry);
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }
  }
  
  List<String> getLogs() => List.from(_logs);
  
  void clear() {
    _logs.clear();
  }
  
  String getLogsAsString() {
    return _logs.join('\n');
  }
}
