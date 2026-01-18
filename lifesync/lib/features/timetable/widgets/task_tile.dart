import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/task.dart';

class TaskTile extends ConsumerWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  Color get categoryColor {
    switch (task.category) {
      case TaskCategory.work:
        return AppColors.categoryWork;
      case TaskCategory.study:
        return AppColors.categoryStudy;
      case TaskCategory.health:
        return AppColors.categoryHealth;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
      case TaskCategory.finance:
        return AppColors.categoryFinance;
      case TaskCategory.shopping:
        return AppColors.categoryShopping;
      case TaskCategory.other:
        return AppColors.categoryOther;
    }
  }

  Color get priorityColor {
    switch (task.priority) {
      case PriorityLevel.high:
        return AppColors.priorityHigh;
      case PriorityLevel.medium:
        return AppColors.priorityMedium;
      case PriorityLevel.low:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final box = Hive.box<TaskModel>('tasks');
        box.delete(task.key);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: task.isCompleted
                ? Colors.transparent
                : categoryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            onTap: () {
              // TODO: Navigate to task detail
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Row(
                children: [
                  // Category indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Colors.grey
                          : categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),

                  // Checkbox
                  GestureDetector(
                    onTap: () => _toggleComplete(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? AppColors.success
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? AppColors.success
                              : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),

                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateTimeUtils.formatTime(task.dateTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingS),
                            Text(
                              task.category.icon,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.category.displayName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      task.priority.displayName,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleComplete() {
    final box = Hive.box<TaskModel>('tasks');
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    box.put(task.key, task);
  }
}
