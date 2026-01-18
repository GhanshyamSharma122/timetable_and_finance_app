import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lending.dart';

class UpcomingDuesCard extends ConsumerWidget {
  const UpcomingDuesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<LendingModel>('lendings').listenable(),
      builder: (context, Box<LendingModel> box, _) {
        final pendingLendings = box.values
            .where((l) => l.status == LendingStatus.pending)
            .toList();

        final overdue = pendingLendings.where((l) => l.isOverdue).toList();
        final upcoming = pendingLendings.where((l) {
          if (l.dueDate == null) return false;
          final daysUntil = DateTimeUtils.daysUntil(l.dueDate!);
          return daysUntil >= 0 && daysUntil <= 7;
        }).toList();

        double totalOwed = 0; // Money owed to me
        double totalOwe = 0; // Money I owe

        for (final l in pendingLendings) {
          if (l.type == LendingType.lent) {
            totalOwed += l.amount;
          } else {
            totalOwe += l.amount;
          }
        }

        if (pendingLendings.isEmpty) {
          return const SizedBox.shrink();
        }

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
                  Text(
                    'Lending Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (overdue.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        '${overdue.length} overdue',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  Expanded(
                    child: _buildAmountTile(
                      context,
                      'To Receive',
                      totalOwed,
                      AppColors.success,
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: _buildAmountTile(
                      context,
                      'To Pay',
                      totalOwe,
                      AppColors.error,
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingM),
                const Divider(),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Due This Week',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                ...upcoming.take(3).map((l) => _buildDueItem(context, l)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountTile(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.format(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueItem(BuildContext context, LendingModel lending) {
    final isLent = lending.type == LendingType.lent;
    final color = isLent ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              lending.personName[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lending.personName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  isLent ? 'owes you' : 'you owe',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyUtils.format(lending.amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
