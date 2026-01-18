import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final bool isExpense;
  final TransactionModel? editTransaction;

  const AddTransactionScreen({
    super.key,
    required this.isExpense,
    this.editTransaction,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late bool _isExpense;
  String? _selectedCategoryId;

  bool get isEditing => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
    _selectedDate = DateTime.now();

    if (widget.editTransaction != null) {
      final t = widget.editTransaction!;
      _amountController.text = t.amount.toString();
      _notesController.text = t.notes ?? '';
      _selectedDate = t.date;
      _isExpense = t.type == TransactionType.expense;
      _selectedCategoryId = t.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<CategoryModel> get categories => _isExpense
      ? CategoryModel.defaultExpenseCategories
      : CategoryModel.defaultIncomeCategories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Edit Transaction'
            : (_isExpense ? 'Add Expense' : 'Add Income')),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Type Toggle
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Expense',
                      isSelected: _isExpense,
                      color: AppColors.error,
                      onTap: () {
                        setState(() {
                          _isExpense = true;
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'Income',
                      isSelected: !_isExpense,
                      color: AppColors.success,
                      onTap: () {
                        setState(() {
                          _isExpense = false;
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Amount
            Text(
              'Amount',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0.00',
                prefixStyle: TextStyle(
                  color: _isExpense ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(
                color: _isExpense ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategoryId == category.id;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedCategoryId = category.id);
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.2)
                          : (isDark ? AppColors.cardDark : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: isSelected ? category.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(category.iconName),
                            color: category.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? category.color : null,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_selectedCategoryId == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select a category',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: AppSizes.paddingL),

            // Date
            Text(
              'Date',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            InkWell(
              onTap: _pickDate,
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
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: AppSizes.paddingM),
                    Text(
                      DateTimeUtils.formatDate(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Notes
            Text(
              'Notes (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpense ? AppColors.error : AppColors.success,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  isEditing ? 'Update' : (_isExpense ? 'Add Expense' : 'Add Income'),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
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
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    final box = Hive.box<TransactionModel>('transactions');
    final amount = double.parse(_amountController.text);

    if (isEditing) {
      final updated = widget.editTransaction!.copyWith(
        amount: amount,
        categoryId: _selectedCategoryId,
        type: _isExpense ? TransactionType.expense : TransactionType.income,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      box.put(widget.editTransaction!.key, updated);
    } else {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        type: _isExpense ? TransactionType.expense : TransactionType.income,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
      box.add(transaction);
    }

    Navigator.pop(context);
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final box = Hive.box<TransactionModel>('transactions');
              box.delete(widget.editTransaction!.key);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
