import 'package:flutter_test/flutter_test.dart';
import 'package:salon_app/services/cache_service.dart';

void main() {
  setUp(() {
    // Clear cache before each test
    CacheService.clear();
  });

  group('CacheService', () {
    test('should store and retrieve data from cache', () async {
      // Arrange
      const testKey = 'test_key';
      const testData = {'name': 'John', 'age': 30};

      // Act
      final result = await CacheService.get(
        testKey,
        fetcher: () async => testData,
      );

      // Assert
      expect(result, equals(testData));
    });

    test('should return cached data on subsequent calls', () async {
      // Arrange
      const testKey = 'test_key';
      const testData = {'name': 'John', 'age': 30};
      int fetchCount = 0;

      // Act - First call
      final result1 = await CacheService.get(
        testKey,
        fetcher: () async {
          fetchCount++;
          return testData;
        },
      );

      // Act - Second call (should use cache)
      final result2 = await CacheService.get(
        testKey,
        fetcher: () async {
          fetchCount++;
          return testData;
        },
      );

      // Assert
      expect(result1, equals(testData));
      expect(result2, equals(testData));
      expect(fetchCount, equals(1)); // Should only fetch once
    });

    test('should handle null fetcher result', () async {
      // Arrange
      const testKey = 'test_key';

      // Act
      final result = await CacheService.get(
        testKey,
        fetcher: () async => null,
      );

      // Assert
      expect(result, isNull);
    });

    test('should handle fetcher errors', () async {
      // Arrange
      const testKey = 'test_key';

      // Act
      final result = await CacheService.get(
        testKey,
        fetcher: () async => throw Exception('Network error'),
      );

      // Assert
      expect(result, isNull);
    });

    test('should create pagination info correctly', () {
      // Test normal pagination
      final pagination = CacheService.createPaginationInfo(100, 2, 20);

      expect(pagination.currentPage, equals(2));
      expect(pagination.totalPages, equals(5));
      expect(pagination.totalItems, equals(100));
      expect(pagination.itemsPerPage, equals(20));
      expect(pagination.hasNextPage, isTrue);
      expect(pagination.hasPreviousPage, isTrue);
    });

    test('should create pagination for first page', () {
      final pagination = CacheService.createPaginationInfo(100, 1, 20);

      expect(pagination.hasNextPage, isTrue);
      expect(pagination.hasPreviousPage, isFalse);
    });

    test('should create pagination for last page', () {
      final pagination = CacheService.createPaginationInfo(100, 5, 20);

      expect(pagination.hasNextPage, isFalse);
      expect(pagination.hasPreviousPage, isTrue);
    });

    test('should paginate list correctly', () {
      // Arrange
      final items = List.generate(100, (index) => 'Item ${index + 1}');

      // Act
      final paginated = CacheService.paginateList(items, 2, 20);

      // Assert
      expect(paginated.items.length, equals(20));
      expect(paginated.items.first, equals('Item 21'));
      expect(paginated.items.last, equals('Item 40'));
      expect(paginated.pagination.currentPage, equals(2));
      expect(paginated.pagination.totalPages, equals(5));
    });

    test('should handle empty list pagination', () {
      // Arrange
      final items = <String>[];

      // Act
      final paginated = CacheService.paginateList(items, 1, 20);

      // Assert
      expect(paginated.items.length, equals(0));
      expect(paginated.pagination.totalItems, equals(0));
      expect(paginated.pagination.totalPages, equals(1));
    });

    test('should handle pagination beyond available items', () {
      // Arrange
      final items = List.generate(25, (index) => 'Item ${index + 1}');

      // Act
      final paginated = CacheService.paginateList(items, 3, 20);

      // Assert
      expect(paginated.items.length, equals(5)); // Only 5 items left
      expect(paginated.items.first, equals('Item 41'));
      expect(paginated.items.last, equals('Item 45'));
    });

    test('should invalidate cache entries', () async {
      // Arrange
      const testKey = 'test_key';
      const testData = {'name': 'John'};

      // Act - Store data
      await CacheService.get(
        testKey,
        fetcher: () async => testData,
      );

      // Verify it's cached
      final cached = await CacheService.get(
        testKey,
        fetcher: () async => {'name': 'different'},
      );
      expect(cached, equals(testData));

      // Act - Invalidate
      CacheService.invalidate(testKey);

      // Assert - Should fetch new data after invalidation
      final invalidated = await CacheService.get(
        testKey,
        fetcher: () async => {'name': 'new'},
      );
      expect(invalidated, equals({'name': 'new'}));
    });

    test('should clear all cache', () async {
      // Arrange
      const testKey1 = 'test_key_1';
      const testKey2 = 'test_key_2';
      const testData1 = {'name': 'John'};
      const testData2 = {'name': 'Jane'};

      // Act - Store data
      await CacheService.get(testKey1, fetcher: () async => testData1);
      await CacheService.get(testKey2, fetcher: () async => testData2);

      // Verify both are cached
      final cached1 =
          await CacheService.get(testKey1, fetcher: () async => testData1);
      final cached2 =
          await CacheService.get(testKey2, fetcher: () async => testData2);
      expect(cached1, equals(testData1));
      expect(cached2, equals(testData2));

      // Act - Clear all
      CacheService.clear();

      // Assert - Both should fetch new data after clear
      final afterClear1 = await CacheService.get(testKey1,
          fetcher: () async => {'name': 'new1'});
      final afterClear2 = await CacheService.get(testKey2,
          fetcher: () async => {'name': 'new2'});
      expect(afterClear1, equals({'name': 'new1'}));
      expect(afterClear2, equals({'name': 'new2'}));
    });

    test('should validate coordinates correctly', () {
      // Valid coordinates
      expect(CacheService.areValidCoordinates(37.7749, -122.4194), isTrue);
      expect(CacheService.areValidCoordinates(0, 0), isTrue);
      expect(CacheService.areValidCoordinates(-90, -180), isTrue);
      expect(CacheService.areValidCoordinates(90, 180), isTrue);

      // Invalid coordinates
      expect(CacheService.areValidCoordinates(91, 0), isFalse);
      expect(CacheService.areValidCoordinates(-91, 0), isFalse);
      expect(CacheService.areValidCoordinates(0, 181), isFalse);
      expect(CacheService.areValidCoordinates(0, -181), isFalse);
    });

    test('should get cache statistics', () async {
      // Arrange
      const testKey = 'test_key';
      const testData = {'name': 'John'};

      // Act - Store data
      await CacheService.get(testKey, fetcher: () async => testData);

      // Act - Get stats
      final stats = CacheService.getStats();

      // Assert
      expect(stats['totalEntries'], equals(1));
      expect(stats['validEntries'], equals(1));
      expect(stats['expiredEntries'], equals(0));
      expect(stats['cacheHits'], greaterThanOrEqualTo(0));
      expect(stats['cacheMisses'], greaterThanOrEqualTo(0));
    });
  });
}
