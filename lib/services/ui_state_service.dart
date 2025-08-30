import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Service for managing consistent UI states across the application
class UiStateService {
  static final Logger _logger = Logger();

  // =============================================================================
  // LOADING WIDGETS
  // =============================================================================

  /// Creates a centered circular progress indicator with optional message
  static Widget buildLoadingIndicator({
    String? message,
    Color? color,
    double size = 40.0,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? const Color(0xff721c80),
              ),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: color ?? const Color(0xff721c80),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Creates a loading overlay that covers the entire screen
  static Widget buildLoadingOverlay({
    required Widget child,
    bool isLoading = false,
    String? loadingMessage,
    Color? overlayColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
            child: buildLoadingIndicator(
              message: loadingMessage ?? 'Cargando...',
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  /// Creates a skeleton loading effect for list items
  static Widget buildSkeletonLoader({
    int itemCount = 5,
    double height = 80.0,
    EdgeInsetsGeometry? margin,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: height,
          margin:
              margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SizedBox.shrink(),
        );
      },
    );
  }

  /// Creates a shimmer effect placeholder
  static Widget buildShimmerPlaceholder({
    double width = double.infinity,
    double height = 20.0,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  // =============================================================================
  // ERROR WIDGETS
  // =============================================================================

  /// Creates a comprehensive error display widget
  static Widget buildErrorWidget({
    required String title,
    required String message,
    IconData? icon,
    VoidCallback? onRetry,
    String? retryText,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 48,
            color: iconColor ?? Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor ?? Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText ?? 'Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor ?? Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Creates a simple error message widget
  static Widget buildSimpleError({
    required String message,
    IconData icon = Icons.error,
    Color? color,
    double? fontSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color ?? Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: color ?? Colors.red,
              fontSize: fontSize ?? 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Creates an empty state widget
  static Widget buildEmptyState({
    required String title,
    required String message,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox,
              size: 64,
              color: iconColor ?? Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor ?? Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff721c80),
                  foregroundColor: Colors.white,
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =============================================================================
  // SUCCESS WIDGETS
  // =============================================================================

  /// Creates a success message widget
  static Widget buildSuccessWidget({
    required String message,
    IconData icon = Icons.check_circle,
    Color? color,
    Duration autoHideDuration = const Duration(seconds: 3),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (color ?? Colors.green).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Colors.green).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color ?? Colors.green[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================================
  // STATE MANAGEMENT HELPERS
  // =============================================================================

  /// Wraps a widget with loading/error/empty state handling
  static Widget buildStateWrapper({
    required AsyncSnapshot snapshot,
    required Widget Function(dynamic data) onSuccess,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? emptyWidget,
    String? emptyMessage,
    String? emptyTitle,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return loadingWidget ?? buildLoadingIndicator(message: 'Cargando...');
    }

    if (snapshot.hasError) {
      _logger.e('Snapshot error: ${snapshot.error}');
      return errorWidget ??
          buildErrorWidget(
            title: 'Error',
            message: 'Ocurrió un error al cargar los datos.',
            onRetry: () {
              // Retry logic would be handled by parent widget
            },
          );
    }

    if (!snapshot.hasData ||
        (snapshot.data is List && (snapshot.data as List).isEmpty)) {
      return emptyWidget ??
          buildEmptyState(
            title: emptyTitle ?? 'Sin datos',
            message: emptyMessage ?? 'No hay información disponible.',
          );
    }

    return onSuccess(snapshot.data);
  }

  /// Shows a snackbar with consistent styling
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? const Color(0xff721c80),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows a loading dialog
  static void showLoadingDialog({
    required BuildContext context,
    String message = 'Cargando...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hides the current loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Logs UI state changes for debugging
  static void logStateChange(String widgetName, String state, [dynamic data]) {
    _logger.d(
        'UI State Change - $widgetName: $state${data != null ? ' - Data: $data' : ''}');
  }

  /// Creates a fade transition for state changes
  static Widget buildFadeTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      child: child,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Creates a slide transition for state changes
  static Widget buildSlideTransition({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(0, 0.1),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Singleton instance
final uiStateService = UiStateService();
