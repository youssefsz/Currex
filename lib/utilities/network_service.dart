import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkService {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  // Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      // For web platform
      if (kIsWeb) {
        return true; // We can't reliably detect connection on web
      }

      // For mobile and desktop platforms
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  // Handle network operations with connection check
  Future<T> withConnectionCheck<T>({
    required Future<T> Function() operation,
    required Function() onNoConnection,
  }) async {
    final hasConnection = await hasInternetConnection();

    if (!hasConnection) {
      onNoConnection();
      throw Exception('No internet connection');
    }

    return operation();
  }
}
