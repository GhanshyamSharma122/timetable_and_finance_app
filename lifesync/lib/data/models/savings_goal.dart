import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 11)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime? targetDate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  int colorValue;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isCompleted;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    this.notes,
    required this.colorValue,
    required this.createdAt,
    this.isCompleted = false,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);
  bool get isAchieved => currentAmount >= targetAmount;

  SavingsGoalModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? notes,
    int? colorValue,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
