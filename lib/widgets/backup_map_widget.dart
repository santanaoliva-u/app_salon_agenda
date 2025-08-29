import 'package:flutter/material.dart';

/// A simple map widget that works without Google Maps API key
/// Provides basic location display functionality as a fallback
class BackupMapWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final VoidCallback? onGetDirections;

  const BackupMapWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onGetDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Ubicación del Salón',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              locationName ?? 'Dirección del salón de belleza',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 16),
          if (latitude != null && longitude != null) ...[
            Text(
              'Coordenadas: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 16),
          ],
          if (onGetDirections != null)
            ElevatedButton.icon(
              onPressed: onGetDirections,
              icon: const Icon(Icons.directions),
              label: const Text('Obtener Direcciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff721c80),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple static map representation
class SimpleMapContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;

  const SimpleMapContainer({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.location_on,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(0xff721c80),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
