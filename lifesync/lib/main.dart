import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/models/task.dart';
import 'data/models/category.dart';
import 'data/models/transaction.dart';
import 'data/models/lending.dart';
import 'data/models/budget.dart';
import 'data/models/savings_goal.dart';
import 'data/models/recurring_bill.dart';
import 'data/models/app_settings.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  Hive.registerAdapter(PriorityLevelAdapter());
  Hive.registerAdapter(RecurrenceTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(LendingModelAdapter());
  Hive.registerAdapter(LendingTypeAdapter());
  Hive.registerAdapter(LendingStatusAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(SavingsGoalModelAdapter());
  Hive.registerAdapter(RecurringBillModelAdapter());
  Hive.registerAdapter(BillFrequencyAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Open Hive Boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<LendingModel>('lendings');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox<SavingsGoalModel>('savings_goals');
  await Hive.openBox<RecurringBillModel>('recurring_bills');
  await Hive.openBox<AppSettings>('settings');

  // Initialize Notifications
  await NotificationService.initialize(flutterLocalNotificationsPlugin);

  runApp(
    const ProviderScope(
      child: LifeSyncApp(),
    ),
  );
}
