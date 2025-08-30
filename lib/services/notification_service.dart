import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import 'package:salon_app/services/booking_service.dart';

/// Background message handler (debe ser top-level para Firebase)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Maneja mensajes en segundo plano aquí
  // Usa logging para evitar print en producción
  final logger = Logger();
  logger.i('Received background message: ${message.notification?.title}');
}

/// Service for managing push notifications and reminders
class NotificationService {
  static final Logger _logger = Logger();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channels
  static const String _bookingChannelId = 'booking_reminders';
  static const String _bookingChannelName = 'Recordatorios de Citas';
  static const String _bookingChannelDescription =
      'Notificaciones para recordatorios de citas';

  static const String _generalChannelId = 'general_notifications';
  static const String _generalChannelName = 'Notificaciones Generales';
  static const String _generalChannelDescription =
      'Notificaciones generales de la aplicación';

  // Preferences keys
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _reminderHoursKey = 'reminder_hours';
  static const String _fcmTokenKey = 'fcm_token';

  // Stream controllers
  static final StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();
  static final StreamController<RemoteMessage> _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();

  // Getters for streams
  static Stream<RemoteMessage> get onMessage => _onMessageController.stream;
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  /// Initialize the notification service
  static Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Configure Firebase messaging
      await _configureFirebaseMessaging();

      // Get and save FCM token
      await _saveFCMToken();

