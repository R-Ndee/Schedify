import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/providers/event_provider.dart';
import '../event_form/event_form_screen.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }
          
          final color = Color(int.parse(event.color.replaceAll('#', '0xff')));
          
          return CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.7),
                          color.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event,
                            size: 48,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventFormScreen(
                            selectedDate: event.date,
                            eventToEdit: event,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Event'),
                          content: Text('Are you sure you want to delete "${event.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldDelete == true && context.mounted) {
                        await ref.read(eventListProvider.notifier).deleteEvent(event.id);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event deleted')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
              
              // Event Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      if (event.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'This event has been completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Description
                      _DetailCard(
                        icon: Icons.description,
                        title: 'Description',
                        content: event.description.isEmpty
                            ? 'No description'
                            : event.description,
                        color: color,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date & Time
                      _DetailCard(
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: AppDateUtils.formatDate(event.date),
                        subtitle:
                            '${AppDateUtils.formatTime(event.startTime)} - ${AppDateUtils.formatTime(event.endTime)} (${event.duration})',
                        color: color,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category
                      _DetailCard(
                        icon: Icons.category,
                        title: 'Category',
                        content: event.category,
                        color: color,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Additional Info
                      _DetailCard(
                        icon: Icons.info,
                        title: 'Additional Information',
                        content: event.createdAt != null
                            ? 'Created on ${AppDateUtils.formatDateTime(event.createdAt!)}'
                            : 'No additional information',
                        subtitle: event.updatedAt != null
                            ? 'Last updated: ${AppDateUtils.formatDateTime(event.updatedAt!)}'
                            : null,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: eventAsync.maybeWhen(
        data: (event) {
          if (event == null) return null;
          
          return FloatingActionButton.extended(
            onPressed: () async {
              await ref.read(eventListProvider.notifier).toggleComplete(event);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      event.isCompleted
                          ? 'Event marked as incomplete'
                          : 'Event marked as complete',
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            },
            icon: Icon(event.isCompleted ? Icons.restart_alt : Icons.check),
            label: Text(event.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
          );
        },
        orElse: () => null,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String? subtitle;
  final Color color;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}