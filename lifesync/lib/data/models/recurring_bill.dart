import 'package:hive/hive.dart';

part 'recurring_bill.g.dart';

@HiveType(typeId: 12)
class RecurringBillModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String categoryId;

  @HiveField(4)
  BillFrequency frequency;

  @HiveField(5)
  int dayOfMonth; // For monthly bills (1-31)

  @HiveField(6)
  DateTime? nextDueDate;

  @HiveField(7)
  bool autoAdd; // Auto add to expenses when due

  @HiveField(8)
  bool reminderEnabled;

  @HiveField(9)
  int reminderDaysBefore;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  bool isActive;

  RecurringBillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.frequency,
    this.dayOfMonth = 1,
    this.nextDueDate,
    this.autoAdd = false,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 3,
    this.notes,
    required this.createdAt,
    this.isActive = true,
  });

  RecurringBillModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? categoryId,
    BillFrequency? frequency,
    int? dayOfMonth,
    DateTime? nextDueDate,
    bool? autoAdd,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    String? notes,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RecurringBillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      autoAdd: autoAdd ?? this.autoAdd,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

@HiveType(typeId: 13)
enum BillFrequency {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  quarterly,
  @HiveField(3)
  yearly,
}

extension BillFrequencyExtension on BillFrequency {
  String get displayName {
    switch (this) {
      case BillFrequency.weekly:
        return 'Weekly';
      case BillFrequency.monthly:
        return 'Monthly';
      case BillFrequency.quarterly:
        return 'Quarterly';
      case BillFrequency.yearly:
        return 'Yearly';
    }
  }
}
