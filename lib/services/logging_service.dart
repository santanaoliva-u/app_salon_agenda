import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:salon_app/services/connectivity_service.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Log entry model
class LogEntry {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final String? sessionId;
  final String? stackTrace;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.metadata,
    this.userId,
    this.sessionId,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString().split('.').last,
      'message': message,
      'tag': tag,
      'metadata': metadata,
      'userId': userId,
      'sessionId': sessionId,
      'stackTrace': stackTrace,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'],
      tag: json['tag'],
      metadata: json['metadata'],
      userId: json['userId'],
      sessionId: json['sessionId'],
      stackTrace: json['stackTrace'],
    );
  }
}

/// Centralized logging service with multiple outputs
class LoggingService {
  static final Logger _consoleLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static Database? _database;
  static const String _dbName = 'logs.db';
  static const String _logsTable = 'logs';
  static const String _configTable = 'log_config';

  // Configuration
  static bool _enableFileLogging = true;
  static bool _enableDatabaseLogging = true;
  static bool _enableRemoteLogging = false;
  static int _maxLocalLogs = 1000;
  static Duration _logRetentionPeriod = const Duration(days: 7);
  static LogLevel _minLogLevel = LogLevel.debug;

  // Session tracking
  static String? _currentSessionId;
  static String? _currentUserId;

  // Remote logging endpoint (for future implementation)
  static String? _remoteEndpoint;

  /// Initialize the logging service
  static Future<void> initialize({
    bool enableFileLogging = true,
    bool enableDatabaseLogging = true,
    bool enableRemoteLogging = false,
    int maxLocalLogs = 1000,
    Duration logRetentionPeriod = const Duration(days: 7),
    LogLevel minLogLevel = LogLevel.debug,
    String? remoteEndpoint,
  }) async {
    _enableFileLogging = enableFileLogging;
    _enableDatabaseLogging = enableDatabaseLogging;
    _enableRemoteLogging = enableRemoteLogging;
    _maxLocalLogs = maxLocalLogs;
    _logRetentionPeriod = logRetentionPeriod;
    _minLogLevel = minLogLevel;
    _remoteEndpoint = remoteEndpoint;

    // Generate session ID
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    if (_enableDatabaseLogging) {
      await _initDatabase();
    }

    // Clean up old logs periodically
    Timer.periodic(const Duration(hours: 1), (_) => _cleanupOldLogs());

    log(LogLevel.info, 'Logging service initialized', tag: 'LoggingService');
  }

  /// Initialize database for log storage
  static Future<void> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_logsTable (
              id TEXT PRIMARY KEY,
              timestamp TEXT NOT NULL,
              level TEXT NOT NULL,
              message TEXT NOT NULL,
              tag TEXT,
              metadata TEXT,
              userId TEXT,
              sessionId TEXT,
              stackTrace TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE $_configTable (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      // CORRECCIÓN: Manejar errores de plugins no disponibles en tests
      if (e.toString().contains('Binding has not yet been initialized') ||
          e.toString().contains('MissingPluginException')) {
        // En tests, deshabilitar logging de base de datos
        _enableDatabaseLogging = false;
        debugPrint('Database logging disabled in test environment');
        return;
      }
      rethrow;
    }
  }

  /// Set current user for logging context
  static void setUserContext(String userId) {
    _currentUserId = userId;
  }

  /// Clear user context
  static void clearUserContext() {
    _currentUserId = null;
  }

