import 'package:flutter/material.dart';
import '../../../../core/utils/date_utils.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onTodayPressed;

  const CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onTodayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = AppDateUtils.isSameDay(focusedDay, DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppDateUtils.formatMonthYear(focusedDay),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatDayName(focusedDay),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
          if (!isToday)
            TextButton.icon(
              onPressed: onTodayPressed,
              icon: const Icon(Icons.today),
              label: const Text('Today'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}