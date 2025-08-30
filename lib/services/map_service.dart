import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

/// Service for managing map operations and location data
///
/// This service provides comprehensive map functionality including:
/// - Dynamic location loading from Firestore
/// - Custom marker creation and management
/// - Distance calculations between coordinates
/// - Nearby services discovery
/// - Location validation and error handling
///
/// Key Features:
/// - Real-time location updates from Firestore
/// - Custom markers with business information
/// - Haversine distance calculations
/// - Location-based service discovery
/// - Fallback mechanisms for missing data
///
/// Usage:
/// ```dart
/// // Get salon location
/// final salonLocation = await mapService.getSalonLocation();
///
/// // Calculate distance
/// final distance = mapService.calculateDistance(point1, point2);
///
/// // Find nearby services
/// final nearbyServices = await mapService.getNearbyServices(
///   userLocation,
///   10.0 // 10km radius
/// );
///
/// // Create map markers
/// final markers = await mapService.createCustomMarkers(context);
/// ```
class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Get salon location from Firestore
  Future<LatLng?> getSalonLocation() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('salon_location').get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          return LatLng(data['latitude'], data['longitude']);
        }
      }
      // Fallback to default location
      _logger
          .w('Ubicación del salón no encontrada, usando ubicación por defecto');
      return const LatLng(37.42796133580664, -122.085749655962);
    } catch (e) {
      _logger.e('Error obteniendo ubicación del salón: $e');
      return const LatLng(37.42796133580664, -122.085749655962);
    }
  }

  /// Update salon location in Firestore
  Future<bool> updateSalonLocation(LatLng location) async {
    try {
      await _firestore.collection('settings').doc('salon_location').set({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Ubicación del salón actualizada: $location');
      return true;
    } catch (e) {
      _logger.e('Error actualizando ubicación del salón: $e');
      return false;
    }
  }

  /// Get all workers locations
  Stream<QuerySnapshot> getWorkersLocations() {
    return _firestore
        .collection('workers')
        .where('location', isNull: false)
        .snapshots();
  }

  /// Update worker location
  Future<bool> updateWorkerLocation(String workerId, LatLng location) async {
    try {
      await _firestore.collection('workers').doc(workerId).update({
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Ubicación del trabajador actualizada: $workerId');
      return true;
    } catch (e) {
      _logger.e('Error actualizando ubicación del trabajador: $e');
      return false;
    }
  }

  /// Get salon information including address
  Future<Map<String, dynamic>?> getSalonInfo() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('salon_info').get();
      if (doc.exists) {
        return doc.data();
      }
      return {
        'name': 'Salón de Belleza',
        'address': 'Dirección no especificada',
        'phone': '+1 (555) 123-4567',
        'email': 'info@salonbelleza.com',
        'hours':
            'Lunes - Viernes: 9:00 AM - 8:00 PM\nSábados: 8:00 AM - 6:00 PM\nDomingos: Cerrado',
      };
    } catch (e) {
      _logger.e('Error obteniendo información del salón: $e');
      return null;
    }
  }

  /// Calculate distance between two points (in kilometers)
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = point1.latitude * (3.141592653589793 / 180);
    final double lat2Rad = point2.latitude * (3.141592653589793 / 180);
    final double deltaLatRad =
        (point2.latitude - point1.latitude) * (3.141592653589793 / 180);
    final double deltaLngRad =
        (point2.longitude - point1.longitude) * (3.141592653589793 / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Get nearby services/workers within radius
  Future<List<Map<String, dynamic>>> getNearbyServices(
      LatLng userLocation, double radiusKm) async {
    try {
      final services = <Map<String, dynamic>>[];

      // Get all workers with locations
      final workersSnapshot = await _firestore
          .collection('workers')
          .where('location', isNull: false)
          .get();

      for (final doc in workersSnapshot.docs) {
        final data = doc.data();
        final location = data['location'];
        if (location != null) {
          final workerLocation =
              LatLng(location['latitude'], location['longitude']);
          final distance = calculateDistance(userLocation, workerLocation);

          if (distance <= radiusKm) {
            services.add({
              ...data,
              'id': doc.id,
              'distance': distance,
              'location': workerLocation,
            });
          }
        }
      }

      // Sort by distance
      services.sort((a, b) => a['distance'].compareTo(b['distance']));
      return services;
    } catch (e) {
      _logger.e('Error obteniendo servicios cercanos: $e');
      return [];
    }
  }

  /// Create custom markers for map
  Future<Set<Marker>> createCustomMarkers(BuildContext context) async {
    final markers = <Marker>{};

    try {
      // Salon marker
      final salonLocation = await getSalonLocation();
      if (salonLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('salon'),
            position: salonLocation,
            infoWindow: const InfoWindow(
              title: 'Salón de Belleza',
              snippet: 'Tu destino de belleza',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        );
      }

      // Workers markers
      final workersSnapshot = await _firestore.collection('workers').get();
      for (final doc in workersSnapshot.docs) {
        final data = doc.data();
        final location = data['location'];
        if (location != null) {
          final workerLocation =
              LatLng(location['latitude'], location['longitude']);
          markers.add(
            Marker(
              markerId: MarkerId('worker_${doc.id}'),
              position: workerLocation,
              infoWindow: InfoWindow(
                title: data['name'] ?? 'Trabajador',
                snippet: data['specialty'] ?? 'Especialista',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error creando marcadores: $e');
    }

    return markers;
  }

  /// Validate coordinates
  bool areValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}

/// Singleton instance
final mapService = MapService();
