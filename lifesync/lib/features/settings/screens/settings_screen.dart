import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/settings_provider.dart';
import '../widgets/pin_setup_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: settings.isDarkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setDarkMode(value);
                },
                secondary: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Security Section
          _buildSectionHeader(context, 'Security'),
          _buildSettingCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                title: const Text('App Lock'),
                subtitle: Text(settings.isPinEnabled
                    ? 'PIN protection enabled'
                    : 'Protect app with PIN'),
                value: settings.isPinEnabled,
                onChanged: (value) async {
                  if (value) {
                    // Enable PIN
                    final pin = await showDialog<String>(
                      context: context,
                      builder: (context) => const PinSetupDialog(),
                    );
                    if (pin != null && pin.length == 4) {
                      ref.read(settingsProvider.notifier).enablePin(pin);
                    }
                  } else {
                    // Disable PIN
                    ref.read(settingsProvider.notifier).disablePin();
                  }
                },
                secondary: Icon(
                  settings.isPinEnabled ? Icons.lock : Icons.lock_open,
                  color: AppColors.primary,
                ),
              ),
              if (settings.isPinEnabled) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.password, color: AppColors.primary),
                  title: const Text('Change PIN'),
                  onTap: () async {
                    final pin = await showDialog<String>(
                      context: context,
                      builder: (context) => const PinSetupDialog(isChange: true),
                    );
                    if (pin != null && pin.length == 4) {
                      ref.read(settingsProvider.notifier).updatePin(pin);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PIN updated successfully')),
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Preferences Section
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.currency_rupee, color: AppColors.primary),
                title: const Text('Currency'),
                subtitle: Text(settings.currencySymbol),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCurrencyPicker(context, ref),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Task reminders & budget alerts'),
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setNotificationsEnabled(value);
                },
                secondary: Icon(
                  settings.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.alarm, color: AppColors.primary),
                title: const Text('Default Reminder'),
                subtitle: Text('${settings.defaultReminderMinutes} minutes before'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showReminderPicker(context, ref, settings.defaultReminderMinutes),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Data Section
          _buildSectionHeader(context, 'Data'),
          _buildSettingCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.backup, color: AppColors.primary),
                title: const Text('Backup Data'),
                subtitle: settings.lastBackupDate != null
                    ? Text('Last backup: ${_formatDate(settings.lastBackupDate!)}')
                    : const Text('Never backed up'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement backup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup feature coming soon!')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restore, color: AppColors.primary),
                title: const Text('Restore Data'),
                subtitle: const Text('Restore from backup'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement restore
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restore feature coming soon!')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.file_download, color: AppColors.primary),
                title: const Text('Export Data'),
                subtitle: const Text('Export to CSV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildSettingCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('LifeSync'),
                subtitle: const Text('Version 1.0.0'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXL),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingS,
        bottom: AppSizes.paddingS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final currencies = [
      ('₹', 'Indian Rupee'),
      ('\$', 'US Dollar'),
      ('€', 'Euro'),
      ('£', 'British Pound'),
      ('¥', 'Japanese Yen'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((c) {
            return ListTile(
              leading: Text(c.$1, style: const TextStyle(fontSize: 24)),
              title: Text(c.$2),
              onTap: () {
                ref.read(settingsProvider.notifier).setCurrencySymbol(c.$1);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReminderPicker(BuildContext context, WidgetRef ref, int current) {
    final options = [5, 10, 15, 30, 60, 120];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((minutes) {
            String label;
            if (minutes < 60) {
              label = '$minutes minutes before';
            } else {
              label = '${minutes ~/ 60} hour(s) before';
            }
            return RadioListTile<int>(
              value: minutes,
              groupValue: current,
              title: Text(label),
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setDefaultReminderMinutes(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
