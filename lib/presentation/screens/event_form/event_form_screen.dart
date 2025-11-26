import 'package:calendar_app/core/constrant/app_constrant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/event_model.dart';
import '../../../domain/providers/event_provider.dart';
import 'dart:developer' as developer;

class EventFormScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final EventModel? eventToEdit;

  const EventFormScreen({
    super.key,
    required this.selectedDate,
    this.eventToEdit,
  });

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedColor;
  late String _startTime;
  late String _endTime;
  // ✅ TAMBAHAN: Reminder settings
  late bool _hasReminder;
  late int _reminderMinutes;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    _selectedDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    
    developer.log('========== EventFormScreen INIT ==========', name: 'EventFormScreen');
    developer.log('Selected date: $_selectedDate', name: 'EventFormScreen');
    
    if (widget.eventToEdit != null) {
      // Edit mode
      final event = widget.eventToEdit!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _selectedDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      _selectedCategory = event.category;
      _selectedColor = event.color;
      _startTime = AppDateUtils.formatTime(event.startTime);
      _endTime = AppDateUtils.formatTime(event.endTime);
      // ✅ Load reminder settings
      _hasReminder = event.hasReminder;
      _reminderMinutes = event.reminderMinutes;
      developer.log('Edit mode: ${event.title}', name: 'EventFormScreen');
    } else {
      // Add mode
      _selectedCategory = AppConstants.eventCategories.first;
      _selectedColor = AppConstants.categoryColors[_selectedCategory]!;
      _startTime = '09:00';
      _endTime = '10:00';
      // ✅ Default reminder settings
      _hasReminder = true;
      _reminderMinutes = 15;
      developer.log('Add mode: New event', name: 'EventFormScreen');
    }
    developer.log('==========================================', name: 'EventFormScreen');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(AppConstants.calendarFirstYear),
      lastDate: DateTime(AppConstants.calendarLastYear),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final currentTime = isStartTime ? _startTime : _endTime;
    final timeParts = currentTime.split(':');
    
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
    
    if (picked != null) {
      final time = '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    developer.log('========== SAVE EVENT STARTED ==========', name: 'EventFormScreen');
    
    if (!_formKey.currentState!.validate()) {
      developer.log('❌ Form validation failed', name: 'EventFormScreen');
      return;
    }
    
    developer.log('✅ Form validation passed', name: 'EventFormScreen');
    
    final startTimeParts = _startTime.split(':');
    final endTimeParts = _endTime.split(':');
    
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
    );
    
    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
    );
    
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      developer.log('❌ Invalid time range', name: 'EventFormScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final event = EventModel(
        id: widget.eventToEdit?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: start,
        endTime: end,
        category: _selectedCategory,
        color: _selectedColor,
        isCompleted: widget.eventToEdit?.isCompleted ?? false,
        // ✅ TAMBAHAN: Save reminder settings
        hasReminder: _hasReminder,
        reminderMinutes: _hasReminder ? _reminderMinutes : 0,
        createdAt: widget.eventToEdit?.createdAt,
      );
      
      developer.log('Event with reminder:', name: 'EventFormScreen');
      developer.log('  Has reminder: ${event.hasReminder}', name: 'EventFormScreen');
      developer.log('  Reminder minutes: ${event.reminderMinutes}', name: 'EventFormScreen');
      developer.log('  Reminder text: ${event.reminderText}', name: 'EventFormScreen');
      
      if (widget.eventToEdit != null) {
        await ref.read(eventListProvider.notifier).updateEvent(event);
      } else {
        await ref.read(eventListProvider.notifier).addEvent(event);
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      await ref.read(eventListProvider.notifier).refresh();
      
      developer.log('========== SAVE EVENT COMPLETED ==========', name: 'EventFormScreen');
      
      if (mounted) {
        Navigator.pop(context, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.eventToEdit != null
                  ? 'Event updated successfully'
                  : 'Event added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log('========== SAVE EVENT FAILED ==========', name: 'EventFormScreen');
      developer.log('❌ Error: $e', name: 'EventFormScreen');
      developer.log('❌ StackTrace: $stackTrace', name: 'EventFormScreen');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.eventToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Event' : 'Add Event'),
        actions: [
          if (isEditMode)
            IconButton(
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Event'),
                    content: const Text('Are you sure you want to delete this event?'),
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
                
                if (shouldDelete == true && mounted) {
                  await ref
                      .read(eventListProvider.notifier)
                      .deleteEvent(widget.eventToEdit!.id);
                  
                  if (mounted) {
                    Navigator.pop(context, true);
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter event description',
                prefixIcon: Icon(Icons.description),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Date Selector
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(AppDateUtils.formatDate(_selectedDate)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              onTap: _selectDate,
            ),
            
            const SizedBox(height: 16),
            
            // Time Selectors
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start'),
                    subtitle: Text(_startTime),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    onTap: () => _selectTime(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('End'),
                    subtitle: Text(_endTime),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    onTap: () => _selectTime(false),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.eventCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                            AppConstants.categoryColors[category]!
                                .replaceAll('#', '0xff'),
                          )),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedColor = AppConstants.categoryColors[value]!;
                  });
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // ✅ TAMBAHAN: Reminder Section
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Enable/Disable Reminder Switch
                    SwitchListTile(
                      title: const Text('Enable reminder'),
                      subtitle: Text(
                        _hasReminder 
                          ? 'You will be notified before the event'
                          : 'No reminder for this event'
                      ),
                      value: _hasReminder,
                      onChanged: (value) {
                        setState(() {
                          _hasReminder = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    
                    // Reminder Time Selector
                    if (_hasReminder) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _reminderMinutes,
                        decoration: InputDecoration(
                          labelText: 'Remind me',
                          prefixIcon: const Icon(Icons.alarm),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: AppConstants.reminderOptions.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _reminderMinutes = value;
                            });
                          }
                        },
                      ),
                      
                      // Preview reminder time
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _reminderMinutes > 0
                                  ? 'Notification will be sent at ${_calculateReminderTime()}'
                                  : 'No reminder set',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Color Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(int.parse(_selectedColor.replaceAll('#', '0xff')))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(int.parse(_selectedColor.replaceAll('#', '0xff'))),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.color_lens,
                    color: Color(int.parse(_selectedColor.replaceAll('#', '0xff'))),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Event Color Preview',
                    style: TextStyle(
                      color: Color(int.parse(_selectedColor.replaceAll('#', '0xff'))),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveEvent,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(isEditMode ? Icons.save : Icons.add),
            label: Text(
              _isSaving
                  ? 'Saving...'
                  : isEditMode
                      ? 'Save Changes'
                      : 'Add Event',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ),
    );
  }
  
  // ✅ Helper: Calculate reminder time untuk preview
  String _calculateReminderTime() {
    if (_reminderMinutes == 0) return 'No reminder';
    
    final startTimeParts = _startTime.split(':');
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
    );
    
    final reminderTime = startDateTime.subtract(Duration(minutes: _reminderMinutes));
    return AppDateUtils.formatDateTime(reminderTime);
  }
}