import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'ui_state_service.dart';

/// Service for monitoring network connectivity and managing online/offline states
class ConnectivityService {
  static final Logger _logger = Logger();
  static final Connectivity _connectivity = Connectivity();

  // Stream controllers
  static final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  static final StreamController<ConnectivityResult>
      _connectivityResultController =
      StreamController<ConnectivityResult>.broadcast();

  // Current state
  static bool _isOnline = true;
  static ConnectivityResult _currentConnectivityResult =
      ConnectivityResult.none;

  // Callbacks for connection events
  static final List<VoidCallback> _onConnectionRestoredCallbacks = [];
  static final List<VoidCallback> _onConnectionLostCallbacks = [];

  // Getters for streams
  static Stream<bool> get onConnectionStatusChanged =>
      _connectionStatusController.stream;
  static Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivityResultController.stream;

  // Getters for current state
  static bool get isOnline => _isOnline;
  static ConnectivityResult get currentConnectivityResult =>
      _currentConnectivityResult;
  static bool get isOffline => !_isOnline;

  /// Add callback for connection restored event
  static void addConnectionRestoredCallback(VoidCallback callback) {
    _onConnectionRestoredCallbacks.add(callback);
  }

  /// Add callback for connection lost event
  static void addConnectionLostCallback(VoidCallback callback) {
    _onConnectionLostCallbacks.add(callback);
  }

  /// Remove callback for connection restored event
  static void removeConnectionRestoredCallback(VoidCallback callback) {
    _onConnectionRestoredCallbacks.remove(callback);
  }

  /// Remove callback for connection lost event
  static void removeConnectionLostCallback(VoidCallback callback) {
    _onConnectionLostCallbacks.remove(callback);
  }

  /// Initialize the connectivity service
  static Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      _logger.i('Connectivity service initialized. Current status: $_isOnline');
    } catch (e) {
      _logger.e('Error initializing connectivity service: $e');
      _isOnline = false;
      _connectionStatusController.add(false);
    }
  }

  /// Update connection status based on connectivity result
  static Future<void> _updateConnectionStatus(
      List<ConnectivityResult> results) async {
    // Get the first (most relevant) result
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _currentConnectivityResult = result;
    _connectivityResultController.add(result);

    final wasOnline = _isOnline;
    _isOnline = await _isConnectedToInternet(result);

    // Only notify if status changed
    if (wasOnline != _isOnline) {
      _connectionStatusController.add(_isOnline);
      _logger.i('Connection status changed: $_isOnline (Result: $result)');

      // Handle connection status change
      if (_isOnline) {
        await _handleConnectionRestored();
      } else {
        await _handleConnectionLost();
      }
    }
  }

  /// Check if device is actually connected to internet
  static Future<bool> _isConnectedToInternet(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) return false;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) return true;
      // Fallback a DNS público
      final fallback = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));
      return fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.w('Internet connectivity check failed: $e');
      return false;
    }
  }

  /// Handle when connection is restored
  static Future<void> _handleConnectionRestored() async {
    _logger.i('Internet connection restored');

    // Execute registered callbacks for connection restored
    for (final callback in _onConnectionRestoredCallbacks) {
      try {
        callback();
      } catch (e) {
        _logger.e('Error executing connection restored callback: $e');
      }
    }

    // Small delay for stability
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Handle when connection is lost
  static Future<void> _handleConnectionLost() async {
    _logger.w('Internet connection lost');

    // Execute registered callbacks for connection lost
    for (final callback in _onConnectionLostCallbacks) {
      try {
        callback();
      } catch (e) {
        _logger.e('Error executing connection lost callback: $e');
      }
    }
  }

  /// Check current connectivity status
  static Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      final isConnected = await _isConnectedToInternet(result);
      return isConnected;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get connectivity information
  static Future<Map<String, dynamic>> getConnectivityInfo() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      final isConnected = await _isConnectedToInternet(result);

      return {
        'isOnline': isConnected,
        'connectivityResult': result,
        'connectionType': _getConnectionTypeString(result),
        'canAccessInternet': isConnected,
      };
    } catch (e) {
      _logger.e('Error getting connectivity info: $e');
      return {
        'isOnline': false,
        'connectivityResult': ConnectivityResult.none,
        'connectionType': 'Unknown',
        'canAccessInternet': false,
      };
    }
  }

  /// Get human-readable connection type string
  static String _getConnectionTypeString(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Datos móviles';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Otro';
      case ConnectivityResult.none:
        return 'Sin conexión';
    }
  }

  /// Show connectivity status widget
  static Widget buildConnectivityIndicator({
    double size = 16,
    Color onlineColor = Colors.green,
    Color offlineColor = Colors.red,
  }) {
    return StreamBuilder<bool>(
      stream: onConnectionStatusChanged,
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isConnected ? onlineColor : offlineColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: size * 0.6,
          ),
        );
      },
    );
  }

  /// Show connectivity status banner
  static Widget buildConnectivityBanner() {
    return StreamBuilder<bool>(
      stream: onConnectionStatusChanged,
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;

        if (isConnected) {
          return const SizedBox.shrink(); // Hide banner when online
        }

        return Container(
          color: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sin conexión a internet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final isNowConnected = await checkConnectivity();
                  if (isNowConnected) {
                    // Force refresh status
                    final results = await _connectivity.checkConnectivity();
                    await _updateConnectionStatus(results);
                  }
                },
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Execute operation with connectivity check
  static Future<T?> executeWithConnectivityCheck<T>(
    Future<T> Function() operation, {
    T? fallbackValue,
    String? errorMessage,
    BuildContext? context,
  }) async {
    if (!isOnline) {
      _logger.w('Operation cancelled due to no internet connection');
      if (errorMessage != null) {
        if (context != null) {
          UiStateService.showSnackBar(
            context: context,
            message: errorMessage,
            backgroundColor: Colors.red,
          );
        } else {
          _logger.i('Error message: $errorMessage');
        }
      }
      return fallbackValue;
    }

    try {
      return await operation();
    } catch (e) {
      _logger.e('Operation failed: $e');
      if (errorMessage != null) {
        if (context != null) {
          UiStateService.showSnackBar(
            context: context,
            message: errorMessage,
            backgroundColor: Colors.red,
          );
        } else {
          _logger.i('Error message: $errorMessage');
        }
      }
      return fallbackValue;
    }
  }

  /// Wait for connection to be restored
  static Future<void> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (isOnline) {
      return; // Already connected
    }

    final completer = Completer<void>();

    late StreamSubscription<bool> subscription;

    subscription = onConnectionStatusChanged.listen((isConnected) {
      if (isConnected) {
        subscription.cancel();
        completer.complete();
      }
    });

    // Set timeout
    Future.delayed(timeout).then((_) {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(TimeoutException('Connection timeout'));
      }
    });

    return completer.future;
  }

  /// Dispose of resources
  static void dispose() {
    _connectionStatusController.close();
    _connectivityResultController.close();
  }
}

/// Singleton instance
final connectivityService = ConnectivityService();
