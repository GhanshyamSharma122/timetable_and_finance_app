import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  TaskCategory category;

  @HiveField(6)
  PriorityLevel priority;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  RecurrenceType recurrence;

  @HiveField(9)
  int? recurrenceInterval; // For custom recurrence (every X days)

  @HiveField(10)
  bool hasReminder;

  @HiveField(11)
  int? reminderMinutesBefore;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.endTime,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    this.recurrence = RecurrenceType.none,
    this.recurrenceInterval,
    this.hasReminder = false,
    this.reminderMinutesBefore,
    required this.createdAt,
    this.completedAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? endTime,
    TaskCategory? category,
    PriorityLevel? priority,
    bool? isCompleted,
    RecurrenceType? recurrence,
    int? recurrenceInterval,
    bool? hasReminder,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  study,
  @HiveField(2)
  health,
  @HiveField(3)
  personal,
  @HiveField(4)
  finance,
  @HiveField(5)
  shopping,
  @HiveField(6)
  other,
}

@HiveType(typeId: 2)
enum PriorityLevel {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 3)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  custom,
}

extension TaskCategoryExtension on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.finance:
        return 'Finance';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TaskCategory.work:
        return '💼';
      case TaskCategory.study:
        return '📚';
      case TaskCategory.health:
        return '🏃';
      case TaskCategory.personal:
        return '🏠';
      case TaskCategory.finance:
        return '💰';
      case TaskCategory.shopping:
        return '🛒';
      case TaskCategory.other:
        return '📌';
    }
  }
}

extension PriorityLevelExtension on PriorityLevel {
  String get displayName {
    switch (this) {
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
    }
  }
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }
}
