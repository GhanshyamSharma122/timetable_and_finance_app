import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/app_settings.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final appLockedProvider = StateProvider<bool>((ref) => true);

class SettingsNotifier extends StateNotifier<AppSettings> {
  late Box<AppSettings> _box;

  SettingsNotifier() : super(AppSettings()) {
    _init();
  }

  void _init() {
    _box = Hive.box<AppSettings>('settings');
    final saved = _box.get('app_settings');
    if (saved != null) {
      state = saved;
    } else {
      _box.put('app_settings', state);
    }
  }

  void _save() {
    _box.put('app_settings', state);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _save();
  }

  void setDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    _save();
  }

  void enablePin(String pin) {
    state = state.copyWith(
      isPinEnabled: true,
      pinCode: pin,
    );
    _save();
  }

  void disablePin() {
    state = state.copyWith(
      isPinEnabled: false,
      pinCode: null,
    );
    _save();
  }

  void updatePin(String newPin) {
    state = state.copyWith(pinCode: newPin);
    _save();
  }

  bool verifyPin(String pin) {
    return state.pinCode == pin;
  }

  void setCurrencySymbol(String symbol) {
    state = state.copyWith(currencySymbol: symbol);
    _save();
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _save();
  }

  void setDefaultReminderMinutes(int minutes) {
    state = state.copyWith(defaultReminderMinutes: minutes);
    _save();
  }

  void updateLastBackupDate() {
    state = state.copyWith(lastBackupDate: DateTime.now());
    _save();
  }
}
