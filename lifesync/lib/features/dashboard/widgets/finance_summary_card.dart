import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';

class FinanceSummaryCard extends ConsumerWidget {
  const FinanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<TransactionModel>('transactions').listenable(),
      builder: (context, Box<TransactionModel> box, _) {
        final now = DateTime.now();
        final thisMonth = box.values.where((t) {
          return t.date.month == now.month && t.date.year == now.year;
        }).toList();

        double totalExpense = 0;
        double totalIncome = 0;

        for (final t in thisMonth) {
          if (t.type == TransactionType.expense) {
            totalExpense += t.amount;
          } else {
            totalIncome += t.amount;
          }
        }

        final balance = totalIncome - totalExpense;
        final isPositive = balance >= 0;

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
                      color: (isPositive ? AppColors.success : AppColors.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      isPositive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: isPositive ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? AppColors.success : AppColors.error,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'This Month',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyUtils.formatCompact(balance.abs()),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
