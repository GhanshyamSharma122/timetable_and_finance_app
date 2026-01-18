import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/task.dart';

class TaskSummaryCard extends ConsumerWidget {
  const TaskSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<TaskModel>('tasks').listenable(),
      builder: (context, Box<TaskModel> box, _) {
        final today = DateTime.now();
        final todayTasks = box.values.where((task) {
          return DateTimeUtils.isSameDay(task.dateTime, today);
        }).toList();

        final completedCount = todayTasks.where((t) => t.isCompleted).length;
        final totalCount = todayTasks.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

        return Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completedCount/$totalCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'Tasks Today',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
