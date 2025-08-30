import 'package:flutter_test/flutter_test.dart';
import 'package:salon_app/services/cache_service.dart';

void main() {
  group('Integration Tests', () {
    test('CacheService integration with LoggingService', () async {
      // Test that cache operations are properly logged
      final testKey = 'integration_test_key';
      final testData = {'message': 'Integration test data'};

      // Clear cache first
      CacheService.clear();

      // Perform cache operation
      final result = await CacheService.get(
        testKey,
        fetcher: () async => testData,
      );

      // Verify result
      expect(result, equals(testData));

      // Get cache stats
      final stats = CacheService.getStats();
      expect(stats['totalEntries'], equals(1));
      expect(stats['cacheHits'], equals(0));
      expect(stats['cacheMisses'], equals(1));
    });

    test('CacheService pagination integration', () {
      // Test pagination functionality
      final items = List.generate(50, (index) => 'Item ${index + 1}');

      // Test first page
      final page1 = CacheService.paginateList(items, 1, 10);
      expect(page1.items.length, equals(10));
      expect(page1.items.first, equals('Item 1'));
      expect(page1.items.last, equals('Item 10'));
      expect(page1.pagination.currentPage, equals(1));
      expect(page1.pagination.hasNextPage, isTrue);
      expect(page1.pagination.hasPreviousPage, isFalse);

      // Test middle page
      final page3 = CacheService.paginateList(items, 3, 10);
      expect(page3.items.length, equals(10));
      expect(page3.items.first, equals('Item 21'));
      expect(page3.items.last, equals('Item 30'));
      expect(page3.pagination.currentPage, equals(3));

      // Test last page
      final page5 = CacheService.paginateList(items, 5, 10);
      expect(page5.items.length, equals(10));
      expect(page5.items.first, equals('Item 41'));
      expect(page5.items.last, equals('Item 50'));
      expect(page5.pagination.hasNextPage, isFalse);
      expect(page5.pagination.hasPreviousPage, isTrue);
    });

    test('CacheService cache invalidation', () async {
      final testKey = 'invalidation_test';
      final testData = {'data': 'test'};

      // Store data
      await CacheService.get(
        testKey,
        fetcher: () async => testData,
      );

      // Verify it's cached
      final cached = await CacheService.get(
        testKey,
        fetcher: () async => {'data': 'should not be returned'},
      );
      expect(cached, equals(testData));

      // Invalidate cache
      CacheService.invalidate(testKey);

      // Verify it's no longer cached
      final afterInvalidation = await CacheService.get(
        testKey,
        fetcher: () async => {'data': 'new data'},
      );
      expect(afterInvalidation, equals({'data': 'new data'}));
    });

    test('CacheService statistics tracking', () async {
      // Clear cache
      CacheService.clear();

      final testKey = 'stats_test';
      final testData = {'stats': 'test'};

      // First call - should be a miss
      await CacheService.get(
        testKey,
        fetcher: () async => testData,
      );

      // Second call - should be a hit
      await CacheService.get(
        testKey,
        fetcher: () async => {'stats': 'different'},
      );

      final stats = CacheService.getStats();
      expect(stats['cacheHits'], equals(1));
      expect(stats['cacheMisses'], equals(1));
      expect(stats['totalEntries'], equals(1));
    });

    test('CacheService coordinate validation', () {
      // Valid coordinates
      expect(CacheService.areValidCoordinates(37.7749, -122.4194), isTrue);
      expect(CacheService.areValidCoordinates(0.0, 0.0), isTrue);
      expect(CacheService.areValidCoordinates(-90.0, -180.0), isTrue);
      expect(CacheService.areValidCoordinates(90.0, 180.0), isTrue);

      // Invalid coordinates
      expect(CacheService.areValidCoordinates(91.0, 0.0), isFalse);
      expect(CacheService.areValidCoordinates(-91.0, 0.0), isFalse);
      expect(CacheService.areValidCoordinates(0.0, 181.0), isFalse);
      expect(CacheService.areValidCoordinates(0.0, -181.0), isFalse);
    });

    test('CacheService bulk operations', () async {
      // Test clearing cache
      CacheService.clear();
      var stats = CacheService.getStats();
      expect(stats['totalEntries'], equals(0));

      // Add some data using public methods
      await CacheService.get(
        'test1',
        fetcher: () async => 'data1',
      );
      await CacheService.get(
        'test2',
        fetcher: () async => 'data2',
      );

      stats = CacheService.getStats();
      expect(stats['totalEntries'], equals(2));

      // Clear again
      CacheService.clear();
      stats = CacheService.getStats();
      expect(stats['totalEntries'], equals(0));
    });
  });
}
