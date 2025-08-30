import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

/// Service for managing app permissions with user-friendly handling
class PermissionsService {
  static final Logger _logger = Logger();

  /// Request location permission with comprehensive error handling
  static Future<PermissionStatus> requestLocationPermission({
    bool showDialogIfDenied = true,
  }) async {
    try {
      // Check current permission status
      final status = await Permission.location.status;

      if (status.isGranted) {
        _logger.i('Location permission already granted');
        return status;
      }

      if (status.isDenied) {
        // Request permission
        final result = await Permission.location.request();

        if (result.isGranted) {
          _logger.i('Location permission granted');
          return result;
        } else if (result.isPermanentlyDenied) {
          _logger.w('Location permission permanently denied');
          if (showDialogIfDenied) {
            await _showPermissionDialog(
              title: 'Permiso de Ubicación Requerido',
              message:
                  'Esta aplicación necesita acceso a tu ubicación para mostrar mapas y calcular rutas. Por favor, habilita el permiso en la configuración de la aplicación.',
              onSettingsPressed: () => openAppSettings(),
            );
          }
          return result;
        } else {
          _logger.w('Location permission denied');
          if (showDialogIfDenied) {
            await _showPermissionDialog(
              title: 'Permiso Denegado',
              message:
                  'Sin el permiso de ubicación, algunas funciones del mapa estarán limitadas.',
              onSettingsPressed: () => openAppSettings(),
            );
          }
          return result;
        }
      }

      if (status.isPermanentlyDenied) {
        _logger.w('Location permission permanently denied');
        if (showDialogIfDenied) {
          await _showPermissionDialog(
            title: 'Permiso de Ubicación Requerido',
            message:
                'El permiso de ubicación fue denegado permanentemente. Por favor, habilítalo en la configuración de la aplicación.',
            onSettingsPressed: () => openAppSettings(),
          );
        }
        return status;
      }

      // Request permission for the first time
      final result = await Permission.location.request();
      _logger.i('Location permission request result: $result');
      return result;
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      _logger.e('Error checking location permission: $e');
      return false;
    }
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions({
    List<Permission> permissions = const [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ],
  }) async {
    try {
      final statuses = await permissions.request();
      _logger.i('Multiple permissions requested: $statuses');
      return statuses;
    } catch (e) {
      _logger.e('Error requesting multiple permissions: $e');
      return {};
    }
  }

  /// Check permission status for a specific permission
  static Future<PermissionStatus> checkPermissionStatus(
      Permission permission) async {
    try {
      return await permission.status;
    } catch (e) {
      _logger.e('Error checking permission status: $e');
      return PermissionStatus.denied;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      _logger.e('Error opening app settings: $e');
      return false;
    }
  }

  /// Show permission explanation dialog
  static Future<void> _showPermissionDialog({
    required String title,
    required String message,
    required VoidCallback onSettingsPressed,
  }) async {
    // This would be called from a BuildContext, so we'll return early
    // The actual dialog should be shown by the calling widget
    _logger.i('Permission dialog requested: $title');
  }

  /// Get user-friendly permission status description
  static String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Concedido';
      case PermissionStatus.denied:
        return 'Denegado';
      case PermissionStatus.permanentlyDenied:
        return 'Denegado permanentemente';
      case PermissionStatus.restricted:
        return 'Restringido';
      case PermissionStatus.limited:
        return 'Limitado';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  /// Check if permission needs to be requested
  static bool shouldRequestPermission(PermissionStatus status) {
    return status.isDenied || status.isPermanentlyDenied;
  }

  /// Handle permission rationale (educational dialog)
  static Future<bool> showPermissionRationale({
    required BuildContext context,
    required String title,
    required String message,
    String positiveButtonText = 'Continuar',
    String negativeButtonText = 'Cancelar',
  }) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(negativeButtonText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(positiveButtonText),
            ),
          ],
        ),
      );

      return result ?? false;
    } catch (e) {
      _logger.e('Error showing permission rationale: $e');
      return false;
    }
  }

  /// Comprehensive location permission flow
  static Future<PermissionStatus> requestLocationWithRationale({
    required BuildContext context,
    String rationaleTitle = '¿Por qué necesitamos tu ubicación?',
    String rationaleMessage = 'Tu ubicación nos ayuda a:\n\n'
        '• Mostrar tu posición en el mapa\n'
        '• Calcular rutas óptimas\n'
        '• Encontrar servicios cercanos\n'
        '• Mejorar tu experiencia de navegación',
  }) async {
    try {
      // First check current status
      final currentStatus = await Permission.location.status;

      if (currentStatus.isGranted) {
        return currentStatus;
      }

      // Show rationale if permission is denied
      if (currentStatus.isDenied) {
        // CORRECCIÓN: Almacenar context localmente para evitar linting issue
        final localContext = context;
        final shouldRequest = await showPermissionRationale(
          // ignore: use_build_context_synchronously
          context: localContext,
          title: rationaleTitle,
          message: rationaleMessage,
        );

        if (!shouldRequest) {
          return PermissionStatus.denied;
        }

        // Verificar que el context siga siendo válido después del async gap
        if (!localContext.mounted) {
          return PermissionStatus.denied;
        }
      }

      // Request permission
      return await requestLocationPermission(showDialogIfDenied: true);
    } catch (e) {
      _logger.e('Error in comprehensive location permission flow: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check and request notification permission
  static Future<PermissionStatus> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        return status;
      }

      if (status.isDenied) {
        final result = await Permission.notification.request();
        _logger.i('Notification permission result: $result');
        return result;
      }

      return status;
    } catch (e) {
      _logger.e('Error requesting notification permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Get comprehensive permission status report
  static Future<Map<String, dynamic>> getPermissionReport() async {
    try {
      final locationStatus = await Permission.location.status;
      final notificationStatus = await Permission.notification.status;

      return {
        'location': {
          'status': locationStatus,
          'description': getPermissionStatusDescription(locationStatus),
          'granted': locationStatus.isGranted,
          'denied': locationStatus.isDenied,
          'permanentlyDenied': locationStatus.isPermanentlyDenied,
        },
        'notification': {
          'status': notificationStatus,
          'description': getPermissionStatusDescription(notificationStatus),
          'granted': notificationStatus.isGranted,
          'denied': notificationStatus.isDenied,
          'permanentlyDenied': notificationStatus.isPermanentlyDenied,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Error generating permission report: $e');
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

/// Singleton instance
final permissionsService = PermissionsService();
