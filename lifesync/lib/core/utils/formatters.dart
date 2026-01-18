import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat timeFormat = DateFormat('hh:mm a');
  static final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat dayFormat = DateFormat('EEE, dd MMM');
  static final DateFormat shortDateFormat = DateFormat('dd/MM/yyyy');

  static String formatDate(DateTime date) => dateFormat.format(date);
  static String formatTime(DateTime time) => timeFormat.format(time);
  static String formatDateTime(DateTime dateTime) =>
      dateTimeFormat.format(dateTime);
  static String formatMonthYear(DateTime date) => monthYearFormat.format(date);
  static String formatDay(DateTime date) => dayFormat.format(date);
  static String formatShortDate(DateTime date) => shortDateFormat.format(date);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static String getRelativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    if (isYesterday(date)) return 'Yesterday';
    return formatDate(date);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    return date.difference(startOfDay(now)).inDays;
  }

  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now()) && !isToday(date);
  }
}

class CurrencyUtils {
  static final NumberFormat currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat compactFormat = NumberFormat.compact();

  static String format(double amount) => currencyFormat.format(amount);
  static String formatCurrency(double amount) => format(amount);

  static String formatCompact(double amount) {
    if (amount.abs() >= 100000) {
      return '₹${compactFormat.format(amount)}';
    }
    return format(amount);
  }

  static String formatWithSign(double amount) {
    final formatted = format(amount.abs());
    if (amount >= 0) {
      return '+$formatted';
    }
    return '-$formatted';
  }
}
