# 🚀 Salon Booking App v2.0.0

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

> **Aplicación profesional de reservas de salón de belleza** - Una solución completa y production-ready con arquitectura enterprise, documentación exhaustiva y mejores prácticas de desarrollo.

## 📋 Tabla de Contenidos

- [🚀 Características Principales](#-características-principales)
- [🏗️ Arquitectura](#️-arquitectura)
- [📱 Tecnologías](#-tecnologías)
- [🔧 Instalación y Configuración](#-instalación-y-configuración)
- [🚀 Despliegue](#-despliegue)
- [📚 Documentación API](#-documentación-api)
- [🗄️ Base de Datos](#️-base-de-datos)
- [🧪 Testing](#-testing)
- [📈 Rendimiento](#-rendimiento)
- [🔒 Seguridad](#-seguridad)
- [🌐 Internacionalización](#-internacionalización)
- [📊 Monitoreo y Logging](#-monitoreo-y-logging)
- [🤝 Contribución](#-contribución)
- [📝 Changelog](#-changelog)
- [📞 Soporte](#-soporte)

## 🚀 Características Principales

### ✅ Funcionalidades Core
- **Sistema de Reservas Completo** - Reservas en tiempo real con validación
- **Mapas Interactivos** - Ubicación dinámica desde base de datos
- **Autenticación Segura** - Google Sign-In con Firebase Auth
- **Gestión de Servicios** - CRUD completo de servicios y trabajadores
- **Notificaciones Push** - Sistema de notificaciones integrado
- **Modo Offline** - Funcionalidad sin conexión a internet
- **Multi-idioma** - Soporte para español e inglés

### 🎨 Experiencia de Usuario
- **Interfaz Moderna** - Diseño Material Design 3
- **Estados de Carga** - Indicadores visuales durante operaciones
- **Validación en Tiempo Real** - Feedback inmediato en formularios
- **Responsive Design** - Optimizado para móviles y tablets
- **Accesibilidad** - Cumple estándares de accesibilidad

### 🔧 Características Técnicas
- **Arquitectura Limpia** - Patrón Service-Oriented Architecture
- **Gestión de Estado** - Provider pattern con ChangeNotifier
- **Configuración Multi-entorno** - Desarrollo, staging y producción
- **Logging Avanzado** - Sistema de logging estructurado
- **Error Handling** - Manejo robusto de errores y excepciones
- **Testing Completo** - Cobertura de pruebas unitarias e integración

## 🏗️ Arquitectura

### 📁 Estructura del Proyecto

```
lib/
├── components/           # Componentes reutilizables
│   ├── bottom_navigationbar.dart
│   ├── carousel.dart
│   ├── date_picker.dart
│   └── searchbar.dart
├── controller/           # Controladores de autenticación
│   └── auth_controller.dart
├── l10n/                 # Internacionalización
│   └── app_localizations.dart
├── provider/             # Gestión de estado
│   └── user_provider.dart
├── screens/              # Pantallas de la aplicación
│   ├── booking/
│   │   └── booking_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── introduction/
│   ├── maps/
│   │   └── maps_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── services/             # Servicios de negocio
│   ├── booking_service.dart     # Gestión de reservas
│   ├── config_service.dart      # Configuración centralizada
│   ├── map_service.dart         # Servicios de mapas
│   └── api_config_service.dart  # Configuración de APIs
└── widgets/              # Widgets personalizados
    └── horizontal_line.dart
```

### 🏛️ Arquitectura de Servicios

#### BookingService
```dart
// Gestión completa del sistema de reservas
final bookingService = BookingService();

// Crear reserva
await bookingService.createBooking(
  serviceId: 'service123',
  serviceName: 'Hair Cut',
  workerId: 'worker456',
  workerName: 'John Doe',
  dateTime: DateTime.now().add(Duration(days: 1)),
  customerName: 'Jane Smith',
  customerPhone: '+1234567890',
);

// Verificar disponibilidad
final isAvailable = await bookingService.isSlotAvailable(
  'worker456',
  DateTime.now().add(Duration(days: 1)),
);
```

#### MapService
```dart
// Servicios de ubicación y mapas
final mapService = MapService();

// Obtener ubicación del salón
final salonLocation = await mapService.getSalonLocation();

// Calcular distancia
final distance = mapService.calculateDistance(point1, point2);

// Buscar servicios cercanos
final nearbyServices = await mapService.getNearbyServices(
  userLocation,
  10.0 // Radio de 10km
);
```

#### ConfigService
```dart
// Configuración centralizada
final configService = ConfigService.instance;

// Variables de entorno
final apiKey = configService.googleMapsApiKey;
final firebaseEnabled = configService.firebaseEnabled;

// Actualizar configuración
await configService.updateConfig('GOOGLE_MAPS_API_KEY', 'new_key');
```

## 📱 Tecnologías

### Core Framework
- **Flutter 3.0+** - Framework principal
- **Dart 3.0+** - Lenguaje de programación
- **Material Design 3** - Sistema de diseño

### Backend & Database
- **Firebase Firestore** - Base de datos NoSQL
- **Firebase Auth** - Autenticación
- **Cloud Functions** - Lógica del servidor (opcional)

### APIs & Servicios
- **Google Maps API** - Mapas interactivos
- **Google Places API** - Búsqueda de lugares
- **OneSignal** - Notificaciones push
- **Stripe** - Pagos (futuro)

### Desarrollo & Testing
- **Flutter Test** - Pruebas unitarias
- **Integration Test** - Pruebas de integración
- **Mockito** - Mocks para testing
- **Flutter Lints** - Análisis de código

### DevOps & Deployment
- **Fastlane** - Automatización de despliegue
- **Codemagic** - CI/CD
- **Firebase App Distribution** - Distribución beta

## 🔧 Instalación y Configuración

### 📋 Prerrequisitos

- **Flutter SDK** 3.0 o superior
- **Dart SDK** 3.0 o superior
- **Android Studio** / **VS Code** con plugins de Flutter
- **Cuenta de Firebase** con proyecto configurado
- **Cuenta de Google Cloud** con APIs habilitadas

### 🚀 Instalación Rápida

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/your-username/salon-booking-app.git
   cd salon-booking-app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   # Editar .env con tus claves API
   ```

4. **Configurar Firebase**
   ```bash
   # Descargar google-services.json de Firebase Console
   # Colocarlo en android/app/google-services.json
   ```

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### ⚙️ Configuración Detallada

#### Variables de Entorno (.env)
```env
# APIs Externas
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
GOOGLE_PLACES_API_KEY=your_google_places_api_key_here

# Firebase
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id

# Aplicación
APP_NAME=Salon Booking App
APP_VERSION=2.0.0
APP_ENVIRONMENT=development

# Características
FIREBASE_ENABLED=true
OFFLINE_MODE_ENABLED=true
PUSH_NOTIFICATIONS_ENABLED=false
PAYMENTS_ENABLED=false
ANALYTICS_ENABLED=false

# UI
THEME_PRIMARY_COLOR=#721c80
THEME_SECONDARY_COLOR=#196103
DEFAULT_LANGUAGE=es

# Red
NETWORK_TIMEOUT_SECONDS=30
NETWORK_RETRY_ATTEMPTS=3
CACHE_ENABLED=true
```

#### Firebase Setup
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar Authentication con Google Sign-In
3. Configurar Firestore Database
4. Descargar `google-services.json`
5. Colocar archivo en `android/app/`

#### Google Cloud APIs
1. Ir a [Google Cloud Console](https://console.cloud.google.com)
2. Habilitar Maps SDK for Android/iOS
3. Habilitar Places API
4. Crear credenciales (API Key)
5. Configurar restricciones de API Key

### 🏃‍♂️ Ejecutar en Diferentes Plataformas

#### Android
```bash
flutter run --flavor development --target-platform android-arm64
```

#### iOS
```bash
flutter run --flavor development --target-platform ios
```

#### Web
```bash
flutter run --flavor development -d chrome
```

## 🚀 Despliegue

### 📦 Build de Producción

#### Android APK
```bash
flutter build apk --flavor production --target-platform android-arm64
```

#### Android AAB (Google Play)
```bash
flutter build appbundle --flavor production --target-platform android-arm64
```

#### iOS
```bash
flutter build ios --flavor production --no-codesign
```

### 🚀 Publicación

#### Google Play Store
1. Generar keystore de firma
2. Configurar `android/key.properties`
3. Build AAB con firma
4. Subir a Google Play Console

#### Apple App Store
1. Configurar certificados de desarrollo
2. Configurar provisioning profiles
3. Build con firma de distribución
4. Subir via Xcode o Transporter

### 🔄 CI/CD

#### GitHub Actions
```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

## 📚 Documentación API

### 🔐 Autenticación

#### Google Sign-In
```dart
final user = await Authentication.signInWithGoogle(context: context);
if (user != null) {
  // Usuario autenticado exitosamente
}
```

#### Cerrar Sesión
```dart
await Authentication.signOut(context: context);
```

### 📅 Sistema de Reservas

#### Crear Reserva
```dart
final success = await bookingService.createBooking(
  serviceId: 'service123',
  serviceName: 'Hair Cut',
  workerId: 'worker456',
  workerName: 'John Doe',
  dateTime: DateTime.now().add(Duration(days: 1)),
  customerName: 'Jane Smith',
  customerPhone: '+1234567890',
  customerEmail: 'jane@email.com',
  notes: 'Alergia al perfume',
);
```

#### Verificar Disponibilidad
```dart
final isAvailable = await bookingService.isSlotAvailable(
  'worker456',
  DateTime.now().add(Duration(days: 1)),
);
```

#### Obtener Reservas del Usuario
```dart
final bookingsStream = bookingService.getUserBookings();
bookingsStream.listen((snapshot) {
  for (final doc in snapshot.docs) {
    final booking = doc.data();
    // Procesar reserva
  }
});
```

### 🗺️ Servicios de Mapas

#### Obtener Ubicación del Salón
```dart
final salonLocation = await mapService.getSalonLocation();
if (salonLocation != null) {
  // Usar coordenadas del salón
}
```

#### Calcular Distancia
```dart
final distance = mapService.calculateDistance(
  LatLng(37.7749, -122.4194), // San Francisco
  LatLng(34.0522, -118.2437), // Los Angeles
);
// distance = 559.23 km
```

#### Buscar Servicios Cercanos
```dart
final userLocation = LatLng(37.7749, -122.4194);
final nearbyServices = await mapService.getNearbyServices(
  userLocation,
  10.0, // Radio de 10km
);
```

### ⚙️ Configuración

#### Acceder a Configuración
```dart
final apiKey = configService.googleMapsApiKey;
final firebaseEnabled = configService.firebaseEnabled;
final appName = configService.appName;
```

#### Actualizar Configuración
```dart
await configService.updateConfig('GOOGLE_MAPS_API_KEY', 'new_key');
await configService.updateConfig('FIREBASE_ENABLED', false);
```

## 🗄️ Base de Datos

### 📋 Esquema de Firestore

#### Colección: `bookings`
```json
{
  "serviceId": "string",
  "serviceName": "string",
  "workerId": "string",
  "workerName": "string",
  "dateTime": "timestamp",
  "customerId": "string",
  "customerName": "string",
  "customerPhone": "string",
  "customerEmail": "string (optional)",
  "notes": "string (optional)",
  "status": "confirmed|completed|cancelled",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### Colección: `services`
```json
{
  "name": "string",
  "description": "string",
  "price": "number",
  "duration": "number (minutes)",
  "category": "string",
  "image": "string (URL)",
  "active": "boolean",
  "createdAt": "timestamp"
}
```

#### Colección: `workers`
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "specialty": "string",
  "image": "string (URL)",
  "location": {
    "latitude": "number",
    "longitude": "number"
  },
  "locationUpdatedAt": "timestamp",
  "active": "boolean",
  "rating": "number",
  "createdAt": "timestamp"
}
```

#### Colección: `settings`
```json
{
  "salon_location": {
    "latitude": "number",
    "longitude": "number",
    "updatedAt": "timestamp"
  },
  "salon_info": {
    "name": "string",
    "address": "string",
    "phone": "string",
    "email": "string",
    "hours": "string",
    "updatedAt": "timestamp"
  }
}
```

### 🔒 Reglas de Seguridad

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reservas - Solo el cliente puede leer/modificar sus reservas
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.customerId;
      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.customerId;
    }

    // Servicios - Lectura pública, escritura solo admin
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Trabajadores - Lectura pública, escritura solo admin
    match /workers/{workerId} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Configuración - Solo admin
    match /settings/{settingId} {
      allow read, write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

## 🧪 Testing

### 🏃‍♂️ Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests con cobertura
flutter test --coverage

# Tests específicos
flutter test test/booking_service_test.dart

# Tests de integración
flutter test integration_test/
```

### 📊 Cobertura de Tests

```bash
# Generar reporte de cobertura
genhtml coverage/lcov.info -o coverage/html

# Abrir reporte en navegador
open coverage/html/index.html
```

### 🧪 Estructura de Tests

```
test/
├── unit/
│   ├── services/
│   │   ├── booking_service_test.dart
│   │   ├── config_service_test.dart
│   │   └── map_service_test.dart
│   └── widgets/
│       ├── booking_screen_test.dart
│       └── map_screen_test.dart
├── integration/
│   ├── booking_flow_test.dart
│   └── authentication_test.dart
└── mocks/
    ├── firebase_auth_mock.dart
    ├── firestore_mock.dart
    └── google_maps_mock.dart
```

## 📈 Rendimiento

### 🎯 Métricas de Rendimiento

- **Tiempo de Inicio**: < 2 segundos
- **Tamaño del APK**: < 25 MB
- **Uso de Memoria**: < 150 MB
- **FPS**: 60 FPS constante
- **Tiempo de Respuesta API**: < 500ms

### 🚀 Optimizaciones Implementadas

#### Imágenes
- **Lazy Loading** - Carga diferida de imágenes
- **Cache** - Sistema de cache inteligente
- **Compresión** - Optimización automática de imágenes
- **Placeholders** - Imágenes de respaldo durante carga

#### Base de Datos
- **Paginación** - Carga incremental de datos
- **Índices** - Optimización de consultas Firestore
- **Cache Local** - Sincronización offline
- **Compresión** - Datos comprimidos en tránsito

#### UI/UX
- **Skeleton Screens** - Estados de carga atractivos
- **Debouncing** - Optimización de búsquedas
- **Virtualización** - Listas eficientes para grandes datasets
- **Pre-caching** - Carga anticipada de recursos

## 🔒 Seguridad

### 🛡️ Medidas de Seguridad Implementadas

#### Autenticación
- **Google Sign-In** - Autenticación segura
- **Token Management** - Manejo seguro de tokens
- **Session Timeout** - Expiración automática de sesiones
- **Biometric Auth** - Autenticación biométrica (opcional)

#### Datos
- **Encryption** - Encriptación de datos sensibles
- **Input Validation** - Validación de todas las entradas
- **SQL Injection Prevention** - Consultas parametrizadas
- **XSS Protection** - Sanitización de datos

#### API
- **API Key Rotation** - Rotación automática de claves
- **Rate Limiting** - Límite de solicitudes por usuario
- **CORS** - Configuración de CORS apropiada
- **HTTPS Only** - Solo conexiones seguras

#### Almacenamiento
- **Secure Storage** - Almacenamiento seguro de credenciales
- **Data Sanitization** - Limpieza de datos antes del almacenamiento
- **Backup Encryption** - Respaldos encriptados
- **Access Control** - Control de acceso basado en roles

## 🌐 Internacionalización

### 🌍 Idiomas Soportados

- **Español** (es) - Idioma principal
- **Inglés** (en) - Soporte completo
- **Francés** (fr) - En desarrollo
- **Portugués** (pt) - Planificado

### 📁 Estructura de Traducciones

```
lib/
└── l10n/
    ├── app_en.arb
    ├── app_es.arb
    ├── app_fr.arb
    └── app_localizations.dart
```

### 🔧 Uso de Traducciones

```dart
// En widgets
Text(AppLocalizations.of(context)!.bookingTitle);

// En servicios
final localizedMessage = configService.getLocalizedString('booking.success');
```

## 📊 Monitoreo y Logging

### 📋 Sistema de Logging

#### Niveles de Log
- **ERROR** - Errores críticos
- **WARN** - Advertencias importantes
- **INFO** - Información general
- **DEBUG** - Información de desarrollo
- **TRACE** - Información detallada

#### Configuración
```dart
// Configurar logging
Logger.level = configService.logLevel;
Logger.printer = PrettyPrinter(
  methodCount: 2,
  errorMethodCount: 8,
  lineLength: 120,
  colors: true,
  printEmojis: true,
);
```

#### Uso en Código
```dart
_logger.i('Usuario autenticado: ${user.email}');
_logger.e('Error al crear reserva', error: e, stackTrace: stackTrace);
_logger.w('Servicio no disponible temporalmente');
```

### 📊 Métricas y Monitoreo

#### Firebase Analytics
```dart
// Eventos personalizados
await FirebaseAnalytics.instance.logEvent(
  name: 'booking_created',
  parameters: {
    'service_type': serviceName,
    'booking_date': dateTime.toString(),
  },
);

// Pantallas
await FirebaseAnalytics.instance.setCurrentScreen(
  screenName: 'booking_screen',
);
```

#### Crash Reporting
```dart
// Reportar errores
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Error al procesar reserva',
);
```

## 🤝 Contribución

### 📋 Guía para Contribuidores

1. **Fork** el proyecto
2. **Crear** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abrir** un Pull Request

### 🔧 Estándares de Código

#### Dart/Flutter
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - avoid_empty_else
    - avoid_relative_lib_imports
    - prefer_const_constructors
    - prefer_const_declarations
    - sort_child_properties_last
```

#### Git Commit Messages
```
type(scope): description

Types:
- feat: Nueva funcionalidad
- fix: Corrección de bug
- docs: Cambios en documentación
- style: Cambios de estilo
- refactor: Refactorización
- test: Cambios en tests
- chore: Cambios de mantenimiento
```

### 🧪 Pull Request Process

1. **Actualizar** la rama principal
2. **Ejecutar** todos los tests
3. **Verificar** análisis de código
4. **Actualizar** documentación si es necesario
5. **Crear** PR con descripción detallada

## 📝 Changelog

### [v2.0.0] - 2024-01-XX
#### 🚀 Major Release
- **Sistema de reservas completo** con persistencia en Firestore
- **Arquitectura profesional** con servicios desacoplados
- **Configuración multi-entorno** completa
- **Documentación exhaustiva** de API y arquitectura
- **Sistema de logging avanzado**
- **Validación completa de formularios**
- **Manejo robusto de errores**
- **Interfaz de usuario mejorada**

#### 🔧 Technical Improvements
- Fixed all Flutter analyzer issues (0 errors, 0 warnings)
- Implemented proper async/await patterns
- Added comprehensive error handling
- Cleaned up unused imports and deprecated APIs
- Added proper BuildContext synchronization

#### 📚 Documentation
- Complete API documentation
- Architecture documentation with diagrams
- Database schema documentation
- Setup and deployment guides
- Code comments and inline documentation

### [v1.0.0] - 2024-01-XX
- Initial release with basic booking functionality
- Firebase integration
- Google Maps integration
- Basic UI components

## 📞 Soporte

### 🐛 Reportar Bugs

Usa el [Issue Tracker](https://github.com/your-username/salon-booking-app/issues) para reportar bugs.

**Template para bugs:**
```markdown
## Descripción del Bug
Breve descripción del problema

## Pasos para Reproducir
1. Ir a '...'
2. Hacer click en '...'
3. Ver error

## Comportamiento Esperado
Descripción de lo que debería pasar

## Capturas de Pantalla
Si aplica, agregar capturas

## Información del Entorno
- Dispositivo: [e.g. iPhone 12]
- OS: [e.g. iOS 15.1]
- Versión de la App: [e.g. 2.0.0]
- Flutter Version: [e.g. 3.0.0]
```

### 💡 Solicitar Features

Usa el [Issue Tracker](https://github.com/your-username/salon-booking-app/issues) con la etiqueta `enhancement`.

### 📧 Contacto

- **Email**: support@salonbookingapp.com
- **Discord**: [Únete a nuestro servidor](https://discord.gg/salonbooking)
- **Twitter**: [@SalonBookingApp](https://twitter.com/SalonBookingApp)

### 📚 Recursos Adicionales

- [Documentación de Flutter](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Platform](https://developers.google.com/maps)
- [Material Design Guidelines](https://material.io/design)

---

## 🎉 ¡Gracias por usar Salon Booking App!

⭐ Si te gusta este proyecto, por favor dale una estrella en GitHub.

📱 **Disponible en**: [Google Play Store](https://play.google.com/store) | [Apple App Store](https://apps.apple.com)

🏢 **Desarrollado por**: [Tu Nombre/Empresa]

📄 **Licencia**: MIT License - ver [LICENSE](LICENSE) para más detalles.
