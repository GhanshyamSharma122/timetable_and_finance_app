import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lending.dart';
import '../widgets/lending_tile.dart';
import 'add_lending_screen.dart';

final lendingTabProvider = StateProvider<int>((ref) => 0);

class LendingScreen extends ConsumerWidget {
  const LendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(lendingTabProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lending'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<LendingModel>('lendings').listenable(),
        builder: (context, Box<LendingModel> box, _) {
          final allLendings = box.values.toList();

          // Calculate totals
          double totalOwed = 0; // Money owed to me
          double totalOwe = 0; // Money I owe

          final pendingLent = <LendingModel>[];
          final pendingBorrowed = <LendingModel>[];
          final settled = <LendingModel>[];

          for (final l in allLendings) {
            if (l.status == LendingStatus.pending) {
              if (l.type == LendingType.lent) {
                totalOwed += l.amount;
                pendingLent.add(l);
              } else {
                totalOwe += l.amount;
                pendingBorrowed.add(l);
              }
            } else {
              settled.add(l);
            }
          }

          // Sort by due date
          pendingLent.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });
          pendingBorrowed.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });

          final netBalance = totalOwed - totalOwe;

          return Column(
            children: [
              // Balance Summary
              Container(
                margin: const EdgeInsets.all(AppSizes.paddingM),
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: netBalance >= 0
                        ? [AppColors.success, AppColors.secondaryLight]
                        : [AppColors.error, const Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Column(
                  children: [
                    Text(
                      'Net Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyUtils.format(netBalance.abs()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      netBalance >= 0 ? 'You will receive' : 'You need to pay',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalancePill(
                            'To Receive',
                            totalOwed,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: _buildBalancePill(
                            'To Pay',
                            totalOwe,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    _buildTab(
                      index: 0,
                      label: 'Money Owed',
                      count: pendingLent.length,
                      isSelected: selectedTab == 0,
                      color: AppColors.success,
                      onTap: () =>
                          ref.read(lendingTabProvider.notifier).state = 0,
                    ),
                    _buildTab(
                      index: 1,
                      label: 'Money I Owe',
                      count: pendingBorrowed.length,
                      isSelected: selectedTab == 1,
                      color: AppColors.error,
                      onTap: () =>
                          ref.read(lendingTabProvider.notifier).state = 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.paddingM),

              // List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final list = selectedTab == 0 ? pendingLent : pendingBorrowed;

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedTab == 0
                                  ? Icons.sentiment_satisfied_alt
                                  : Icons.celebration,
                              size: 64,
                              color: (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight)
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: AppSizes.paddingM),
                            Text(
                              selectedTab == 0
                                  ? 'No one owes you money'
                                  : "You don't owe anyone",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
                          child: LendingTile(lending: list[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalancePill(String label, double amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
              Text(
                CurrencyUtils.formatCompact(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required String label,
    required int count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
