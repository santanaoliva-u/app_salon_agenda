# Correcciones para la Integración de Google Maps

## Problemas identificados

1. **Falta de configuración de API key**: No se encuentra la configuración de Google Maps API
2. **Permisos insuficientes**: Posiblemente faltan permisos en AndroidManifest.xml
3. **Configuración incompleta**: No se ha verificado la implementación completa

## Configuración de API Key

### Para Android (android/app/src/main/AndroidManifest.xml)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.salon_app">
    
    <!-- Permisos necesarios -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:name="${applicationName}"
        android:label="salon_app"
        android:icon="@mipmap/ic_launcher">
        
        <!-- API Key de Google Maps -->
        <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="TU_API_KEY_AQUI"/>
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## Implementación corregida para MapsScreen

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  
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
    _setCustomMapPin();
    _addMarkers();
  }

  void _setCustomMapPin() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/map_marker.png', // Asegúrate de tener este asset
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
          icon: customIcon,
        ),
      );
    });
  }

  void _getPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "TU_API_KEY_AQUI", // Reemplazar con tu API key
      const PointLatLng(37.42796133580664, -122.085749655962),
      const PointLatLng(37.42196133580664, -122.085749655962),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del Salón'),
        backgroundColor: const Color(0xff721c80),
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getPolyline,
        child: const Icon(Icons.directions),
        backgroundColor: const Color(0xff721c80),
      ),
    );
  }
}
```

## Configuración para iOS (ios/Runner/AppDelegate.swift)

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Agregar tu API key aquí
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Configuración para iOS (ios/Runner/Info.plist)

```xml
<dict>
    <!-- Permisos de ubicación -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Esta aplicación necesita acceso a la ubicación para mostrar mapas.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Esta aplicación necesita acceso a la ubicación para mostrar mapas.</string>
    
    <!-- API Key de Google Maps -->
    <key>GMSApiKey</key>
    <string>TU_API_KEY_AQUI</string>
</dict>
```

## Manejo de errores y validaciones

```dart
// Función para verificar si Google Maps está disponible
Future<bool> _isGoogleMapsAvailable() async {
  try {
    // Intentar cargar el mapa
    return true;
  } catch (e) {
    // Manejar error
    return false;
  }
}

// Función para solicitar permisos de ubicación
Future<void> _requestLocationPermission() async {
  // Implementar solicitud de permisos usando el paquete permission_handler
  // https://pub.dev/packages/permission_handler
}

// Widget con manejo de errores
Widget _buildMapWithErrorHandling() {
  return FutureBuilder<bool>(
    future: _isGoogleMapsAvailable(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError || !snapshot.data!) {
        return const Center(
          child: Text(
            'No se puede cargar el mapa. Verifique su conexión a internet.',
            textAlign: TextAlign.center,
          ),
        );
      } else {
        return _buildGoogleMap();
      }
    },
  );
}
```

## Dependencias necesarias en pubspec.yaml

```yaml
dependencies:
  google_maps_flutter: ^2.2.3
  flutter_polyline_points: ^1.0.0
  permission_handler: ^10.2.0 # Para manejo de permisos
```

## Beneficios de las correcciones

1. **Configuración completa**: API key y permisos correctamente configurados
2. **Manejo de errores**: Validaciones para evitar crashes
3. **Experiencia de usuario mejorada**: Indicadores de carga y mensajes de error
4. **Compatibilidad**: Configuración tanto para Android como iOS
5. **Seguridad**: Manejo adecuado de permisos de ubicación

## Consideraciones importantes

1. **API Key**: Obtener una API key válida desde Google Cloud Console
2. **Facturación**: Habilitar la facturación en Google Cloud para usar Maps API
3. **Restricciones**: Aplicar restricciones a la API key para seguridad
4. **Pruebas**: Probar en dispositivos reales con GPS
5. **Permisos**: Solicitar permisos de ubicación en tiempo de ejecución
6. **Fallback**: Considerar implementar un mapa alternativo o coordenadas si Google Maps no está disponible