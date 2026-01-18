import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 14)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool isPinEnabled;

  @HiveField(2)
  String? pinCode;

  @HiveField(3)
  String currencySymbol;

  @HiveField(4)
  bool notificationsEnabled;

  @HiveField(5)
  int defaultReminderMinutes;

  @HiveField(6)
  DateTime? lastBackupDate;

  AppSettings({
    this.isDarkMode = false,
    this.isPinEnabled = false,
    this.pinCode,
    this.currencySymbol = '₹',
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 30,
    this.lastBackupDate,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isPinEnabled,
    String? pinCode,
    String? currencySymbol,
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    DateTime? lastBackupDate,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      pinCode: pinCode ?? this.pinCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes: defaultReminderMinutes ?? this.defaultReminderMinutes,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }
}
