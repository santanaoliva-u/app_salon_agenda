import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing API configurations with fallback modes
class ApiConfigService extends ChangeNotifier {
  static const String _googleMapsKey = 'GOOGLE_MAPS_API_KEY';
  static const String _firebaseEnabledKey = 'FIREBASE_ENABLED';

  String? _googleMapsApiKey;
  bool _firebaseEnabled = true;
  bool _isInitialized = false;

  // Getters
  String? get googleMapsApiKey => _googleMapsApiKey;
  bool get firebaseEnabled => _firebaseEnabled;
  bool get isInitialized => _isInitialized;
  bool get hasValidGoogleMapsKey =>
      _googleMapsApiKey != null &&
      _googleMapsApiKey!.isNotEmpty &&
      !_googleMapsApiKey!.contains('your_');

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load from environment variables first
      _googleMapsApiKey = dotenv.env[_googleMapsKey];

      // Load from shared preferences (user can override)
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString(_googleMapsKey);
      if (storedKey != null && storedKey.isNotEmpty) {
        _googleMapsApiKey = storedKey;
      }

      _firebaseEnabled = prefs.getBool(_firebaseEnabledKey) ?? true;

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing ApiConfigService: $e');
      _isInitialized = true; // Mark as initialized even on error
      notifyListeners();
    }
  }

  /// Update Google Maps API key
  Future<bool> updateGoogleMapsApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_googleMapsKey, apiKey);
      _googleMapsApiKey = apiKey;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating Google Maps API key: $e');
      return false;
    }
  }

  /// Toggle Firebase functionality
  Future<bool> toggleFirebase(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firebaseEnabledKey, enabled);
      _firebaseEnabled = enabled;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling Firebase: $e');
      return false;
    }
  }

  /// Reset to default configuration
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_googleMapsKey);
      await prefs.remove(_firebaseEnabledKey);

      _googleMapsApiKey = dotenv.env[_googleMapsKey];
      _firebaseEnabled = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting to defaults: $e');
    }
  }

  /// Get configuration status for UI display
  Map<String, dynamic> getConfigurationStatus() {
    return {
      'googleMapsConfigured': hasValidGoogleMapsKey,
      'firebaseEnabled': _firebaseEnabled,
      'googleMapsKey': _googleMapsApiKey ?? 'No configurada',
      'backupMode': !hasValidGoogleMapsKey,
    };
  }
}

/// Singleton instance
final apiConfigService = ApiConfigService();
