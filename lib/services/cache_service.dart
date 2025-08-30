import 'dart:async';
import 'package:salon_app/services/logging_service.dart';

/// Cache entry with metadata
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;
  final String key;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    required this.key,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  bool get isValid => !isExpired;
}

/// Pagination metadata
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.empty() {
    return PaginationInfo(
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      itemsPerPage: 20,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }
}

/// Paginated data container
class PaginatedData<T> {
  final List<T> items;
  final PaginationInfo pagination;

  PaginatedData({
    required this.items,
    required this.pagination,
  });
}

/// Advanced caching service with pagination support
class CacheService {
  static final Map<String, CacheEntry> _memoryCache = {};
  static final Map<String, Completer> _pendingRequests = {};
  static const Duration _defaultTTL = Duration(minutes: 5);
  static const int _maxCacheSize = 100;

  // Cache statistics
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _evictions = 0;

  /// Get data from cache or fetch from source
  static Future<T?> get<T>(
    String key, {
    Future<T?> Function()? fetcher,
    Duration ttl = _defaultTTL,
    bool useMemoryCache = true,
  }) async {
    if (useMemoryCache) {
      final cached = _getFromMemoryCache<T>(key);
      if (cached != null) {
        _cacheHits++;
        LoggingService.debug('Cache hit for key: $key', tag: 'CacheService');
        return cached;
      }
    }

    _cacheMisses++;

    // Prevent duplicate requests
    if (_pendingRequests.containsKey(key)) {
      LoggingService.debug('Waiting for pending request: $key',
          tag: 'CacheService');
      return await _pendingRequests[key]!.future as T?;
    }

    if (fetcher == null) {
      LoggingService.debug('No fetcher provided for key: $key',
          tag: 'CacheService');
      return null;
    }

    final completer = Completer<T?>();
    _pendingRequests[key] = completer;

    try {
      final data = await fetcher();
      if (data != null && useMemoryCache) {
        _setInMemoryCache(key, data, ttl);
      }
      completer.complete(data);
      return data;
    } catch (e) {
      LoggingService.error('Error fetching data for key: $key',
          tag: 'CacheService', metadata: {'error': e.toString()});
      completer.complete(null);
      return null;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  /// Get paginated data with caching
  static Future<PaginatedData<T>?> getPaginated<T>(
    String baseKey,
    int page,
    int pageSize, {
    required Future<PaginatedData<T>?> Function(int, int) fetcher,
    Duration ttl = _defaultTTL,
    bool useMemoryCache = true,
  }) async {
    final key = '${baseKey}_page_$page';

    return get<PaginatedData<T>>(
      key,
      fetcher: () => fetcher(page, pageSize),
      ttl: ttl,
      useMemoryCache: useMemoryCache,
    );
  }

  /// Set data in memory cache
  static void _setInMemoryCache<T>(String key, T data, Duration ttl) {
    // Evict old entries if cache is full
    if (_memoryCache.length >= _maxCacheSize) {
      _evictOldEntries();
    }

    _memoryCache[key] = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
      key: key,
    );

    LoggingService.debug('Cached data for key: $key', tag: 'CacheService');
  }

  /// Get data from memory cache
  static T? _getFromMemoryCache<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) {
      LoggingService.debug('Cache miss for key: $key', tag: 'CacheService');
      return null;
    }

    if (entry.isExpired) {
      _memoryCache.remove(key);
      _evictions++;
      LoggingService.debug('Expired cache entry removed: $key',
          tag: 'CacheService');
      return null;
    }

    // DIAGNÓSTICO: Agregar logs para debugging de tipos
    LoggingService.debug(
        'Cache hit for key: $key, data type: ${entry.data.runtimeType}, expected type: $T',
        tag: 'CacheService');

    // CORRECCIÓN: Verificar si los datos son null antes de castear
    if (entry.data == null) {
      return null;
    }

