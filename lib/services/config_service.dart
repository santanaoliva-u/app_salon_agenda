import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Service for managing all application configuration from environment variables
class ConfigService extends ChangeNotifier {
  static final Logger _logger = Logger();

  // Singleton instance
  static ConfigService? _instance;
  static ConfigService get instance {
    _instance ??= ConfigService._();
    return _instance!;
  }

  ConfigService._();

  bool _isInitialized = false;
  late SharedPreferences _prefs;

  // =============================================================================
  // API KEYS Y SERVICIOS EXTERNOS
  // =============================================================================

  // Google Services
  String? get googleMapsApiKey => _getEnvString('GOOGLE_MAPS_API_KEY');
  String? get googlePlacesApiKey => _getEnvString('GOOGLE_PLACES_API_KEY');

  // Firebase Configuration
  String? get firebaseApiKey => _getEnvString('FIREBASE_API_KEY');
  String? get firebaseAuthDomain => _getEnvString('FIREBASE_AUTH_DOMAIN');
  String? get firebaseProjectId => _getEnvString('FIREBASE_PROJECT_ID');
  String? get firebaseStorageBucket => _getEnvString('FIREBASE_STORAGE_BUCKET');
  String? get firebaseMessagingSenderId =>
      _getEnvString('FIREBASE_MESSAGING_SENDER_ID');
  String? get firebaseAppId => _getEnvString('FIREBASE_APP_ID');
  String? get firebaseMeasurementId => _getEnvString('FIREBASE_MEASUREMENT_ID');

  // Payment Services
  String? get stripePublishableKey => _getEnvString('STRIPE_PUBLISHABLE_KEY');
  String? get stripeSecretKey => _getEnvString('STRIPE_SECRET_KEY');

  // Push Notifications
  String? get oneSignalAppId => _getEnvString('ONESIGNAL_APP_ID');
  String? get oneSignalRestApiKey => _getEnvString('ONESIGNAL_REST_API_KEY');

  // =============================================================================
  // CONFIGURACIÓN DE LA APLICACIÓN
  // =============================================================================

  String get appName => _getEnvString('APP_NAME') ?? 'Salon Booking App';
  String get appVersion => _getEnvString('APP_VERSION') ?? '1.0.0';
  String get appEnvironment =>
      _getEnvString('APP_ENVIRONMENT') ?? 'development';

  // Feature Flags
  bool get firebaseEnabled => _getEnvBool('FIREBASE_ENABLED') ?? false;
  bool get offlineModeEnabled => _getEnvBool('OFFLINE_MODE_ENABLED') ?? true;
  bool get pushNotificationsEnabled =>
      _getEnvBool('PUSH_NOTIFICATIONS_ENABLED') ?? false;
  bool get paymentsEnabled => _getEnvBool('PAYMENTS_ENABLED') ?? false;
  bool get analyticsEnabled => _getEnvBool('ANALYTICS_ENABLED') ?? false;

  // UI Configuration
  Color get themePrimaryColor =>
      _parseColor(_getEnvString('THEME_PRIMARY_COLOR') ?? '#721c80');
  Color get themeSecondaryColor =>
      _parseColor(_getEnvString('THEME_SECONDARY_COLOR') ?? '#196103');
  String get defaultLanguage => _getEnvString('DEFAULT_LANGUAGE') ?? 'es';
  List<String> get supportedLanguages =>
      _getEnvString('SUPPORTED_LANGUAGES')?.split(',') ?? ['en', 'es'];

  // =============================================================================
  // CONFIGURACIÓN DE RED Y CONECTIVIDAD
  // =============================================================================

  int get networkTimeoutSeconds => _getEnvInt('NETWORK_TIMEOUT_SECONDS') ?? 30;
  int get networkRetryAttempts => _getEnvInt('NETWORK_RETRY_ATTEMPTS') ?? 3;
  int get networkRetryDelaySeconds =>
      _getEnvInt('NETWORK_RETRY_DELAY_SECONDS') ?? 2;

  // Cache Configuration
  bool get cacheEnabled => _getEnvBool('CACHE_ENABLED') ?? true;
  int get cacheMaxSizeMb => _getEnvInt('CACHE_MAX_SIZE_MB') ?? 50;
  int get cacheExpirationHours => _getEnvInt('CACHE_EXPIRATION_HOURS') ?? 24;

  // =============================================================================
  // CONFIGURACIÓN DE LOGGING
  // =============================================================================

  String get logLevel => _getEnvString('LOG_LEVEL') ?? 'info';
  String get logMaxFileSize => _getEnvString('LOG_MAX_FILE_SIZE') ?? '10MB';
  int get logMaxFiles => _getEnvInt('LOG_MAX_FILES') ?? 5;
  bool get logToConsole => _getEnvBool('LOG_TO_CONSOLE') ?? true;
  bool get logToFile => _getEnvBool('LOG_TO_FILE') ?? true;

  // =============================================================================
  // CONFIGURACIÓN DE ALMACENAMIENTO
  // =============================================================================

