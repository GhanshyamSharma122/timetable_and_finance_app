import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // TODO: Navigate to reports
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TransactionModel>('transactions').listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          final transactions = box.values
              .where((t) =>
                  t.date.month == selectedMonth.month &&
                  t.date.year == selectedMonth.year)
              .toList();

          transactions.sort((a, b) => b.date.compareTo(a.date));

          double totalIncome = 0;
          double totalExpense = 0;
          Map<String, double> categoryExpenses = {};

          for (final t in transactions) {
            if (t.type == TransactionType.income) {
              totalIncome += t.amount;
            } else {
              totalExpense += t.amount;
              categoryExpenses[t.categoryId] =
                  (categoryExpenses[t.categoryId] ?? 0) + t.amount;
            }
          }

          final balance = totalIncome - totalExpense;

          return CustomScrollView(
            slivers: [
              // Month Selector
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppSizes.paddingM),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          ref.read(selectedMonthProvider.notifier).state =
                              DateTime(selectedMonth.year, selectedMonth.month - 1);
                        },
                      ),
                      Text(
                        DateTimeUtils.formatMonthYear(selectedMonth),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          final now = DateTime.now();
                          if (selectedMonth.year < now.year ||
                              (selectedMonth.year == now.year &&
                                  selectedMonth.month < now.month)) {
                            ref.read(selectedMonthProvider.notifier).state =
                                DateTime(selectedMonth.year, selectedMonth.month + 1);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Income',
                          totalIncome,
                          AppColors.success,
                          Icons.arrow_downward,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: _buildSummaryCard(
                          'Expense',
                          totalExpense,
                          AppColors.error,
                          Icons.arrow_upward,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: _buildSummaryCard(
                          'Balance',
                          balance,
                          balance >= 0 ? AppColors.primary : AppColors.error,
                          balance >= 0 ? Icons.trending_up : Icons.trending_down,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expense Chart
              if (categoryExpenses.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(AppSizes.paddingM),
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses by Category',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        SizedBox(
                          height: 200,
                          child: _buildPieChart(categoryExpenses, totalExpense),
                        ),
                      ],
                    ),
                  ),
                ),

              // Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${transactions.length} items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions List
              if (transactions.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          'No transactions this month',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                          child: TransactionTile(transaction: transactions[index]),
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyUtils.formatCompact(amount),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryExpenses, double total) {
    final categories = CategoryModel.defaultExpenseCategories;
    final List<PieChartSectionData> sections = [];

    int index = 0;
    categoryExpenses.forEach((categoryId, amount) {
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => categories.last,
      );
      final percentage = (amount / total) * 100;

      sections.add(
        PieChartSectionData(
          value: amount,
          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          color: category.color,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
      index++;
    });

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryExpenses.entries.take(5).map((entry) {
              final category = categories.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => categories.last,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
