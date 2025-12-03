import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/providers/event_provider.dart';

void showNotificationDebugPanel(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => ref.watch(eventListProvider).when(
      data: (events) {
        final eventsWithReminder = events.where((e) => e.hasReminder).toList();
        final now = DateTime.now();
        
        return AlertDialog(
          title: const Text('📋 Notification Debug'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current time
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⏰ Current Time:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          now.toString(),
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Events with reminder
                  const Text(
                    '📌 Events with Reminder:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  
                  if (eventsWithReminder.isEmpty)
                    const Text(
                      'No events with reminder',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    )
                  else
                    ...eventsWithReminder.map((event) {
                      final notificationTime = event.reminderTime;
                      final willSchedule = notificationTime.isAfter(now);
                      final minUntil = notificationTime.difference(now).inMinutes;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: willSchedule ? Colors.green : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: willSchedule
                              ? Colors.green.withOpacity(0.05)
                              : Colors.red.withOpacity(0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'Start: ${event.startTime.toString().substring(11, 16)}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            Text(
                              'Reminder: ${event.reminderMinutes} min',
                              style: const TextStyle(fontSize: 10),
                            ),
                            Text(
                              'Notify at: ${notificationTime.toString().substring(11, 16)}',
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            if (willSchedule)
                              Text(
                                '✅ WILL SCHEDULE (in $minUntil min)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                '❌ NOT SCHEDULED (${minUntil.abs()} min late)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
      loading: () => AlertDialog(
        title: const Text('Loading...'),
        content: const CircularProgressIndicator(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
      error: (error, stack) => AlertDialog(
        title: const Text('Error'),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}