  int get maxFileSizeMb => _getEnvInt('MAX_FILE_SIZE_MB') ?? 10;
  List<String> get allowedFileTypes =>
      _getEnvString('ALLOWED_FILE_TYPES')?.split(',') ??
      ['jpg', 'jpeg', 'png', 'pdf'];
  String get uploadPath => _getEnvString('UPLOAD_PATH') ?? '/uploads/';

  // Image Configuration
  int get imageMaxWidth => _getEnvInt('IMAGE_MAX_WIDTH') ?? 1920;
  int get imageMaxHeight => _getEnvInt('IMAGE_MAX_HEIGHT') ?? 1080;
  int get imageQuality => _getEnvInt('IMAGE_QUALITY') ?? 85;

  // =============================================================================
  // CONFIGURACIÓN DE SEGURIDAD
  // =============================================================================

  String? get jwtSecret => _getEnvString('JWT_SECRET');
  int get jwtExpirationHours => _getEnvInt('JWT_EXPIRATION_HOURS') ?? 24;

  String? get encryptionKey => _getEnvString('ENCRYPTION_KEY');
  String? get encryptionIv => _getEnvString('ENCRYPTION_IV');

  // =============================================================================
  // CONFIGURACIÓN DE NEGOCIO
  // =============================================================================

  int get maxBookingsPerDay => _getEnvInt('MAX_BOOKINGS_PER_DAY') ?? 10;
  int get minAdvanceBookingHours =>
      _getEnvInt('MIN_ADVANCE_BOOKING_HOURS') ?? 2;
  int get maxAdvanceBookingDays => _getEnvInt('MAX_ADVANCE_BOOKING_DAYS') ?? 30;

  // =============================================================================
  // MÉTODOS DE INICIALIZACIÓN
  // =============================================================================

  /// Initialize the configuration service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      _isInitialized = true;
      _logger.i('ConfigService initialized successfully');

      notifyListeners();
    } catch (e) {
      _logger.e('Error initializing ConfigService: $e');
      // Continue with default values
      _isInitialized = true;
      notifyListeners();
    }
  }

  // =============================================================================
  // MÉTODOS DE ACCESO A VARIABLES
  // =============================================================================

  /// Get string value from environment or SharedPreferences
  String? _getEnvString(String key) {
    // First try environment variables
    String? value = dotenv.env[key];
    if (value != null && value.isNotEmpty && !value.contains('your_')) {
      return value;
    }

    // Fallback to SharedPreferences
    return _prefs.getString(key);
  }

  /// Get boolean value from environment or SharedPreferences
  bool? _getEnvBool(String key) {
    String? value = _getEnvString(key);
    if (value != null) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  /// Get integer value from environment or SharedPreferences
  int? _getEnvInt(String key) {
    String? value = _getEnvString(key);
    if (value != null) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Parse color from hex string
  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      _logger.w('Error parsing color $hexColor, using default');
      return const Color(0xFF721c80);
    }
  }

  // =============================================================================
  // MÉTODOS DE CONFIGURACIÓN DINÁMICA
  // =============================================================================

  /// Update configuration value
  Future<bool> updateConfig(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else {
        await _prefs.setString(key, jsonEncode(value));
      }

      _logger.i('Configuration updated: $key = $value');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Error updating configuration: $e');
      return false;
    }
  }

  /// Get all configuration as map
  Map<String, dynamic> getAllConfig() {
    return {
      // API Keys
      'googleMapsApiKey': googleMapsApiKey,
      'firebaseEnabled': firebaseEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,

      // App Config
      'appName': appName,
      'appVersion': appVersion,
      'appEnvironment': appEnvironment,

      // UI Config
      'themePrimaryColor': themePrimaryColor.toARGB32(),
      'defaultLanguage': defaultLanguage,

      // Network Config
      'networkTimeoutSeconds': networkTimeoutSeconds,
      'cacheEnabled': cacheEnabled,

      // Business Rules
      'maxBookingsPerDay': maxBookingsPerDay,
      'minAdvanceBookingHours': minAdvanceBookingHours,
    };
  }

  /// Reset configuration to defaults
  Future<void> resetToDefaults() async {
    try {
      await _prefs.clear();
      _logger.i('Configuration reset to defaults');
      notifyListeners();
    } catch (e) {
      _logger.e('Error resetting configuration: $e');
    }
  }

  /// Check if configuration is valid for production
  bool isProductionReady() {
    final requiredKeys = [
      'GOOGLE_MAPS_API_KEY',
      'FIREBASE_PROJECT_ID',
    ];

    for (final key in requiredKeys) {
      final value = _getEnvString(key);
      if (value == null || value.isEmpty || value.contains('your_')) {
        _logger.w('Missing or invalid configuration: $key');
        return false;
      }
    }

    return true;
  }

  /// Export configuration for debugging (without sensitive data)
  Map<String, dynamic> exportSafeConfig() {
    final config = getAllConfig();

    // Remove sensitive information
    config.removeWhere((key, value) =>
        key.contains('key') ||
        key.contains('secret') ||
        key.contains('password') ||
        key.contains('token'));

    return config;
  }
}

/// Global instance for easy access
final configService = ConfigService.instance;