  /// Main logging method
  static void log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    String? stackTrace,
  }) {
    if (level.index < _minLogLevel.index) return;

    final logEntry = LogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_${level.toString()}',
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      metadata: metadata,
      userId: _currentUserId,
      sessionId: _currentSessionId,
      stackTrace: stackTrace,
    );

    // Console logging
    _logToConsole(logEntry);

    // Database logging
    if (_enableDatabaseLogging) {
      _logToDatabase(logEntry);
    }

    // File logging
    if (_enableFileLogging) {
      _logToFile(logEntry);
    }

    // Remote logging
    if (_enableRemoteLogging && ConnectivityService.isOnline) {
      _logToRemote(logEntry);
    }
  }

  /// Log to console with appropriate level
  static void _logToConsole(LogEntry entry) {
    final message = '[${entry.tag ?? 'App'}] ${entry.message}';

    switch (entry.level) {
      case LogLevel.debug:
        _consoleLogger.d(message);
        break;
      case LogLevel.info:
        _consoleLogger.i(message);
        break;
      case LogLevel.warning:
        _consoleLogger.w(message);
        break;
      case LogLevel.error:
        _consoleLogger.e(message, error: entry.stackTrace);
        break;
      case LogLevel.critical:
        _consoleLogger.f(message, error: entry.stackTrace);
        break;
    }
  }

  /// Log to database
  static Future<void> _logToDatabase(LogEntry entry) async {
    if (_database == null) return;

    try {
      await _database!.insert(
        _logsTable,
        entry.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Maintain max log limit
      final count = Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM $_logsTable'),
          ) ??
          0;

      if (count > _maxLocalLogs) {
        final excess = count - _maxLocalLogs;
        await _database!.rawDelete('''
          DELETE FROM $_logsTable
          WHERE id IN (
            SELECT id FROM $_logsTable
            ORDER BY timestamp ASC
            LIMIT ?
          )
        ''', [excess]);
      }
    } catch (e) {
      debugPrint('Error logging to database: $e');
    }
  }

  /// Log to file
  static Future<void> _logToFile(LogEntry entry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app_logs.txt');

      final logLine = '${entry.timestamp.toIso8601String()} '
          '[${entry.level.toString().split('.').last.toUpperCase()}] '
          '[${entry.tag ?? 'App'}] '
          '${entry.message}\n';

      await logFile.writeAsString(logLine, mode: FileMode.append);
    } catch (e) {
      // CORRECCIÓN: Manejar errores de plugins no disponibles en tests
      if (e.toString().contains('Binding has not yet been initialized') ||
          e.toString().contains('MissingPluginException')) {
        // En tests, no intentar escribir a archivo
        return;
      }
      debugPrint('Error logging to file: $e');
    }
  }

  /// Log to remote server
  static Future<void> _logToRemote(LogEntry entry) async {
    if (_remoteEndpoint == null) return;

    try {
      final response = await http.post(
        Uri.parse(_remoteEndpoint!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Log sent to remote successfully');
      } else {
        debugPrint(
            'Failed to send log to remote: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error logging to remote: $e');
    }
  }

  /// Clean up old logs
  static Future<void> _cleanupOldLogs() async {
    if (_database == null) return;

    try {
      final cutoffDate = DateTime.now().subtract(_logRetentionPeriod);
      await _database!.delete(
        _logsTable,
        where: 'timestamp < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );
    } catch (e) {
      debugPrint('Error cleaning up old logs: $e');
    }
  }

  /// Get logs from database
  static Future<List<LogEntry>> getLogs({
    LogLevel? level,
    String? tag,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    if (_database == null) return [];

    try {
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (level != null) {
        whereClause += 'level = ?';
        whereArgs.add(level.toString().split('.').last);
      }

      if (tag != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'tag = ?';
        whereArgs.add(tag);
      }

      if (startDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'timestamp >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'timestamp <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final results = await _database!.query(
        _logsTable,
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return results.map((row) => LogEntry.fromJson(row)).toList();
    } catch (e) {
      debugPrint('Error getting logs: $e');
      return [];
    }
  }

  /// Get log statistics
  static Future<Map<String, dynamic>> getLogStats() async {
    if (_database == null) {
      return {
        'totalLogs': 0,
        'logsByLevel': {},
        'recentErrors': 0,
        'storageSize': 0,
      };
    }

    try {
      final totalLogs = Sqflite.firstIntValue(
            await _database!.rawQuery('SELECT COUNT(*) FROM $_logsTable'),
          ) ??
          0;

      final logsByLevel = <String, int>{};
      for (final level in LogLevel.values) {
        final count = Sqflite.firstIntValue(
              await _database!.rawQuery(
                'SELECT COUNT(*) FROM $_logsTable WHERE level = ?',
                [level.toString().split('.').last],
              ),
            ) ??
            0;
        logsByLevel[level.toString().split('.').last] = count;
      }

      final recentErrors = Sqflite.firstIntValue(
            await _database!.rawQuery('''
          SELECT COUNT(*) FROM $_logsTable
          WHERE level IN ('error', 'critical')
          AND timestamp >= ?
        ''', [
              DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .toIso8601String()
            ]),
          ) ??
          0;

      return {
        'totalLogs': totalLogs,
        'logsByLevel': logsByLevel,
        'recentErrors': recentErrors,
        'storageSize': await _getDatabaseSize(),
      };
    } catch (e) {
      debugPrint('Error getting log stats: $e');
      return {
        'totalLogs': 0,
        'logsByLevel': {},
        'recentErrors': 0,
        'storageSize': 0,
      };
    }
  }

  /// Get database file size
  static Future<int> _getDatabaseSize() async {
    try {
      final dbPath = await getDatabasesPath();
      final file = File(join(dbPath, _dbName));
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Export logs to file
  static Future<String?> exportLogs({
    LogLevel? level,
    String? tag,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await getLogs(
        level: level,
        tag: tag,
        startDate: startDate,
        endDate: endDate,
        limit: 10000, // Large limit for export
      );

      final directory = await getApplicationDocumentsDirectory();
      final exportFile = File(
          '${directory.path}/logs_export_${DateTime.now().millisecondsSinceEpoch}.json');

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalLogs': logs.length,
        'logs': logs.map((log) => log.toJson()).toList(),
      };

      await exportFile.writeAsString(jsonEncode(exportData));
      return exportFile.path;
    } catch (e) {
      debugPrint('Error exporting logs: $e');
      return null;
    }
  }

  /// Clear all logs
  static Future<void> clearLogs() async {
    if (_database == null) return;

    try {
      await _database!.delete(_logsTable);
      log(LogLevel.info, 'All logs cleared', tag: 'LoggingService');
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
  }

  /// Convenience methods for different log levels
  static void debug(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    log(LogLevel.debug, message, tag: tag, metadata: metadata);
  }

  static void info(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    log(LogLevel.info, message, tag: tag, metadata: metadata);
  }

  static void warning(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    log(LogLevel.warning, message, tag: tag, metadata: metadata);
  }

  static void error(String message,
      {String? tag, Map<String, dynamic>? metadata, String? stackTrace}) {
    log(LogLevel.error, message,
        tag: tag, metadata: metadata, stackTrace: stackTrace);
  }

  static void critical(String message,
      {String? tag, Map<String, dynamic>? metadata, String? stackTrace}) {
    log(LogLevel.critical, message,
        tag: tag, metadata: metadata, stackTrace: stackTrace);
  }

  /// Log performance metrics
  static void logPerformance(String operation, Duration duration,
      {Map<String, dynamic>? metadata}) {
    final perfMetadata = {
      'operation': operation,
      'durationMs': duration.inMilliseconds,
      'durationReadable': '${duration.inMilliseconds}ms',
      ...?metadata,
    };

    log(LogLevel.info,
        'Performance: $operation took ${duration.inMilliseconds}ms',
        tag: 'Performance', metadata: perfMetadata);
  }

  /// Log user actions
  static void logUserAction(String action, {Map<String, dynamic>? metadata}) {
    log(LogLevel.info, 'User action: $action',
        tag: 'UserAction', metadata: metadata);
  }

  /// Log errors with context
  static void logError(Object error, StackTrace stackTrace,
      {String? tag, Map<String, dynamic>? metadata}) {
    log(LogLevel.error, error.toString(),
        tag: tag ?? 'Error',
        metadata: metadata,
        stackTrace: stackTrace.toString());
  }

  /// Dispose resources
  static Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

/// Singleton instance
final loggingService = LoggingService();
