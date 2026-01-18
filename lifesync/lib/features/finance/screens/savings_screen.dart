import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/savings_goal.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<SavingsGoalModel>(
          'savings_goals',
        ).listenable(),
        builder: (context, Box<SavingsGoalModel> box, _) {
          final goals = box.values.toList();

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color:
                        (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)
                            .withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    'No savings goals yet',
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

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.paddingM,
              mainAxisSpacing: AppSizes.paddingM,
              childAspectRatio: 0.8,
            ),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _SavingsGoalCard(goal: goal);
            },
          );
        },
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, {SavingsGoalModel? goal}) {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(goal: goal),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;

  const _SavingsGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showAddGoalDialog(context, goal: goal),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Progress
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 4,
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.transparent,
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(goal.colorValue).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons
                          .savings, // Default icon since model doesn't support custom icons
                      color: Color(goal.colorValue),
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  // Name
                  Text(
                    goal.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Amount
                  Text(
                    '${CurrencyUtils.formatCompact(goal.currentAmount)} / ${CurrencyUtils.formatCompact(goal.targetAmount)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Percentage
                  Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: () => _showDepositDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, {SavingsGoalModel? goal}) {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(goal: goal),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${goal.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹ ',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                goal.currentAmount += amount;
                goal.save();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalDialog extends StatefulWidget {
  final SavingsGoalModel? goal;

  const _AddGoalDialog({this.goal});

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late DateTime _targetDate;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController = TextEditingController(
      text: widget.goal?.targetAmount.toString() ?? '',
    );
    _currentAmountController = TextEditingController(
      text: widget.goal?.currentAmount.toString() ?? '0',
    );
    _targetDate =
        widget.goal?.targetDate ??
        DateTime.now().add(const Duration(days: 365));
    if (widget.goal != null) {
      _selectedColor = Color(widget.goal!.colorValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? 'New Goal' : 'Edit Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: _currentAmountController,
              decoration: const InputDecoration(
                labelText: 'Current Saved',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.paddingM),
            ListTile(
              title: const Text('Target Date'),
              subtitle: Text(DateFormat.yMMMd().format(_targetDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _targetDate = picked);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.goal != null)
          TextButton(
            onPressed: () {
              widget.goal!.delete();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text;
            final target = double.tryParse(_targetAmountController.text);
            final current = double.tryParse(_currentAmountController.text) ?? 0;

            if (name.isNotEmpty && target != null && target > 0) {
              final box = Hive.box<SavingsGoalModel>('savings_goals');
              if (widget.goal != null) {
                widget.goal!
                  ..name = name
                  ..targetAmount = target
                  ..currentAmount = current
                  ..targetDate = _targetDate
                  ..colorValue = _selectedColor.value;
                widget.goal!.save();
              } else {
                box.add(
                  SavingsGoalModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    targetAmount: target,
                    currentAmount: current,
                    targetDate: _targetDate,
                    colorValue: _selectedColor.value,
                    createdAt: DateTime.now(),
                  ),
                );
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