      _logger.i('Notification service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing notification service: $e');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel bookingChannel =
        AndroidNotificationChannel(
      _bookingChannelId,
      _bookingChannelName,
      description: _bookingChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
      _generalChannelId,
      _generalChannelName,
      description: _generalChannelDescription,
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(bookingChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  /// Request permissions for notifications
  static Future<void> _requestPermissions() async {
    // Request Firebase messaging permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _logger
        .i('Notification permission status: ${settings.authorizationStatus}');

    // Request local notification permissions for iOS
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Configure Firebase messaging handlers
  static Future<void> _configureFirebaseMessaging() async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Received foreground message: ${message.notification?.title}');
      _onMessageController.add(message);
      _showLocalNotification(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('App opened from notification: ${message.notification?.title}');
      _onMessageOpenedAppController.add(message);
    });

    // Handle messages when app is in background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Save FCM token to SharedPreferences and optionally to server
  static Future<void> _saveFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, token);
        _logger.i('FCM token saved: ${token.substring(0, 20)}...');

        // Send token to server for targeted notifications
        await _sendTokenToServer(token);
      }
    } catch (e) {
      _logger.e('Error saving FCM token: $e');
    }
  }

  /// Send FCM token to server for targeted notifications
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.w('No authenticated user, skipping token upload');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));

      _logger.i('FCM token sent to server for user: ${user.uid}');
    } catch (e) {
      _logger.e('Error sending FCM token to server: $e');
    }
  }

  /// Get stored FCM token
  static Future<String?> getFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  /// Show local notification from FCM message
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _generalChannelId,
        _generalChannelName,
        channelDescription: _generalChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        notification.title ?? 'Notificación',
        notification.body ?? '',
        details,
        payload: jsonEncode(data),
      );
    }
  }

  /// Schedule booking reminder notification
  static Future<void> scheduleBookingReminder({
    required String bookingId,
    required String serviceName,
    required String customerName,
    required DateTime bookingDateTime,
    int hoursBefore = 24,
  }) async {
    try {
      // Check if notifications are enabled
      if (!await areNotificationsEnabled()) {
        _logger.i(
            'Notifications disabled, skipping reminder for booking: $bookingId');
        return;
      }

      final reminderTime =
          bookingDateTime.subtract(Duration(hours: hoursBefore));

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) {
        _logger.w('Reminder time is in the past, skipping: $reminderTime');
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _bookingChannelId,
        _bookingChannelName,
        channelDescription: _bookingChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        bookingId.hashCode, // Unique ID based on booking ID
        'Recordatorio de Cita',
        'Tienes una cita programada: $serviceName con $customerName',
        tz.TZDateTime.from(reminderTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'type': 'booking_reminder',
          'bookingId': bookingId,
          'serviceName': serviceName,
          'customerName': customerName,
          'bookingDateTime': bookingDateTime.toIso8601String(),
        }),
      );

      _logger.i('Booking reminder scheduled for: $reminderTime');
    } catch (e) {
      _logger.e('Error scheduling booking reminder: $e');
    }
  }

  /// Cancel booking reminder notification
  static Future<void> cancelBookingReminder(String bookingId) async {
    try {
      await _localNotifications.cancel(bookingId.hashCode);
      _logger.i('Booking reminder cancelled for: $bookingId');
    } catch (e) {
      _logger.e('Error cancelling booking reminder: $e');
    }
  }

  /// Send immediate notification
  static Future<void> sendImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _generalChannelId,
        _generalChannelName,
        channelDescription: _generalChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );

      _logger.i('Immediate notification sent: $title');
    } catch (e) {
      _logger.e('Error sending immediate notification: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        final data = jsonDecode(payload);
        _logger.i('Notification tapped with payload: $data');

        // Handle different notification types
        final type = data['type'];
        switch (type) {
          case 'booking_reminder':
            // Navigate to booking details or home screen
            _handleBookingReminderTap(data);
            break;
          default:
            _logger.i('Unknown notification type: $type');
        }
      }
    } catch (e) {
      _logger.e('Error handling notification tap: $e');
    }
  }

  /// Handle booking reminder notification tap
  static void _handleBookingReminderTap(Map<String, dynamic> data) {
    final bookingId = data['bookingId'];
    _logger.i('Handling booking reminder tap for: $bookingId');

    // Navigate to booking details screen
    if (onNavigateToBooking != null) {
      onNavigateToBooking!(bookingId);
    } else {
      _logger.w('No navigation handler set for booking details');
    }
  }

  /// Callback for navigating to booking details screen
  static void Function(String bookingId)? onNavigateToBooking;

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      _logger.e('Error checking notification settings: $e');
      return true; // Default to enabled
    }
  }

  /// Enable/disable notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
      _logger.i('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error setting notification settings: $e');
    }
  }

  /// Get reminder hours before booking
  static Future<int> getReminderHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_reminderHoursKey) ?? 24;
    } catch (e) {
      _logger.e('Error getting reminder hours: $e');
      return 24;
    }
  }

  /// Set reminder hours before booking
  static Future<void> setReminderHours(int hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderHoursKey, hours);
      _logger.i('Reminder hours set to: $hours');
    } catch (e) {
      _logger.e('Error setting reminder hours: $e');
    }
  }

  /// Schedule reminders for all upcoming bookings
  static Future<void> scheduleAllBookingReminders() async {
    try {
      // Get user bookings from booking service
      final bookings = await bookingService.getUserBookings().first;

      for (final doc in bookings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final bookingDateTime = (data['dateTime'] as Timestamp).toDate();
        final serviceName = data['serviceName'] as String? ?? 'Servicio';
        final customerName = data['customerName'] as String? ?? 'Cliente';

        // Only schedule if booking is in the future
        if (bookingDateTime.isAfter(DateTime.now())) {
          await scheduleBookingReminder(
            bookingId: doc.id,
            serviceName: serviceName,
            customerName: customerName,
            bookingDateTime: bookingDateTime,
          );
        }
      }

      _logger.i('All booking reminders scheduled');
    } catch (e) {
      _logger.e('Error scheduling all booking reminders: $e');
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      _logger.i('All notifications cancelled');
    } catch (e) {
      _logger.e('Error cancelling all notifications: $e');
    }
  }

  /// Get notification settings summary
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final enabled = await areNotificationsEnabled();
      final reminderHours = await getReminderHours();
      final fcmToken = await getFCMToken();

      return {
        'enabled': enabled,
        'reminderHours': reminderHours,
        'fcmToken': fcmToken,
        'hasToken': fcmToken != null,
      };
    } catch (e) {
      _logger.e('Error getting notification settings: $e');
      return {
        'enabled': true,
        'reminderHours': 24,
        'fcmToken': null,
        'hasToken': false,
      };
    }
  }

  /// Dispose of resources
  static void dispose() {
    _onMessageController.close();
    _onMessageOpenedAppController.close();
    onNavigateToBooking = null;
  }
}

/// Singleton instance
final notificationService = NotificationService();
final bookingService = BookingService();
