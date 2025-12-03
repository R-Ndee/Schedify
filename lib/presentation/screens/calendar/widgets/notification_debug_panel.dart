import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/providers/event_provider.dart';

class NotificationDebugPanel extends ConsumerWidget {
  const NotificationDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventListProvider);
    
    return AlertDialog(
      title: const Text('📋 Notification Debug'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: eventsAsync.when(
            data: (events) {
              final eventsWithReminder = events.where((e) => e.hasReminder).toList();
              final now = DateTime.now();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current Time: ${now.toString().substring(0, 16)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Events with Reminder:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (eventsWithReminder.isEmpty)
                    const Text(
                      'No events with reminder',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    )
                  else
                    ...eventsWithReminder.map((event) {
                      final notificationTime = event.reminderTime;
                      final timeUntilNotification = notificationTime.difference(now).inMinutes;
                      final willSchedule = notificationTime.isAfter(now);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: willSchedule ? Colors.green : Colors.red,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: willSchedule
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📌 ${event.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start: ${event.startTime.toString().substring(11, 16)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Reminder: ${event.reminderMinutes} min before',
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              'Notify at: ${notificationTime.toString().substring(11, 16)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            if (willSchedule)
                              Text(
                                '✅ Will schedule (in ${timeUntilNotification} min)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                '❌ NOT scheduled (time passed)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              );
            }, error: (Object error, StackTrace stackTrace) {  }, loading: () {  },
          ),
        ),
      ),
    );
  }
}
