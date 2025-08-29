import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/services/api_config_service.dart';
import 'package:salon_app/widgets/backup_map_widget.dart';
import 'package:logger/logger.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Logger _logger = Logger();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  final List<LatLng> _polylineCoordinates = <LatLng>[];

  late BitmapDescriptor customIcon;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    try {
      await _setCustomMapPin();
      _addMarkers();
    } catch (e) {
      _logger.e('Error initializing map: $e');
      // Fallback: add markers without custom icon
      _addMarkers();
    }
  }

  Future<void> _setCustomMapPin() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/shop.png',
    );
  }

  void _addMarkers() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('salon_location'),
          position: const LatLng(37.42796133580664, -122.085749655962),
          infoWindow: const InfoWindow(
            title: 'Salón de Belleza',
            snippet: 'Dirección del salón',
          ),
          icon:
              customIcon, // Will use default marker if customIcon failed to load
        ),
      );
    });
  }

  void _getPolyline() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: const PointLatLng(37.42796133580664, -122.085749655962),
          destination: const PointLatLng(37.42196133580664, -122.085749655962),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        _polylineCoordinates.clear(); // Clear previous points
        for (var point in result.points) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              points: _polylineCoordinates,
            ),
          );
        });
      } else {
        _logger.w('No route points found');
      }
    } catch (e) {
      _logger.e('Error getting polyline: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiConfigService>(
      builder: (context, apiConfig, child) {
        final hasValidApiKey = apiConfig.hasValidGoogleMapsKey;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ubicación del Salón'),
            backgroundColor: const Color(0xff721c80),
            foregroundColor: Colors.white,
            actions: [
              if (!hasValidApiKey)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showApiKeyDialog(context),
                  tooltip: 'Configurar API Key',
                ),
            ],
          ),
          body: hasValidApiKey
              ? GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                )
              : _buildBackupMode(),
          floatingActionButton: hasValidApiKey
              ? FloatingActionButton(
                  onPressed: _getPolyline,
                  backgroundColor: const Color(0xff721c80),
                  child: const Icon(Icons.directions),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBackupMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          BackupMapWidget(
            latitude: 37.42796133580664,
            longitude: -122.085749655962,
            locationName:
                'Salón de Belleza Principal\n123 Calle Principal, Ciudad',
            onGetDirections: () => _showDirectionsDialog(context),
          ),
          const SizedBox(height: 20),
          SimpleMapContainer(
            title: 'Información de Contacto',
            subtitle:
                'Teléfono: +1 (555) 123-4567\nEmail: info@salonbelleza.com',
            icon: Icons.contact_phone,
            backgroundColor: Colors.blue[50],
          ),
          const SizedBox(height: 16),
          SimpleMapContainer(
            title: 'Horarios de Atención',
            subtitle:
                'Lunes - Viernes: 9:00 AM - 8:00 PM\nSábados: 8:00 AM - 6:00 PM\nDomingos: Cerrado',
            icon: Icons.schedule,
            backgroundColor: Colors.green[50],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modo Limitado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'La funcionalidad completa del mapa requiere una clave de API de Google Maps válida. '
                    'Configure su clave de API en la configuración para acceder a todas las funciones.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showApiKeyDialog(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('Configurar API Key'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff721c80),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final TextEditingController apiKeyController = TextEditingController();
    final apiConfig = context.read<ApiConfigService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Google Maps API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingrese su clave de API de Google Maps para habilitar la funcionalidad completa del mapa:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Ingrese su clave de API',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final apiKey = apiKeyController.text.trim();
              if (apiKey.isNotEmpty) {
                final success = await apiConfig.updateGoogleMapsApiKey(apiKey);
                if (success) {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('API Key configurada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al guardar la API Key'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff721c80),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDirectionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obtener Direcciones'),
        content: const Text(
          'Para obtener direcciones detalladas, configure una clave de API de Google Maps válida en la configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showApiKeyDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff721c80),
            ),
            child: const Text('Configurar API'),
          ),
        ],
      ),
    );
  }
}
