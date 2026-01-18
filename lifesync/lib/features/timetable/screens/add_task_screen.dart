import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/task.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final TaskModel? editTask;

  const AddTaskScreen({
    super.key,
    this.initialDate,
    this.editTask,
  });

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  TaskCategory _category = TaskCategory.personal;
  PriorityLevel _priority = PriorityLevel.medium;
  RecurrenceType _recurrence = RecurrenceType.none;
  bool _hasReminder = false;
  int _reminderMinutes = 30;

  bool get isEditing => widget.editTask != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();

    if (widget.editTask != null) {
      final task = widget.editTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedDate = task.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(task.dateTime);
      _category = task.category;
      _priority = task.priority;
      _recurrence = task.recurrence;
      _hasReminder = task.hasReminder;
      _reminderMinutes = task.reminderMinutesBefore ?? 30;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Date & Time
            Text(
              'Date & Time',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeCard(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateTimeUtils.formatDate(_selectedDate),
                    onTap: _pickDate,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _buildDateTimeCard(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _selectedTime.format(context),
                    onTap: _pickTime,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Category
            Text(
              'Category',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Wrap(
              spacing: AppSizes.paddingS,
              runSpacing: AppSizes.paddingS,
              children: TaskCategory.values.map((category) {
                final isSelected = _category == category;
                return ChoiceChip(
                  label: Text('${category.icon} ${category.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _category = category);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Priority
            Text(
              'Priority',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: PriorityLevel.values.map((priority) {
                final isSelected = _priority == priority;
                final color = _getPriorityColor(priority);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _priority = priority),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : (isDark
                                  ? AppColors.cardDark
                                  : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              color: isSelected
                                  ? color
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              priority.displayName,
                              style: TextStyle(
                                color: isSelected
                                    ? color
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Recurrence
            Text(
              'Repeat',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Wrap(
              spacing: AppSizes.paddingS,
              runSpacing: AppSizes.paddingS,
              children: RecurrenceType.values.map((recurrence) {
                final isSelected = _recurrence == recurrence;
                return ChoiceChip(
                  label: Text(recurrence.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _recurrence = recurrence);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Reminder
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Reminder'),
                    subtitle: Text(
                      _hasReminder
                          ? '$_reminderMinutes minutes before'
                          : 'No reminder set',
                    ),
                    value: _hasReminder,
                    onChanged: (value) {
                      setState(() => _hasReminder = value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_hasReminder) ...[
                    const Divider(),
                    Row(
                      children: [
                        const Text('Remind me'),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _reminderMinutes,
                          items: [5, 10, 15, 30, 60, 120, 1440].map((minutes) {
                            String label;
                            if (minutes < 60) {
                              label = '$minutes min before';
                            } else if (minutes == 60) {
                              label = '1 hour before';
                            } else if (minutes == 120) {
                              label = '2 hours before';
                            } else {
                              label = '1 day before';
                            }
                            return DropdownMenuItem(
                              value: minutes,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _reminderMinutes = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Save Button
            ElevatedButton(
              onPressed: _saveTask,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  isEditing ? 'Update Task' : 'Add Task',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSizes.paddingS),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.high:
        return AppColors.priorityHigh;
      case PriorityLevel.medium:
        return AppColors.priorityMedium;
      case PriorityLevel.low:
        return AppColors.priorityLow;
    }
  }

  IconData _getPriorityIcon(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.high:
        return Icons.keyboard_double_arrow_up;
      case PriorityLevel.medium:
        return Icons.drag_handle;
      case PriorityLevel.low:
        return Icons.keyboard_double_arrow_down;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<TaskModel>('tasks');
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (isEditing) {
      final updatedTask = widget.editTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateTime: dateTime,
        category: _category,
        priority: _priority,
        recurrence: _recurrence,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _hasReminder ? _reminderMinutes : null,
      );
      box.put(widget.editTask!.key, updatedTask);
    } else {
      final task = TaskModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dateTime: dateTime,
        category: _category,
        priority: _priority,
        recurrence: _recurrence,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _hasReminder ? _reminderMinutes : null,
        createdAt: DateTime.now(),
      );
      box.add(task);
    }

    Navigator.pop(context);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final box = Hive.box<TaskModel>('tasks');
              box.delete(widget.editTask!.key);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
