import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 10)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double limit;

  @HiveField(3)
  int month; // 1-12

  @HiveField(4)
  int year;

  @HiveField(5)
  bool notifyAt80Percent;

  @HiveField(6)
  bool notifyAt100Percent;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
    required this.year,
    this.notifyAt80Percent = true,
    this.notifyAt100Percent = true,
  });

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? limit,
    int? month,
    int? year,
    bool? notifyAt80Percent,
    bool? notifyAt100Percent,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      month: month ?? this.month,
      year: year ?? this.year,
      notifyAt80Percent: notifyAt80Percent ?? this.notifyAt80Percent,
      notifyAt100Percent: notifyAt100Percent ?? this.notifyAt100Percent,
    );
  }
}
