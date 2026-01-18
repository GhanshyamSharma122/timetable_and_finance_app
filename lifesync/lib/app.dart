import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'features/pin_lock/screens/pin_lock_screen.dart';
import 'features/shell/screens/app_shell.dart';

class LifeSyncApp extends ConsumerWidget {
  const LifeSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isLocked = ref.watch(appLockedProvider);

    return MaterialApp(
      title: 'LifeSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: settings.isPinEnabled && isLocked
          ? const PinLockScreen()
          : const AppShell(),
    );
  }
}
