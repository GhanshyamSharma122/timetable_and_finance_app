import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/task.dart';
import '../../timetable/widgets/task_tile.dart';

class TodayTasksList extends ConsumerWidget {
  const TodayTasksList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<TaskModel>('tasks').listenable(),
      builder: (context, Box<TaskModel> box, _) {
        final today = DateTime.now();
        final todayTasks = box.values
            .where((task) => DateTimeUtils.isSameDay(task.dateTime, today))
            .toList();

        // Sort by completion status, then by time
        todayTasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.dateTime.compareTo(b.dateTime);
        });

        if (todayTasks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success.withOpacity(0.5),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  'No tasks for today',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Enjoy your free time! 🎉',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: todayTasks
              .take(5)
              .map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                    child: TaskTile(task: task),
                  ))
              .toList(),
        );
      },
    );
  }
}
