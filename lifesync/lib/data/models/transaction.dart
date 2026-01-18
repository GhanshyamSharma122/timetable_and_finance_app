import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 5)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  TransactionType type;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 6)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;
}
