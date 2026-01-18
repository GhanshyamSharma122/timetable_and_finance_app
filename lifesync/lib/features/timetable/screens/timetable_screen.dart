import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/task.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) => CalendarFormat.month);

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
          ),
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(Icons.view_agenda_outlined),
            onSelected: (format) {
              ref.read(calendarFormatProvider.notifier).state = format;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Month View'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks View'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week View'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          ValueListenableBuilder(
            valueListenable: Hive.box<TaskModel>('tasks').listenable(),
            builder: (context, Box<TaskModel> box, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: TableCalendar<TaskModel>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDate,
                  calendarFormat: calendarFormat,
                  selectedDayPredicate: (day) => DateTimeUtils.isSameDay(day, selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    ref.read(selectedDateProvider.notifier).state = selectedDay;
                  },
                  onFormatChanged: (format) {
                    ref.read(calendarFormatProvider.notifier).state = format;
                  },
                  eventLoader: (day) {
                    return box.values
                        .where((task) => DateTimeUtils.isSameDay(task.dateTime, day))
                        .toList();
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: theme.colorScheme.onSurface,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: TextStyle(
                      color: AppColors.error.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSizes.paddingM),

          // Selected date header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: Row(
              children: [
                Text(
                  DateTimeUtils.getRelativeDate(selectedDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Text(
                  DateTimeUtils.formatDate(selectedDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskScreen(
                          initialDate: selectedDate,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Tasks list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<TaskModel>('tasks').listenable(),
              builder: (context, Box<TaskModel> box, _) {
                final tasks = box.values
                    .where((task) => DateTimeUtils.isSameDay(task.dateTime, selectedDate))
                    .toList();

                tasks.sort((a, b) {
                  if (a.isCompleted != b.isCompleted) {
                    return a.isCompleted ? 1 : -1;
                  }
                  return a.dateTime.compareTo(b.dateTime);
                });

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          'No tasks scheduled',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskScreen(
                                  initialDate: selectedDate,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Task'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                      child: TaskTile(task: tasks[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
