import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _inrDecimalFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compact(locale: 'en_IN');

  /// Format as Indian rupees: ₹1,200
  static String inr(num amount) => _inrFormatter.format(amount);

  /// Format with decimals: ₹1,200.50
  static String inrDecimal(num amount) => _inrDecimalFormatter.format(amount);

  /// Compact format: ₹24.5K, ₹1.2L
  static String inrCompact(num amount) {
    final compact = _compactFormatter.format(amount);
    return '₹$compact';
  }

  /// Format date: 15 Sep 2026
  static String date(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

  /// Format date-time: 15 Sep 2026, 2:30 PM
  static String dateTime(DateTime dt) =>
      DateFormat('d MMM yyyy, h:mm a').format(dt);

  /// Relative time: 2 hours ago, just now, yesterday
  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  /// Mask Aadhaar: XXXX XXXX 1234
  static String maskAadhaar(String aadhaar) {
    final digits = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12) return aadhaar;
    return 'XXXX XXXX ${digits.substring(8)}';
  }

  /// Mask account number: ****1234
  static String maskAccount(String account) {
    if (account.length <= 4) return account;
    return '${'*' * (account.length - 4)}${account.substring(account.length - 4)}';
  }

  /// Format stock: 24 units, 0 units (sold out)
  static String stock(int count) => count == 0
      ? 'Sold Out'
      : '$count unit${count == 1 ? '' : 's'}';

  /// Format percentage: 75.3%
  static String percent(double value) =>
      '${value.toStringAsFixed(1)}%';

  /// Truncate string: "Handwoven Varan..." 
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
