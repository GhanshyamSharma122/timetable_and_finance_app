import 'package:hive/hive.dart';

part 'lending.g.dart';

@HiveType(typeId: 7)
class LendingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String personName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  LendingType type;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  LendingStatus status;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? settledAt;

  @HiveField(10)
  String? phoneNumber;

  LendingModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.dueDate,
    this.notes,
    this.status = LendingStatus.pending,
    required this.createdAt,
    this.settledAt,
    this.phoneNumber,
  });

  LendingModel copyWith({
    String? id,
    String? personName,
    double? amount,
    LendingType? type,
    DateTime? date,
    DateTime? dueDate,
    String? notes,
    LendingStatus? status,
    DateTime? createdAt,
    DateTime? settledAt,
    String? phoneNumber,
  }) {
    return LendingModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  bool get isOverdue {
    if (status == LendingStatus.paid) return false;
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}

@HiveType(typeId: 8)
enum LendingType {
  @HiveField(0)
  borrowed, // Money I owe (I borrowed from someone)
  @HiveField(1)
  lent, // Money owed to me (I lent to someone)
}

@HiveType(typeId: 9)
enum LendingStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  paid,
}

extension LendingTypeExtension on LendingType {
  String get displayName {
    switch (this) {
      case LendingType.borrowed:
        return 'Money I Owe';
      case LendingType.lent:
        return 'Money Owed to Me';
    }
  }

  String get shortName {
    switch (this) {
      case LendingType.borrowed:
        return 'Borrowed';
      case LendingType.lent:
        return 'Lent';
    }
  }
}

extension LendingStatusExtension on LendingStatus {
  String get displayName {
    switch (this) {
      case LendingStatus.pending:
        return 'Pending';
      case LendingStatus.paid:
        return 'Paid';
    }
  }
}
