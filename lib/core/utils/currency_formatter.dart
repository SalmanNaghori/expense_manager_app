import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format a double amount as a currency string dynamically based on target symbol and locale
  static String format(double amount, String currency, {String locale = 'en'}) {
    final format = NumberFormat.currency(
      locale: locale == 'es' ? 'es_ES' : 'en_US',
      symbol: _getSymbol(currency),
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String _getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return '$currencyCode ';
    }
  }
}
