import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import 'package:salon_app/services/connectivity_service.dart';
import 'package:salon_app/services/booking_service.dart';

/// Service for managing offline data storage and synchronization
class OfflineService {
  static final Logger _logger = Logger();
  static Database? _database;
  static const String _dbName = 'salon_app_offline.db';

  // Table names
  static const String _pendingBookingsTable = 'pending_bookings';
  static const String _cachedServicesTable = 'cached_services';
  static const String _cachedWorkersTable = 'cached_workers';
  static const String _syncMetadataTable = 'sync_metadata';

  // Sync states
  static const String _syncStatePending = 'pending';
  static const String _syncStateSynced = 'synced';
  static const String _syncStateFailed = 'failed';

  /// Initialize the offline service
  static Future<void> initialize() async {
    try {
      _database = await _initDatabase();
      await _createTables();
      _logger.i('Offline service initialized successfully');

      // Listen for connectivity changes to trigger sync
      ConnectivityService.onConnectionStatusChanged.listen((isOnline) {
        if (isOnline) {
          _syncPendingData();
        }
      });
    } catch (e) {
      _logger.e('Error initializing offline service: $e');
    }
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  /// Create database tables
  static Future<void> _createTables([Database? db]) async {
    final database = db ?? _database;
    if (database == null) return;

    // Pending bookings table
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_pendingBookingsTable (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        sync_state TEXT NOT NULL DEFAULT '$_syncStatePending',
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Cached services table
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_cachedServicesTable (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');

    // Cached workers table
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_cachedWorkersTable (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');

    // Sync metadata table
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_syncMetadataTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        last_updated INTEGER NOT NULL
      )
    ''');
  }

  /// Save booking for offline processing
  static Future<bool> saveBookingOffline(
      Map<String, dynamic> bookingData) async {
    if (_database == null) return false;

    try {
      final bookingId =
          bookingData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

      await _database!.insert(
        _pendingBookingsTable,
        {
          'id': bookingId,
          'data': jsonEncode(bookingData),
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'sync_state': _syncStatePending,
          'retry_count': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.i('Booking saved offline: $bookingId');
      return true;
    } catch (e) {
      _logger.e('Error saving booking offline: $e');
      return false;
    }
  }

  /// Get all pending bookings
  static Future<List<Map<String, dynamic>>> getPendingBookings() async {
    if (_database == null) return [];

    try {
      final results = await _database!.query(
        _pendingBookingsTable,
        where: 'sync_state = ?',
        whereArgs: [_syncStatePending],
        orderBy: 'created_at ASC',
      );

      return results.map((row) {
        final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        return {
          ...data,
          'offline_id': row['id'],
          'created_at':
              DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
          'retry_count': row['retry_count'] ?? 0,
        };
      }).toList();
    } catch (e) {
      _logger.e('Error getting pending bookings: $e');
      return [];
    }
  }

  /// Sync pending data with server
  static Future<void> _syncPendingData() async {
    if (_database == null || !ConnectivityService.isOnline) return;

    try {
      final pendingBookings = await getPendingBookings();
      _logger.i('Starting sync of ${pendingBookings.length} pending bookings');

      for (final booking in pendingBookings) {
        await _syncBooking(booking);
      }

      // Clean up old synced data
      await _cleanupSyncedData();
    } catch (e) {
      _logger.e('Error syncing pending data: $e');
    }
  }

  /// Sync individual booking
  static Future<void> _syncBooking(Map<String, dynamic> booking) async {
    if (_database == null) return;

    final offlineId = booking['offline_id'];
    final retryCount = booking['retry_count'] ?? 0;

    try {
      // Remove offline-specific fields before sending to server
      final serverData = Map<String, dynamic>.from(booking)
        ..remove('offline_id')
        ..remove('created_at')
        ..remove('retry_count');

      // Attempt to create booking on server
      final success = await bookingService.createBooking(
        serviceId: serverData['serviceId'],
        serviceName: serverData['serviceName'],
        workerId: serverData['workerId'],
        workerName: serverData['workerName'],
        dateTime: DateTime.parse(serverData['dateTime']),
        customerName: serverData['customerName'],
        customerPhone: serverData['customerPhone'],
        customerEmail: serverData['customerEmail'],
        notes: serverData['notes'],
      );

      if (success) {
        // Mark as synced
        await _database!.update(
          _pendingBookingsTable,
          {'sync_state': _syncStateSynced},
          where: 'id = ?',
          whereArgs: [offlineId],
        );
        _logger.i('Booking synced successfully: $offlineId');
      } else {
        await _markBookingFailed(
            offlineId, 'Server rejected booking', retryCount);
      }
    } catch (e) {
      await _markBookingFailed(offlineId, e.toString(), retryCount);
    }
  }

  /// Mark booking as failed
  static Future<void> _markBookingFailed(
      String offlineId, String error, int retryCount) async {
    if (_database == null) return;

    await _database!.update(
      _pendingBookingsTable,
      {
        'sync_state': _syncStateFailed,
        'last_error': error,
        'retry_count': retryCount + 1,
      },
      where: 'id = ?',
      whereArgs: [offlineId],
    );

    _logger.w('Booking sync failed: $offlineId - $error');
  }

  /// Cache services data for offline use
  static Future<void> cacheServices(List<Map<String, dynamic>> services) async {
    if (_database == null) return;

    try {
      final batch = _database!.batch();

      for (final service in services) {
        batch.insert(
          _cachedServicesTable,
          {
            'id': service['id'] ?? service['name'],
            'data': jsonEncode(service),
            'last_updated': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
      _logger.i('Services cached: ${services.length} items');
    } catch (e) {
      _logger.e('Error caching services: $e');
    }
  }

  /// Get cached services
  static Future<List<Map<String, dynamic>>> getCachedServices() async {
    if (_database == null) return [];

    try {
      final results = await _database!.query(
        _cachedServicesTable,
        orderBy: 'last_updated DESC',
      );

      return results
          .map((row) =>
              jsonDecode(row['data'] as String) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _logger.e('Error getting cached services: $e');
      return [];
    }
  }

  /// Cache workers data for offline use
  static Future<void> cacheWorkers(List<Map<String, dynamic>> workers) async {
    if (_database == null) return;

    try {
      final batch = _database!.batch();

      for (final worker in workers) {
        batch.insert(
          _cachedWorkersTable,
          {
            'id': worker['id'] ?? worker['name'],
            'data': jsonEncode(worker),
            'last_updated': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
      _logger.i('Workers cached: ${workers.length} items');
    } catch (e) {
      _logger.e('Error caching workers: $e');
    }
  }

  /// Get cached workers
  static Future<List<Map<String, dynamic>>> getCachedWorkers() async {
    if (_database == null) return [];

    try {
      final results = await _database!.query(
        _cachedWorkersTable,
        orderBy: 'last_updated DESC',
      );

      return results
          .map((row) =>
              jsonDecode(row['data'] as String) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _logger.e('Error getting cached workers: $e');
      return [];
    }
  }

  /// Clean up old synced data
  static Future<void> _cleanupSyncedData() async {
    if (_database == null) return;

    try {
      // Remove synced bookings older than 7 days
      final sevenDaysAgo = DateTime.now()
          .subtract(const Duration(days: 7))
          .millisecondsSinceEpoch;

      await _database!.delete(
        _pendingBookingsTable,
        where: 'sync_state = ? AND created_at < ?',
        whereArgs: [_syncStateSynced, sevenDaysAgo],
      );

      // Remove failed bookings older than 30 days
      final thirtyDaysAgo = DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch;

      await _database!.delete(
        _pendingBookingsTable,
        where: 'sync_state = ? AND created_at < ?',
        whereArgs: [_syncStateFailed, thirtyDaysAgo],
      );

      _logger.i('Old synced data cleaned up');
    } catch (e) {
      _logger.e('Error cleaning up synced data: $e');
    }
  }

  /// Get offline storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    if (_database == null) {
      return {
        'totalItems': 0,
        'pendingSync': 0,
        'cachedServices': 0,
        'cachedWorkers': 0
      };
    }

    try {
      final pendingCount = Sqflite.firstIntValue(
            await _database!.rawQuery(
                'SELECT COUNT(*) FROM $_pendingBookingsTable WHERE sync_state = ?',
                [_syncStatePending]),
          ) ??
          0;

      final servicesCount = Sqflite.firstIntValue(
            await _database!
                .rawQuery('SELECT COUNT(*) FROM $_cachedServicesTable'),
          ) ??
          0;

      final workersCount = Sqflite.firstIntValue(
            await _database!
                .rawQuery('SELECT COUNT(*) FROM $_cachedWorkersTable'),
          ) ??
          0;

      final totalItems = Sqflite.firstIntValue(
            await _database!
                .rawQuery('SELECT COUNT(*) FROM $_pendingBookingsTable'),
          ) ??
          0;

      return {
        'totalItems': totalItems,
        'pendingSync': pendingCount,
        'cachedServices': servicesCount,
        'cachedWorkers': workersCount,
      };
    } catch (e) {
      _logger.e('Error getting storage stats: $e');
      return {
        'totalItems': 0,
        'pendingSync': 0,
        'cachedServices': 0,
        'cachedWorkers': 0
      };
    }
  }

  /// Clear all offline data
  static Future<void> clearAllData() async {
    if (_database == null) return;

    try {
      await _database!.delete(_pendingBookingsTable);
      await _database!.delete(_cachedServicesTable);
      await _database!.delete(_cachedWorkersTable);
      await _database!.delete(_syncMetadataTable);

      _logger.i('All offline data cleared');
    } catch (e) {
      _logger.e('Error clearing offline data: $e');
    }
  }

  /// Check if operation should be performed offline
  static bool shouldUseOfflineMode() {
    return !ConnectivityService.isOnline;
  }

  /// Get sync status
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final stats = await getStorageStats();
    final isOnline = ConnectivityService.isOnline;

    return {
      'isOnline': isOnline,
      'pendingSync': stats['pendingSync'],
      'lastSyncAttempt': await _getLastSyncTime(),
      'syncInProgress': false, // Could be enhanced with actual sync state
    };
  }

  /// Get last sync time
  static Future<DateTime?> _getLastSyncTime() async {
    if (_database == null) return null;

    try {
      final result = await _database!.query(
        _syncMetadataTable,
        where: 'key = ?',
        whereArgs: ['last_sync_time'],
      );

      if (result.isNotEmpty) {
        final timestamp = int.tryParse(result.first['value'] as String);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
    } catch (e) {
      _logger.e('Error getting last sync time: $e');
    }

    return null;
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
final offlineService = OfflineService();
