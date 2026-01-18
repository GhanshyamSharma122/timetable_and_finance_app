import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lending.dart';

class AddLendingScreen extends ConsumerStatefulWidget {
  final LendingModel? editLending;

  const AddLendingScreen({super.key, this.editLending});

  @override
  ConsumerState<AddLendingScreen> createState() => _AddLendingScreenState();
}

class _AddLendingScreenState extends ConsumerState<AddLendingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();

  LendingType _type = LendingType.lent;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;

  bool get isEditing => widget.editLending != null;

  @override
  void initState() {
    super.initState();
    if (widget.editLending != null) {
      final l = widget.editLending!;
      _nameController.text = l.personName;
      _amountController.text = l.amount.toString();
      _notesController.text = l.notes ?? '';
      _phoneController.text = l.phoneNumber ?? '';
      _type = l.type;
      _date = l.date;
      _dueDate = l.dueDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'Add Lending'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete,
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
                      label: 'I Lent Money',
                      subtitle: 'Someone owes me',
                      isSelected: _type == LendingType.lent,
                      color: AppColors.success,
                      onTap: () => setState(() => _type = LendingType.lent),
                    ),
                  ),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'I Borrowed',
                      subtitle: 'I owe someone',
                      isSelected: _type == LendingType.borrowed,
                      color: AppColors.error,
                      onTap: () => setState(() => _type = LendingType.borrowed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Person Name
            Text(
              'Person Name',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
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
                  color: _type == LendingType.lent
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              style: TextStyle(
                color: _type == LendingType.lent
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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

            // Dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      _buildDatePicker(
                        value: _date,
                        onTap: () => _pickDate(isStartDate: true),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date (Optional)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      _buildDatePicker(
                        value: _dueDate,
                        placeholder: 'No due date',
                        onTap: () => _pickDate(isStartDate: false),
                        isDark: isDark,
                        onClear: _dueDate != null
                            ? () => setState(() => _dueDate = null)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Phone (Optional)
            Text(
              'Phone Number (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
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
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _type == LendingType.lent
                    ? AppColors.success
                    : AppColors.error,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  isEditing ? 'Update' : 'Save',
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
    required String subtitle,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.8) : color.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    DateTime? value,
    String? placeholder,
    required VoidCallback onTap,
    required bool isDark,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
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
            Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null
                    ? DateTimeUtils.formatShortDate(value)
                    : (placeholder ?? ''),
                style: TextStyle(
                  color: value == null
                      ? (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)
                      : null,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _date
          : (_dueDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: isStartDate
          ? DateTime.now().subtract(const Duration(days: 365))
          : _date,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _date = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<LendingModel>('lendings');
    final amount = double.parse(_amountController.text);

    if (isEditing) {
      final updated = widget.editLending!.copyWith(
        personName: _nameController.text.trim(),
        amount: amount,
        type: _type,
        date: _date,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      box.put(widget.editLending!.key, updated);
    } else {
      final lending = LendingModel(
        id: const Uuid().v4(),
        personName: _nameController.text.trim(),
        amount: amount,
        type: _type,
        date: _date,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        createdAt: DateTime.now(),
      );
      box.add(lending);
    }

    Navigator.pop(context);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final box = Hive.box<LendingModel>('lendings');
              box.delete(widget.editLending!.key);
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
