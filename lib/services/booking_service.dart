import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Service for managing booking operations with Firestore
///
/// This service handles all booking-related operations including:
/// - Creating new bookings with validation
/// - Checking slot availability
/// - Managing booking status (confirmed, completed, cancelled)
/// - Retrieving user bookings
/// - Validating booking data
///
/// Features:
/// - Real-time booking creation with Firestore
/// - Automatic slot availability checking
/// - Comprehensive data validation
/// - Error handling and logging
/// - Support for booking metadata (notes, customer info)
///
/// Usage:
/// ```dart
/// // Create a booking
/// final success = await bookingService.createBooking(
///   serviceId: 'service123',
///   serviceName: 'Hair Cut',
///   workerId: 'worker456',
///   workerName: 'John Doe',
///   dateTime: DateTime.now().add(Duration(days: 1)),
///   customerName: 'Jane Smith',
///   customerPhone: '+1234567890',
/// );
///
/// // Check slot availability
/// final isAvailable = await bookingService.isSlotAvailable(
///   'worker456',
///   DateTime.now().add(Duration(days: 1)),
/// );
/// ```
class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Create a new booking
  Future<bool> createBooking({
    required String serviceId,
    required String serviceName,
    required String workerId,
    required String workerName,
    required DateTime dateTime,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? notes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final bookingData = {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'workerId': workerId,
        'workerName': workerName,
        'dateTime': Timestamp.fromDate(dateTime),
        'customerId': user.uid,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerEmail': customerEmail,
        'notes': notes,
        'status': 'confirmed', // confirmed, completed, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('bookings').add(bookingData);
      _logger.i('Reserva creada exitosamente: $serviceName para $customerName');
      return true;
    } catch (e) {
      _logger.e('Error creando reserva: $e');
      return false;
    }
  }

  /// Get bookings for current user
  Stream<QuerySnapshot> getUserBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: false)
        .snapshots();
  }

  /// Get all bookings (for admin/staff)
  Stream<QuerySnapshot> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('dateTime', descending: false)
        .snapshots();
  }

  /// Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Estado de reserva actualizado: $bookingId -> $status');
      return true;
    } catch (e) {
      _logger.e('Error actualizando estado de reserva: $e');
      return false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    return updateBookingStatus(bookingId, 'cancelled');
  }

  /// Check if slot is available
  Future<bool> isSlotAvailable(String workerId, DateTime dateTime) async {
    try {
      final startTime = dateTime;
      final endTime =
          dateTime.add(const Duration(hours: 1)); // Assuming 1 hour slots

      final query = await _firestore
          .collection('bookings')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'confirmed')
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('dateTime', isLessThan: Timestamp.fromDate(endTime))
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      _logger.e('Error verificando disponibilidad: $e');
      return false;
    }
  }

  /// Get available time slots for a worker on a specific date
  Future<List<DateTime>> getAvailableSlots(
      String workerId, DateTime date) async {
    try {
      final slots = <DateTime>[];
      final now = DateTime.now();

      // Generate slots from 9 AM to 6 PM
      for (int hour = 9; hour < 18; hour++) {
        final slotTime = DateTime(date.year, date.month, date.day, hour, 0);
        if (slotTime.isAfter(now) &&
            await isSlotAvailable(workerId, slotTime)) {
          slots.add(slotTime);
        }
      }

      return slots;
    } catch (e) {
      _logger.e('Error obteniendo slots disponibles: $e');
      return [];
    }
  }

  /// Validate booking data
  String? validateBookingData({
    required String serviceId,
    required String workerId,
    required DateTime dateTime,
    required String customerName,
    required String customerPhone,
  }) {
    if (serviceId.isEmpty) return 'Servicio requerido';
    if (workerId.isEmpty) return 'Trabajador requerido';
    if (dateTime.isBefore(DateTime.now())) return 'Fecha debe ser futura';
    if (customerName.trim().isEmpty) return 'Nombre requerido';
    if (customerPhone.trim().isEmpty) return 'Teléfono requerido';
    if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(customerPhone)) {
      return 'Formato de teléfono inválido';
    }
    return null; // Valid
  }
}

/// Singleton instance
final bookingService = BookingService();
