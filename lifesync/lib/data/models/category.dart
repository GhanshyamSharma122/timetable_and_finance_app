import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  String iconName;

  @HiveField(4)
  bool isDefault;

  @HiveField(5)
  bool isExpenseCategory; // true for expense, false for income

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
    this.isDefault = false,
    this.isExpenseCategory = true,
  });

  Color get color => Color(colorValue);

  static List<CategoryModel> get defaultExpenseCategories => [
    CategoryModel(
      id: 'food',
      name: 'Food & Dining',
      colorValue: AppColors.categoryFood.value,
      iconName: 'restaurant',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      colorValue: AppColors.categoryTransport.value,
      iconName: 'directions_car',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      colorValue: AppColors.categoryShopping.value,
      iconName: 'shopping_bag',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      colorValue: AppColors.categoryEntertainment.value,
      iconName: 'movie',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'health',
      name: 'Health',
      colorValue: AppColors.categoryHealth.value,
      iconName: 'medical_services',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills & Utilities',
      colorValue: AppColors.categoryFinance.value,
      iconName: 'receipt_long',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      colorValue: AppColors.categoryStudy.value,
      iconName: 'school',
      isDefault: true,
      isExpenseCategory: true,
    ),
    CategoryModel(
      id: 'other_expense',
      name: 'Other',
      colorValue: AppColors.categoryOther.value,
      iconName: 'more_horiz',
      isDefault: true,
      isExpenseCategory: true,
    ),
  ];

  static List<CategoryModel> get defaultIncomeCategories => [
    CategoryModel(
      id: 'salary',
      name: 'Salary',
      colorValue: AppColors.success.value,
      iconName: 'payments',
      isDefault: true,
      isExpenseCategory: false,
    ),
    CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      colorValue: AppColors.categoryWork.value,
      iconName: 'work',
      isDefault: true,
      isExpenseCategory: false,
    ),
    CategoryModel(
      id: 'investment',
      name: 'Investment',
      colorValue: AppColors.categoryFinance.value,
      iconName: 'trending_up',
      isDefault: true,
      isExpenseCategory: false,
    ),
    CategoryModel(
      id: 'gift',
      name: 'Gift',
      colorValue: AppColors.categoryShopping.value,
      iconName: 'card_giftcard',
      isDefault: true,
      isExpenseCategory: false,
    ),
    CategoryModel(
      id: 'other_income',
      name: 'Other',
      colorValue: AppColors.categoryOther.value,
      iconName: 'more_horiz',
      isDefault: true,
      isExpenseCategory: false,
    ),
  ];
}
