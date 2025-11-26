import 'package:calendar_app/core/constrant/app_constrant.dart';
import 'package:calendar_app/data/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/providers/event_provider.dart';
import 'dart:developer' as developer;
import '../event_form/event_form_screen.dart';
import '../event_detail/event_detail_screen.dart';
import 'widgets/calendar_header.dart';
import 'widgets/event_item.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // ✅ Normalize selected day to start of day
    _selectedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ✅ IMPROVED: Helper method untuk normalisasi tanggal yang konsisten
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ✅ IMPROVED: Method untuk filter events dengan normalisasi konsisten
  List<EventModel> _getEventsForDay(List<EventModel> allEvents, DateTime day) {
    final normalizedDay = _normalizeDate(day);

    return allEvents.where((event) {
      final eventDate = _normalizeDate(event.date);
      return eventDate.isAtSameMomentAs(normalizedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              print('========== NOTIFICATION DEBUG ==========');

              // 1. Check notification service
              try {
                final notificationService =
                    ref.read(notificationServiceProvider);
                print('✅ Notification service accessible');

                // 2. Check permission
                final hasPermission = await notificationService.hasPermission();
                print(
                    'Permission status: ${hasPermission ? "✅ GRANTED" : "❌ DENIED"}');

                if (!hasPermission) {
                  print('Requesting permission...');
                  final granted = await notificationService.requestPermission();
                  print(
                      'Permission request result: ${granted ? "✅ GRANTED" : "❌ DENIED"}');
                }

                // 3. Get pending notifications
                final pending =
                    await notificationService.getPendingNotifications();
                print('Pending notifications: ${pending.length}');
                for (var notification in pending) {
                  print('  - ID: ${notification.id}');
                  print('    Title: ${notification.title}');
                  print('    Body: ${notification.body}');
                }

                // 4. Test immediate notification
                print('Sending test notification...');
                await notificationService.showImmediateNotification(
                  title: '🔔 Test Notification',
                  body: 'If you see this, notifications are working!',
                );
                print('✅ Test notification sent');

                // 5. Check events with reminders
                final eventsAsync = ref.read(eventListProvider);
                eventsAsync.whenData((events) {
                  final eventsWithReminder =
                      events.where((e) => e.hasReminder).toList();
                  print('Events with reminder: ${eventsWithReminder.length}');
                  for (var event in eventsWithReminder) {
                    print('  - ${event.title}');
                    print('    Reminder: ${event.reminderText}');
                    print('    Reminder time: ${event.reminderTime}');
                    print('    Start time: ${event.startTime}');
                  }
                });
              } catch (e, stackTrace) {
                print('❌ ERROR: $e');
                print('StackTrace: $stackTrace');
              }

              print('========================================');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console for debug info'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Debug Notifications',
          ),
          // Debug button - Remove in production
          IconButton(
            onPressed: () async {
              final repository = ref.read(eventRepositoryProvider);
              await repository.debugPrintAllEvents();

              developer.log('========== CURRENT STATE ==========',
                  name: 'CalendarScreen');
              developer.log('Selected date: $_selectedDay',
                  name: 'CalendarScreen');
              developer.log('Focused date: $_focusedDay',
                  name: 'CalendarScreen');
              developer.log('Calendar format: $_calendarFormat',
                  name: 'CalendarScreen');

              eventsAsync.whenData((events) {
                developer.log('Total events in state: ${events.length}',
                    name: 'CalendarScreen');
                final todayEvents = _getEventsForDay(events, _selectedDay);
                developer.log('Events for selected day: ${todayEvents.length}',
                    name: 'CalendarScreen');
                for (var event in todayEvents) {
                  developer.log('  - ${event.title} at ${event.date}',
                      name: 'CalendarScreen');
                }
              });
              developer.log('===================================',
                  name: 'CalendarScreen');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console for debug info'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
          ),
          // Refresh button
          IconButton(
            onPressed: () async {
              await ref.read(eventListProvider.notifier).refresh();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Events refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Calendar Header
          CalendarHeader(
            focusedDay: _focusedDay,
            onTodayPressed: () {
              setState(() {
                final now = DateTime.now();
                _focusedDay = _normalizeDate(now);
                _selectedDay = _normalizeDate(now);
              });
            },
          ),

          // Calendar Widget
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TableCalendar<EventModel>(
              firstDay: DateTime.utc(
                AppConstants.calendarFirstYear,
                1,
                1,
              ),
              lastDay: DateTime.utc(
                AppConstants.calendarLastYear,
                12,
                31,
              ),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: (day) {
                return eventsAsync.maybeWhen(
                  data: (events) => _getEventsForDay(events, day),
                  orElse: () => [],
                );
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
                holidayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                defaultDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markersAnchor: 0.7,
                markerSize: 6.0,
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.3),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                titleTextStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.primary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = _normalizeDate(selectedDay);
                    _focusedDay = _normalizeDate(focusedDay);
                  });
                  developer.log('Selected day changed to: $_selectedDay',
                      name: 'CalendarScreen');
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = _normalizeDate(focusedDay);
                });
              },
            ),
          ),

          const Divider(height: 1),

          // Selected Date Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Events for ${AppDateUtils.formatDate(_selectedDay)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                eventsAsync.maybeWhen(
                  data: (events) {
                    final dayEvents = _getEventsForDay(events, _selectedDay);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayEvents.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Events List Section
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                final dayEvents = _getEventsForDay(events, _selectedDay);

                developer.log(
                    'Displaying ${dayEvents.length} events for ${_selectedDay}',
                    name: 'CalendarScreen');

                if (dayEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No events on this day',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppDateUtils.formatDate(_selectedDay),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4),
                                  ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventFormScreen(
                                  selectedDate: _selectedDay,
                                ),
                              ),
                            );

                            // ✅ IMPROVED: Force refresh setelah add
                            if (result == true && mounted) {
                              await ref
                                  .read(eventListProvider.notifier)
                                  .refresh();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Event'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(eventListProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 80,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return EventItem(
                        key: ValueKey(event
                            .id), // ✅ IMPORTANT: Key untuk Flutter rebuild optimization
                        event: event,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(
                                eventId: event.id,
                              ),
                            ),
                          );

                          // Refresh if event was modified
                          if (result == true && mounted) {
                            await ref
                                .read(eventListProvider.notifier)
                                .refresh();
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading events...'),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading events',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(eventListProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          developer.log('Opening EventFormScreen with date: $_selectedDay',
              name: 'CalendarScreen');

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventFormScreen(
                selectedDate: _selectedDay,
              ),
            ),
          );

          developer.log('EventFormScreen closed with result: $result',
              name: 'CalendarScreen');

          // ✅ IMPROVED: Force refresh dengan feedback yang lebih baik
          if (mounted && result == true) {
            await ref.read(eventListProvider.notifier).refresh();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event added successfully'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        tooltip: 'Add new event',
      ),
    );
  }
}
