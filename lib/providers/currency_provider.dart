import 'package:flutter/material.dart';
import '../utilities/api_service.dart';
import '../utilities/storage_service.dart';
import '../components/connection_error_popup.dart';

class CurrencyProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  BuildContext? _context;

  // Available currencies
  Map<String, dynamic> _currencies = {};

  // Favorite currencies
  List<String> _favoriteCurrencies = [];

  // Default currency pair
  String _fromCurrency = 'usd';
  String _toCurrency = 'eur';

  // Current amount for conversion
  double _amount = 1.0;

  // Current exchange rate
  double _exchangeRate = 0.0;

  // Current converted amount
  double _convertedAmount = 0.0;

  // Recent conversions
  List<Map<String, dynamic>> _recentConversions = [];

  // Loading states
  bool _isLoadingCurrencies = false;
  bool _isLoadingRate = false;

  // Error states
  String? _currenciesError;
  String? _rateError;

  // Getters
  Map<String, dynamic> get currencies => _currencies;
  List<String> get favoriteCurrencies => _favoriteCurrencies;
  String get fromCurrency => _fromCurrency;
  String get toCurrency => _toCurrency;
  double get amount => _amount;
  double get exchangeRate => _exchangeRate;
  double get convertedAmount => _convertedAmount;
  List<Map<String, dynamic>> get recentConversions => _recentConversions;
  bool get isLoadingCurrencies => _isLoadingCurrencies;
  bool get isLoadingRate => _isLoadingRate;
  String? get currenciesError => _currenciesError;
  String? get rateError => _rateError;

  // Set context for displaying UI elements
  void setContext(BuildContext context) {
    _context = context;
  }

  // Initialize provider
  Future<void> init() async {
    await _loadFavorites();
    await _loadRecentConversions();
    await fetchCurrencies();
    await convertCurrency();
  }

  // Load favorite currencies from storage
  Future<void> _loadFavorites() async {
    final favorites = _storageService.getList('favorites');
    if (favorites != null) {
      _favoriteCurrencies = List<String>.from(favorites);
    }
  }

  // Save favorite currencies to storage
  Future<void> _saveFavorites() async {
    await _storageService.setList('favorites', _favoriteCurrencies);
  }

  // Load recent conversions from storage
  Future<void> _loadRecentConversions() async {
    final recents = _storageService.getList('recentConversions');
    if (recents != null) {
      _recentConversions = List<Map<String, dynamic>>.from(
        recents.map((item) => Map<String, dynamic>.from(item)),
      );
    }
  }

  // Save recent conversions to storage
  Future<void> _saveRecentConversions() async {
    await _storageService.setList('recentConversions', _recentConversions);
  }

  // Fetch all available currencies
  Future<void> fetchCurrencies() async {
    _isLoadingCurrencies = true;
    _currenciesError = null;
    notifyListeners();

    try {
      _currencies = await _apiService.getCurrencies();
      _isLoadingCurrencies = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCurrencies = false;

      if (e.toString().contains('No internet connection')) {
        _currenciesError = 'No internet connection';
        if (_context != null) {
          ConnectionErrorPopup.show(
            _context!,
            onRetry: () => fetchCurrencies(),
          );
        }
      } else {
        _currenciesError = e.toString();
      }

      notifyListeners();
    }
  }

  // Toggle favorite currency
  void toggleFavorite(String currencyCode) {
    if (_favoriteCurrencies.contains(currencyCode)) {
      _favoriteCurrencies.remove(currencyCode);
    } else {
      _favoriteCurrencies.add(currencyCode);
    }
    _saveFavorites();
    notifyListeners();
  }

  // Set from currency
  void setFromCurrency(String currencyCode) {
    _fromCurrency = currencyCode;
    convertCurrency();
    notifyListeners();
  }

  // Set to currency
  void setToCurrency(String currencyCode) {
    _toCurrency = currencyCode;
    convertCurrency();
    notifyListeners();
  }

  // Set amount
  void setAmount(double amount) {
    _amount = amount;
    convertCurrency();
    notifyListeners();
  }

  // Swap currencies
  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    convertCurrency();
    notifyListeners();
  }

  // Convert currency
  Future<void> convertCurrency() async {
    if (_fromCurrency == _toCurrency) {
      _exchangeRate = 1.0;
      _convertedAmount = _amount;
      notifyListeners();
      return;
    }

    _isLoadingRate = true;
    _rateError = null;
    notifyListeners();

    try {
      _exchangeRate = await _apiService.getExchangeRate(
        _fromCurrency,
        _toCurrency,
        _context,
      );
      _convertedAmount = _amount * _exchangeRate;

      // Add to recent conversions
      _addToRecentConversions();

      _isLoadingRate = false;
      notifyListeners();
    } catch (e) {
      _isLoadingRate = false;

      if (e.toString().contains('No internet connection')) {
        _rateError = 'No internet connection';
        // The popup is already shown in the ApiService
      } else {
        _rateError = e.toString();
      }

      notifyListeners();
    }
  }

  // Add current conversion to recent conversions
  void _addToRecentConversions() {
    final now = DateTime.now();
    final conversion = {
      'fromCurrency': _fromCurrency,
      'toCurrency': _toCurrency,
      'amount': _amount,
      'convertedAmount': _convertedAmount,
      'rate': _exchangeRate,
      'timestamp': now.millisecondsSinceEpoch,
      'date':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    };

    // Check if already exists
    final existingIndex = _recentConversions.indexWhere(
      (c) =>
          c['fromCurrency'] == _fromCurrency &&
          c['toCurrency'] == _toCurrency &&
          c['amount'] == _amount,
    );

    if (existingIndex != -1) {
      // Remove existing entry
      _recentConversions.removeAt(existingIndex);
    }

    // Add to beginning of list
    _recentConversions.insert(0, conversion);

    // Limit to 10 recent conversions
    if (_recentConversions.length > 10) {
      _recentConversions = _recentConversions.sublist(0, 10);
    }

    _saveRecentConversions();
  }

  // Clear recent conversions
  void clearRecentConversions() {
    _recentConversions.clear();
    _saveRecentConversions();
    notifyListeners();
  }
}
