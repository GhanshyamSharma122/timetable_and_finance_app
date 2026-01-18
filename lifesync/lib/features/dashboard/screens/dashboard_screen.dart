import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/task_summary_card.dart';
import '../widgets/finance_summary_card.dart';
import '../widgets/upcoming_dues_card.dart';
import '../widgets/today_tasks_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LifeSync',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateTimeUtils.formatDay(DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implement global search
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting Card
                  _buildGreetingCard(context),
                  const SizedBox(height: AppSizes.paddingM),

                  // Summary Row
                  Row(
                    children: const [
                      Expanded(child: TaskSummaryCard()),
                      SizedBox(width: AppSizes.paddingM),
                      Expanded(child: FinanceSummaryCard()),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Upcoming Dues
                  const UpcomingDuesCard(),
                  const SizedBox(height: AppSizes.paddingM),

                  // Today's Tasks Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Tasks",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to timetable
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Today's Tasks List
                  const TodayTasksList(),
                  const SizedBox(height: 80), // Space for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData icon;
    List<Color> gradientColors;

    if (hour < 12) {
      greeting = 'Good Morning';
      icon = Icons.wb_sunny;
      gradientColors = [const Color(0xFFFF9A56), const Color(0xFFFFBF44)];
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      icon = Icons.wb_sunny_outlined;
      gradientColors = [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
    } else {
      greeting = 'Good Evening';
      icon = Icons.nights_stay;
      gradientColors = [const Color(0xFF667EEA), const Color(0xFF764BA2)];
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Let\'s make today productive!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 48,
          ),
        ],
      ),
    );
  }
}