    try {
      return entry.data as T?;
    } catch (e) {
      LoggingService.error(
          'Type cast error for key: $key, data: ${entry.data}, expected: $T, error: $e',
          tag: 'CacheService');
      return null;
    }
  }

  /// Evict old entries using LRU strategy
  static void _evictOldEntries() {
    if (_memoryCache.isEmpty) return;

    // Sort by timestamp (oldest first)
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

    // Remove oldest 20% of entries
    final entriesToRemove = (sortedEntries.length * 0.2).ceil();
    for (var i = 0; i < entriesToRemove && i < sortedEntries.length; i++) {
      _memoryCache.remove(sortedEntries[i].key);
      _evictions++;
    }

    LoggingService.debug('Evicted $entriesToRemove old cache entries',
        tag: 'CacheService');
  }

  /// Invalidate cache entry
  static void invalidate(String key) {
    _memoryCache.remove(key);
    LoggingService.debug('Invalidated cache for key: $key',
        tag: 'CacheService');
  }

  /// Invalidate all cache entries matching pattern
  static void invalidatePattern(String pattern) {
    final keysToRemove =
        _memoryCache.keys.where((key) => key.contains(pattern)).toList();
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
    }
    LoggingService.debug(
        'Invalidated ${keysToRemove.length} cache entries matching: $pattern',
        tag: 'CacheService');
  }

  /// Clear all cache
  static void clear() {
    _memoryCache.clear();
    _pendingRequests.clear();
    LoggingService.info('Cache cleared', tag: 'CacheService');
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    final totalEntries = _memoryCache.length;
    final expiredEntries =
        _memoryCache.values.where((entry) => entry.isExpired).length;
    final hitRate = _cacheHits + _cacheMisses > 0
        ? (_cacheHits / (_cacheHits + _cacheMisses) * 100).round()
        : 0;

    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'validEntries': totalEntries - expiredEntries,
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': hitRate,
      'evictions': _evictions,
      'pendingRequests': _pendingRequests.length,
    };
  }

  /// Preload data into cache
  static Future<void> preload<T>(
    String key,
    Future<T?> Function() fetcher, {
    Duration ttl = _defaultTTL,
  }) async {
    try {
      final data = await fetcher();
      if (data != null) {
        _setInMemoryCache(key, data, ttl);
        LoggingService.debug('Preloaded data for key: $key',
            tag: 'CacheService');
      }
    } catch (e) {
      LoggingService.error('Error preloading data for key: $key',
          tag: 'CacheService', metadata: {'error': e.toString()});
    }
  }

  /// Warm up cache with frequently used data
  static Future<void> warmUpCache() async {
    LoggingService.info('Starting cache warm-up', tag: 'CacheService');

    // Preload common data that users frequently access
    // This would be customized based on your app's usage patterns

    LoggingService.info('Cache warm-up completed', tag: 'CacheService');
  }

  /// Create pagination info from total count
  static PaginationInfo createPaginationInfo(
    int totalItems,
    int currentPage,
    int itemsPerPage,
  ) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    final hasNextPage = currentPage < totalPages;
    final hasPreviousPage = currentPage > 1;

    return PaginationInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  /// Get paginated data from list
  static PaginatedData<T> paginateList<T>(
    List<T> allItems,
    int page,
    int pageSize,
  ) {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    final items = startIndex < allItems.length
        ? allItems.sublist(startIndex, endIndex.clamp(0, allItems.length))
        : <T>[];

    final pagination = createPaginationInfo(allItems.length, page, pageSize);

    return PaginatedData<T>(
      items: items,
      pagination: pagination,
    );
  }

  /// Stream cache updates
  static Stream<Map<String, dynamic>> get cacheStatsStream {
    return Stream.periodic(const Duration(seconds: 30), (_) => getStats());
  }

  /// Enable/disable cache debugging
  static bool _debugMode = false;

  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
    LoggingService.info('Cache debug mode ${enabled ? 'enabled' : 'disabled'}',
        tag: 'CacheService');
  }

  /// Get cache debug info
  static Map<String, dynamic> getDebugInfo() {
    if (!_debugMode) return {};

    final entries = _memoryCache.entries.map((entry) {
      return {
        'key': entry.key,
        'timestamp': entry.value.timestamp.toIso8601String(),
        'ttl': entry.value.ttl.inSeconds,
        'isExpired': entry.value.isExpired,
        'dataType': entry.value.data.runtimeType.toString(),
      };
    }).toList();

    return {
      'entries': entries,
      'pendingRequests': _pendingRequests.keys.toList(),
      'stats': getStats(),
    };
  }

  /// Validate coordinates
  static bool areValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}

/// Singleton instance
final cacheService = CacheService();
