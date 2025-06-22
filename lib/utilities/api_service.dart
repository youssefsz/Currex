import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/connection_error_popup.dart';
import 'network_service.dart';

class ApiService {
  final NetworkService _networkService = NetworkService();
  static const String baseUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';

  // Get all available currencies
  Future<Map<String, dynamic>> getCurrencies() async {
    return _networkService.withConnectionCheck(
      operation: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/currencies.json'),
          );

          if (response.statusCode == 200) {
            return json.decode(response.body);
          } else {
            throw Exception(
              'Failed to load currencies: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (e.toString().contains('No internet connection')) {
            rethrow;
          }
          throw Exception('Error fetching currencies: $e');
        }
      },
      onNoConnection: () {},
    );
  }

  // Get exchange rate from one currency to another
  Future<double> getExchangeRate(
    String fromCurrency,
    String toCurrency, [
    BuildContext? context,
  ]) async {
    return _networkService.withConnectionCheck(
      operation: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/currencies/${fromCurrency.toLowerCase()}.json'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final rates = data[fromCurrency.toLowerCase()];
            if (rates != null && rates.containsKey(toCurrency.toLowerCase())) {
              return rates[toCurrency.toLowerCase()].toDouble();
            } else {
              throw Exception(
                'Currency pair ${fromCurrency.toUpperCase()}/${toCurrency.toUpperCase()} not found',
              );
            }
          } else {
            throw Exception(
              'Failed to load exchange rate: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (e.toString().contains('No internet connection')) {
            rethrow;
          }
          throw Exception('Error fetching exchange rate: $e');
        }
      },
      onNoConnection: () {
        if (context != null) {
          ConnectionErrorPopup.show(context);
        }
      },
    );
  }

  // Convert amount from one currency to another
  Future<double> convertCurrency(
    String fromCurrency,
    String toCurrency,
    double amount, [
    BuildContext? context,
  ]) async {
    try {
      final rate = await getExchangeRate(fromCurrency, toCurrency, context);
      return amount * rate;
    } catch (e) {
      rethrow;
    }
  }

  // Get historical data for a specific currency pair
  Future<Map<String, dynamic>> getHistoricalData(
    String fromCurrency,
    String toCurrency,
    String date, [ // Format: YYYY-MM-DD
    BuildContext? context,
  ]) async {
    return _networkService.withConnectionCheck(
      operation: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/currencies/$fromCurrency/$toCurrency.json'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            return {'date': date, 'rate': data[toCurrency].toDouble()};
          } else {
            throw Exception(
              'Failed to load historical data: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (e.toString().contains('No internet connection')) {
            rethrow;
          }
          throw Exception('Error fetching historical data: $e');
        }
      },
      onNoConnection: () {
        if (context != null) {
          ConnectionErrorPopup.show(context);
        }
      },
    );
  }

  // Generate mock historical data for charts
  // In a real app, you'd fetch this from an API with historical endpoints
  Future<List<Map<String, dynamic>>> getMockHistoricalData(
    String fromCurrency,
    String toCurrency,
    String period, [ // 1d, 1w, 1m, 3m, 6m, 1y
    BuildContext? context,
  ]) async {
    return _networkService.withConnectionCheck(
      operation: () async {
        final now = DateTime.now();
        final List<Map<String, dynamic>> result = [];
        int days;

        switch (period) {
          case '1d':
            days = 1;
            break;
          case '1w':
            days = 7;
            break;
          case '1m':
            days = 30;
            break;
          case '3m':
            days = 90;
            break;
          case '6m':
            days = 180;
            break;
          case '1y':
            days = 365;
            break;
          default:
            days = 30;
        }

        final baseRate = await getExchangeRate(
          fromCurrency,
          toCurrency,
          context,
        );

        // Generate data points
        for (int i = days; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final formattedDate =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          // Add some random variation to create realistic looking charts
          final randomFactor =
              0.95 +
              (0.1 * (DateTime.now().millisecondsSinceEpoch % 100) / 100);
          final rate = baseRate * randomFactor;

          result.add({'date': formattedDate, 'rate': rate});
        }

        return result;
      },
      onNoConnection: () {
        if (context != null) {
          ConnectionErrorPopup.show(context);
        }
      },
    );
  }
}
