import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:salon_app/services/config_service.dart';
import 'package:salon_app/services/map_service.dart';
import 'package:salon_app/services/permissions_service.dart';
import 'package:salon_app/widgets/backup_map_widget.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final Logger _logger = Logger();

  CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = <Marker>{};
  final Set<Polyline> _polylines = <Polyline>{};
  final List<LatLng> _polylineCoordinates = <LatLng>[];

  late BitmapDescriptor customIcon;

  // Permission states
  bool _locationPermissionGranted = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    try {
      // Request location permission first
      await _requestLocationPermission();

      // Load dynamic salon location from Firestore
      final salonLocation = await mapService.getSalonLocation();
      if (salonLocation != null) {
        setState(() {
          _kGooglePlex = CameraPosition(
            target: salonLocation,
            zoom: 14.4746,
          );
        });
        _logger.i('Loaded dynamic salon location: $salonLocation');
      }

      await _setCustomMapPin();
      await _loadMarkers();
    } catch (e) {
      _logger.e('Error initializing map: $e');
      // Fallback: add markers without custom icon
      _addMarkers();
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!mounted) return;

    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final status = await PermissionsService.requestLocationWithRationale(
        context: context,
        rationaleTitle: '¿Por qué necesitamos tu ubicación?',
        rationaleMessage: 'Tu ubicación nos ayuda a:\n\n'
            '• Mostrar tu posición en el mapa\n'
            '• Calcular rutas óptimas al salón\n'
            '• Encontrar servicios cercanos\n'
            '• Mejorar tu experiencia de navegación',
      );

      setState(() {
        _locationPermissionGranted = status.isGranted;
      });

      if (status.isGranted) {
        _logger.i('Location permission granted successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permiso de ubicación concedido'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        _logger.w('Location permission permanently denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Permiso de ubicación denegado permanentemente. Habilítalo en configuración.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        _logger.w('Location permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Permiso de ubicación denegado. Algunas funciones estarán limitadas.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      setState(() {
        _locationPermissionGranted = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
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
          position: _kGooglePlex.target,
          infoWindow: const InfoWindow(
            title: 'Salón de Belleza',
            snippet: 'Dirección del salón',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      );
    });
  }

  Future<void> _loadMarkers() async {
    try {
      final markers = await mapService.createCustomMarkers(context);
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
      _logger.i('Loaded ${markers.length} markers from Firestore');
    } catch (e) {
      _logger.e('Error loading markers: $e');
      // Fallback to static markers
      _addMarkers();
    }
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
    return Consumer<ConfigService>(
      builder: (context, config, child) {
        final hasValidApiKey = config.googleMapsApiKey != null;

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
              if (!_locationPermissionGranted && !_isRequestingPermission)
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: _requestLocationPermission,
                  tooltip: 'Solicitar permiso de ubicación',
                ),
              if (_isRequestingPermission)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
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
                  myLocationButtonEnabled: _locationPermissionGranted,
                  myLocationEnabled: _locationPermissionGranted,
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
          // Permission status card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _locationPermissionGranted
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _locationPermissionGranted
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _locationPermissionGranted
                            ? 'Permiso de Ubicación Concedido'
                            : 'Permiso de Ubicación Requerido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _locationPermissionGranted
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _locationPermissionGranted
                        ? 'Tu ubicación está disponible para mejorar la experiencia del mapa.'
                        : 'Concede el permiso de ubicación para ver tu posición en el mapa y calcular rutas.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (!_locationPermissionGranted && !_isRequestingPermission)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: _requestLocationPermission,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Solicitar Permiso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff721c80),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (_isRequestingPermission)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xff721c80)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // API Key configuration card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración de Google Maps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'La funcionalidad completa del mapa requiere una clave de API de Google Maps válida. '
                    'Configure su clave de API para acceder a todas las funciones.',
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
    final config = context.read<ConfigService>();

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
                final success =
                    await config.updateConfig('GOOGLE_MAPS_API_KEY', apiKey);
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
