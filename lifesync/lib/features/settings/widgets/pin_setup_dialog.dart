import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class PinSetupDialog extends StatefulWidget {
  final bool isChange;

  const PinSetupDialog({super.key, this.isChange = false});

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;

  void _onNumberPressed(String number) {
    setState(() {
      _error = null;
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += number;
        }
        if (_pin.length == 4) {
          _isConfirming = true;
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
        }
        if (_confirmPin.length == 4) {
          if (_pin == _confirmPin) {
            Navigator.pop(context, _pin);
          } else {
            _error = 'PINs do not match';
            _confirmPin = '';
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _error = null;
      if (!_isConfirming) {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isChange ? 'Change PIN' : 'Set Up PIN',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Enter a 4-digit PIN',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < currentPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? AppColors.primary
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSizes.paddingS),
              Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],

            const SizedBox(height: AppSizes.paddingL),

            // Number Pad
            _buildNumberPad(isDark),

            const SizedBox(height: AppSizes.paddingM),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(bool isDark) {
    return Column(
      children: [
        for (int row = 0; row < 4; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildNumberButton(row, col, isDark),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNumberButton(int row, int col, bool isDark) {
    String? number;
    Widget? icon;

    if (row < 3) {
      number = '${row * 3 + col + 1}';
    } else {
      if (col == 0) {
        return const SizedBox(width: 56, height: 56);
      } else if (col == 1) {
        number = '0';
      } else {
        icon = Icon(
          Icons.backspace_outlined,
          size: 20,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          if (number != null) {
            _onNumberPressed(number);
          } else if (icon != null) {
            _onDeletePressed();
          }
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.cardDark : Colors.grey.shade100,
          ),
          child: Center(
            child: number != null
                ? Text(
                    number,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  )
                : icon,
          ),
        ),
      ),
    );
  }
}
