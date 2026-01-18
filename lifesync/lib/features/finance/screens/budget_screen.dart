import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget.dart';
import '../../../data/models/category.dart';
import '../../../data/models/transaction.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'school':
        return Icons.school;
      case 'payments':
        return Icons.payments;
      case 'work':
        return Icons.work;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<BudgetModel>('budgets').listenable(),
        builder: (context, Box<BudgetModel> budgetBox, _) {
          final budgets = budgetBox.values.toList();

          return ValueListenableBuilder(
            valueListenable: Hive.box<TransactionModel>(
              'transactions',
            ).listenable(),
            builder: (context, Box<TransactionModel> transactionBox, _) {
              if (budgets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart_outline,
                        size: 64,
                        color:
                            (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight)
                                .withOpacity(0.5),
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'No budgets set',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final currentMonth = DateTime.now();

                  // Calculate spent amount for this category this month
                  final spent = transactionBox.values
                      .where(
                        (t) =>
                            t.type == TransactionType.expense &&
                            t.categoryId == budget.categoryId &&
                            t.date.month == currentMonth.month &&
                            t.date.year == currentMonth.year,
                      )
                      .fold(0.0, (sum, t) => sum + t.amount);

                  final category = CategoryModel.defaultExpenseCategories
                      .firstWhere(
                        (c) => c.id == budget.categoryId,
                        orElse: () => CategoryModel(
                          id: budget.categoryId,
                          name: 'Unknown',
                          colorValue: Colors.grey.value,
                          iconName: 'help_outline',
                          isExpenseCategory: true,
                        ),
                      );

                  final progress = (spent / budget.limit).clamp(0.0, 1.0);
                  final isOverBudget = spent > budget.limit;
                  final remaining = budget.limit - spent;

                  return Dismissible(
                    key: Key(budget.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSizes.paddingL),
                      color: AppColors.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      budget.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget deleted')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIcon(category.iconName),
                                    color: category.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${CurrencyUtils.formatCompact(spent)} of ${CurrencyUtils.formatCompact(budget.limit)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showAddBudgetDialog(
                                    context,
                                    budget: budget,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.paddingM),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  theme.brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              color: isOverBudget
                                  ? AppColors.error
                                  : category.color,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isOverBudget
                                        ? 'Over by ${CurrencyUtils.formatCompact(spent - budget.limit)}'
                                        : '${CurrencyUtils.formatCompact(remaining)} left',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isOverBudget
                                          ? AppColors.error
                                          : AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toInt()}%',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, {BudgetModel? budget}) {
    showDialog(
      context: context,
      builder: (context) => _AddBudgetDialog(budget: budget),
    );
  }
}

class _AddBudgetDialog extends StatefulWidget {
  final BudgetModel? budget;

  const _AddBudgetDialog({this.budget});

  @override
  State<_AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<_AddBudgetDialog> {
  late String _selectedCategoryId;
  late TextEditingController _amountController;
  late bool _notify80;
  late bool _notify100;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId =
        widget.budget?.categoryId ??
        CategoryModel.defaultExpenseCategories.first.id;
    _amountController = TextEditingController(
      text: widget.budget?.limit.toString() ?? '',
    );
    _notify80 = widget.budget?.notifyAt80Percent ?? true;
    _notify100 = widget.budget?.notifyAt100Percent ?? true;
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'school':
        return Icons.school;
      case 'payments':
        return Icons.payments;
      case 'work':
        return Icons.work;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: CategoryModel.defaultExpenseCategories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(_getIcon(c.iconName), color: c.color, size: 16),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: widget.budget == null
                  ? (value) => setState(() => _selectedCategoryId = value!)
                  : null,
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly Limit',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CheckboxListTile(
              title: const Text('Notify at 80%'),
              value: _notify80,
              onChanged: (value) => setState(() => _notify80 = value!),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Notify at 100%'),
              value: _notify100,
              onChanged: (value) => setState(() => _notify100 = value!),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final limit = double.tryParse(_amountController.text);
            if (limit != null && limit > 0) {
              final box = Hive.box<BudgetModel>('budgets');

              if (widget.budget != null) {
                widget.budget!.limit = limit;
                widget.budget!.notifyAt80Percent = _notify80;
                widget.budget!.notifyAt100Percent = _notify100;
                widget.budget!.save();
              } else {
                if (box.values.any(
                  (b) => b.categoryId == _selectedCategoryId,
                )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget for this category already exists'),
                    ),
                  );
                  return;
                }

                final now = DateTime.now();
                final newBudget = BudgetModel(
                  id: DateTime.now().millisecondsSinceEpoch
                      .toString(), // Simple ID generation
                  categoryId: _selectedCategoryId,
                  limit: limit,
                  month: now.month,
                  year: now.year,
                  notifyAt80Percent: _notify80,
                  notifyAt100Percent: _notify100,
                );
                box.add(newBudget);
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
