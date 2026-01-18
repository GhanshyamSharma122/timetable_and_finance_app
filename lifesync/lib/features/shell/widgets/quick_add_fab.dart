import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../timetable/screens/add_task_screen.dart';
import '../../finance/screens/add_transaction_screen.dart';
import '../../lending/screens/add_lending_screen.dart';

class QuickAddFAB extends ConsumerStatefulWidget {
  const QuickAddFAB({super.key});

  @override
  ConsumerState<QuickAddFAB> createState() => _QuickAddFABState();
}

class _QuickAddFABState extends ConsumerState<QuickAddFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded options
        ScaleTransition(
          scale: _expandAnimation,
          alignment: Alignment.bottomRight,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMiniButton(
                  icon: Icons.calendar_today,
                  label: 'Task',
                  color: AppColors.categoryWork,
                  onTap: () {
                    _close();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTaskScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMiniButton(
                  icon: Icons.remove_circle_outline,
                  label: 'Expense',
                  color: AppColors.error,
                  onTap: () {
                    _close();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(isExpense: true),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMiniButton(
                  icon: Icons.add_circle_outline,
                  label: 'Income',
                  color: AppColors.success,
                  onTap: () {
                    _close();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(isExpense: false),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMiniButton(
                  icon: Icons.swap_horiz,
                  label: 'Lending',
                  color: AppColors.info,
                  onTap: () {
                    _close();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddLendingScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Main FAB
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 250),
            turns: _isExpanded ? 0.125 : 0,
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }
}
