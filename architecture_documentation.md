# Documentación de Arquitectura - Salon Booking App

## Visión General
Aplicación Flutter para reservas de salón de belleza con arquitectura limpia y modular.

## Arquitectura General

### Patrón de Diseño
- **MVVM (Model-View-ViewModel)** con Provider para gestión de estado
- **Separación de responsabilidades** clara entre UI, lógica de negocio y datos
- **Inyección de dependencias** mediante Provider

### Estructura de Directorios
```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── components/               # Componentes reutilizables
│   ├── date_picker.dart      # Selector de fechas personalizado
│   ├── carousel.dart         # Carrusel de imágenes
│   └── searchbar.dart        # Barra de búsqueda
├── controller/               # Controladores de autenticación
│   └── auth_controller.dart  # Gestión de autenticación Firebase
├── provider/                 # Providers para gestión de estado
│   ├── user_provider.dart    # Estado del usuario autenticado
│   └── api_config_service.dart # Configuración de APIs
├── screens/                  # Pantallas de la aplicación
│   ├── booking/              # Pantalla de reservas
│   ├── home/                 # Pantalla principal
│   ├── maps/                 # Pantalla de mapas
│   ├── profile/              # Perfil de usuario
│   └── introduction/         # Pantallas de onboarding
├── services/                 # Servicios de negocio
│   ├── booking_service.dart  # Lógica de reservas
│   └── map_service.dart      # Lógica de mapas y ubicaciones
├── widgets/                  # Widgets personalizados
└── l10n/                     # Internacionalización
```

## Servicios Principales

### BookingService
**Responsabilidades:**
- Crear, leer, actualizar y eliminar reservas
- Validar datos de reserva
- Verificar disponibilidad de horarios
- Gestionar estados de reserva (confirmado, completado, cancelado)

**Métodos principales:**
- `createBooking()`: Crear nueva reserva
- `getUserBookings()`: Obtener reservas del usuario
- `updateBookingStatus()`: Cambiar estado de reserva
- `isSlotAvailable()`: Verificar disponibilidad
- `validateBookingData()`: Validar datos de entrada

### MapService
**Responsabilidades:**
- Gestionar ubicaciones del salón y trabajadores
- Calcular distancias entre puntos
- Crear marcadores personalizados
- Obtener información de ubicación desde Firestore

**Métodos principales:**
- `getSalonLocation()`: Obtener ubicación del salón
- `updateSalonLocation()`: Actualizar ubicación del salón
- `calculateDistance()`: Calcular distancia entre coordenadas
- `createCustomMarkers()`: Crear marcadores para el mapa
- `getNearbyServices()`: Encontrar servicios cercanos

### ConfigService
**Responsabilidades:**
- Gestionar TODA la configuración de la aplicación desde variables de entorno
- Centralizar todas las API keys, endpoints y configuraciones críticas
- Proporcionar acceso seguro a configuraciones sensibles
- Gestionar configuración por entorno (desarrollo, staging, producción)
- Almacenar configuraciones persistentes en SharedPreferences
- Validar configuraciones críticas para producción

**Características principales:**
- ✅ Singleton pattern para acceso global
- ✅ Carga automática desde archivo .env
- ✅ Validación de configuraciones críticas
- ✅ Modo seguro (sin exponer datos sensibles en logs)
- ✅ Soporte para múltiples entornos
- ✅ Integración completa con Provider

## Base de Datos - Firestore

### Colecciones Principales

#### `services`
```json
{
  "name": "string",
  "description": "string",
  "price": "number",
  "duration": "number",
  "category": "string",
  "img": "string",
  "isActive": "boolean"
}
```

#### `workers`
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "specialty": "string",
  "img": "string",
  "rating": "number",
  "location": {
    "latitude": "number",
    "longitude": "number"
  }
}
```

#### `bookings`
```json
{
  "serviceId": "string",
  "serviceName": "string",
  "workerId": "string",
  "workerName": "string",
  "customerId": "string",
  "customerName": "string",
  "customerPhone": "string",
  "customerEmail": "string",
  "dateTime": "timestamp",
  "status": "string",
  "notes": "string",
  "price": "number",
  "duration": "number"
}
```

#### `settings`
- `salon_location`: Ubicación del salón
- `salon_info`: Información de contacto y horarios

## Seguridad

### Reglas de Firestore
- **Lectura pública** para servicios y trabajadores
- **Escritura restringida** solo para administradores
- **Reservas privadas** - solo propietario o admin pueden acceder
- **Validación de datos** en reglas de seguridad

### Autenticación
- Firebase Authentication con Google Sign-In
- Verificación de tokens en reglas de seguridad
- Gestión de sesiones con Provider

## Gestión de Estado

### Provider Pattern
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
    ),
    ChangeNotifierProvider<ConfigService>.value(
      value: configService,
    ),
  ],
  child: MyApp(),
)
```

### Estados Principales
- **UserProvider**: Estado de autenticación del usuario
- **ConfigService**: Configuración centralizada de toda la aplicación
- **Local State**: Estados locales en widgets con setState

## Sistema de Configuración Centralizada

### Arquitectura del Sistema .env

El proyecto utiliza un sistema de configuración centralizada basado en variables de entorno que ofrece:

#### 1. Archivo .env Principal
- Contiene TODAS las configuraciones críticas del proyecto
- Estructurado por secciones lógicas con documentación detallada
- Excluido del versionado Git (.gitignore) por seguridad
- Soporte para múltiples entornos (desarrollo, staging, producción)

#### 2. Archivo .env.example
- Plantilla segura para nuevos desarrolladores
- Sin datos sensibles reales
- Instrucciones completas de configuración
- Ejemplos de uso y valores esperados

#### 3. ConfigService
- **Singleton pattern** para acceso global seguro
- **Carga automática** desde archivo .env al inicio
- **Validación integrada** de configuraciones críticas
- **Modo seguro** que no expone datos sensibles en logs
- **Persistencia** con SharedPreferences para configuraciones dinámicas
- **Integración completa** con Provider para inyección de dependencias

### Variables de Entorno por Categoría

#### 🔑 API Keys y Servicios Externos
```env
# Google Services
GOOGLE_MAPS_API_KEY=your_api_key_here
GOOGLE_PLACES_API_KEY=your_api_key_here

# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com

# Payment & Notifications
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
ONESIGNAL_APP_ID=your_onesignal_app_id
```

#### ⚙️ Configuración de Aplicación
```env
# App Settings
APP_NAME=Salon Booking App
APP_ENVIRONMENT=development
DEFAULT_LANGUAGE=es

# Feature Flags
FIREBASE_ENABLED=false
OFFLINE_MODE_ENABLED=true
PUSH_NOTIFICATIONS_ENABLED=false
PAYMENTS_ENABLED=false
```

#### 🔒 Seguridad y Encriptación
```env
# Security Keys
JWT_SECRET=your_jwt_secret_key
ENCRYPTION_KEY=your_32_character_key
ENCRYPTION_IV=your_16_character_iv

# SSL Configuration
SSL_ENABLED=true
```

### Integración con Provider

#### Configuración Global en main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar configuración centralizada
  await configService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigService>.value(
          value: configService,
        ),
        // Otros providers...
      ],
      child: const MyApp(),
    ),
  );
}
```

#### Acceso en Servicios
```dart
class BookingService {
  // Acceso directo al servicio singleton
  final String apiBaseUrl = configService.apiBaseUrl;
  final bool offlineMode = configService.offlineModeEnabled;

  Future<void> createBooking() async {
    if (!configService.firebaseEnabled) {
      // Lógica para modo offline
      return;
    }
    // Lógica normal con Firebase
  }
}
```

#### Acceso en Widgets
```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigService>();

    return Column(
      children: [
        Text('App: ${config.appName}'),
        Text('Versión: ${config.appVersion}'),
        Switch(
          value: config.firebaseEnabled,
          onChanged: (value) => config.updateConfig('FIREBASE_ENABLED', value),
        ),
      ],
    );
  }
}
```

### Validación y Seguridad

#### ✅ Validaciones Automáticas
- Verificación de API keys requeridas para producción
- Validación de formatos (emails, URLs, coordenadas)
- Comprobación de configuraciones críticas faltantes
- Alertas proactivas para configuraciones inválidas

#### 🔐 Modo Seguro
```dart
// ✅ Configuración segura para logs
Map<String, dynamic> safeConfig = configService.exportSafeConfig();
// Resultado: {appName: "Salon App", firebaseEnabled: true}

// ❌ NO exponer datos sensibles
debugPrint('API Key: ${configService.googleMapsApiKey}'); // PELIGROSO
```

### Configuración por Entorno

#### 🌍 Soporte Multi-entorno
```env
# Desarrollo
APP_ENVIRONMENT=development
API_BASE_URL=http://localhost:3000
FIREBASE_PROJECT_ID=salon-app-dev

# Producción
APP_ENVIRONMENT=production
API_BASE_URL=https://api.salonapp.com
FIREBASE_PROJECT_ID=salon-app-prod
```

#### 🔄 Overrides Dinámicos
```dart
// Cambiar configuración en runtime (persiste con SharedPreferences)
await configService.updateConfig('APP_ENVIRONMENT', 'production');
await configService.updateConfig('FIREBASE_ENABLED', false);
```

### Beneficios del Sistema

#### 🔒 **Seguridad Mejorada**
- Variables sensibles no versionadas en Git
- Validaciones automáticas de configuraciones
- Modo seguro para logging y debugging
- Encriptación opcional para datos críticos

#### 🔧 **Mantenibilidad Simplificada**
- Configuración centralizada en un solo lugar
- Cambios sin modificar código fuente
- Documentación integrada en el propio archivo
- Fácil rollback de configuraciones

#### 🚀 **Escalabilidad Optimizada**
- Nuevo servicios sin cambios de código
- Configuración por entorno automatizada
- Persistencia automática de cambios dinámicos
- Preparado para CI/CD pipelines

#### 👥 **Colaboración Eficiente**
- Archivo `.env.example` para onboarding rápido
- Configuración auto-documentada
- Validaciones con mensajes claros
- Separación clara entre entornos

### Mejores Prácticas Implementadas

#### 📝 Documentación
- Comentarios detallados en cada sección
- Ejemplos de uso y valores esperados
- Instrucciones de configuración por entorno
- Notas de seguridad y consideraciones

#### 🛡️ Seguridad
- Archivo `.env` excluido de Git
- Validación de configuraciones críticas
- Modo seguro para exportación de datos
- Encriptación para datos sensibles

#### 🔄 Flexibilidad
- Soporte para overrides dinámicos
- Configuración por entorno
- Persistencia automática
- Fallback a valores por defecto

Este sistema proporciona una base sólida y segura para la gestión de configuraciones, facilitando el mantenimiento, la escalabilidad y la colaboración en el proyecto.

## Manejo de Errores

### Estrategias Implementadas
1. **Validación de entrada** en formularios
2. **Try-catch blocks** en operaciones asíncronas
3. **Logging centralizado** con Logger package
4. **UI de fallback** para estados de error
5. **Modo offline** cuando servicios no están disponibles

### Manejo de Errores por Capa
- **UI Layer**: SnackBars, diálogos de error, estados de carga
- **Service Layer**: Logging, reintentos, validaciones
- **Data Layer**: Validaciones en Firestore rules

## Optimizaciones de Rendimiento

### Implementadas
1. **Lazy Loading** en listas grandes
2. **Caching** de imágenes con CachedNetworkImage
3. **StreamBuilder** para actualizaciones en tiempo real
4. **Debouncing** en búsquedas
5. **Paginación** preparada para futuras implementaciones

### Pendientes
1. **Offline-first** con sincronización
2. **Background sync** para reservas
3. **Image optimization** y compresión
4. **Bundle splitting** para reducción de tamaño

## Testing Strategy

### Unit Tests
- Servicios de negocio (BookingService, MapService)
- Validaciones de datos
- Utilidades y helpers

### Integration Tests
- Flujos completos de reserva
- Autenticación y navegación
- Integración con Firestore

### Widget Tests
- Componentes UI principales
- Formularios y validaciones
- Estados de carga y error

## Internacionalización (i18n)

### Implementación Actual
- Soporte básico para Español e Inglés
- AppLocalizations con delegados Flutter
- Locale configurado en main.dart

### Expansión Pendiente
- Más idiomas (Francés, Portugués, etc.)
- Traducciones dinámicas desde Firestore
- RTL support para idiomas árabes

## Monitoreo y Analytics

### Logging
- Logger package para logging estructurado
- Niveles: Debug, Info, Warning, Error
- Logs diferenciados por plataforma

### Analytics (Pendiente)
- Firebase Analytics para eventos de usuario
- Crash reporting con Firebase Crashlytics
- Performance monitoring

## Escalabilidad

### Arquitectura Escalable
1. **Modular Services**: Fácil agregar nuevos servicios
2. **Provider Pattern**: Gestión de estado extensible
3. **Repository Pattern**: Preparado para múltiples fuentes de datos
4. **Clean Architecture**: Separación clara de responsabilidades

### Próximas Funcionalidades
1. **Multi-tenancy** para múltiples salones
2. **API REST** para integraciones externas
3. **Real-time notifications** con WebSockets
4. **Advanced booking** con paquetes y promociones

## Deployment

### Configuración por Entorno
- **Development**: Firebase project de desarrollo
- **Staging**: Ambiente de pruebas
- **Production**: Ambiente de producción

### CI/CD Pipeline (Pendiente)
- Automated testing
- Code quality checks
- Automated deployment
- Environment-specific configurations

## Conclusión

La arquitectura implementada proporciona una base sólida y escalable para la aplicación de reservas de salón. Las decisiones de diseño priorizan:

- **Mantenibilidad** con separación clara de responsabilidades
- **Escalabilidad** con servicios modulares y patrones probados
- **Experiencia de usuario** con manejo robusto de errores y estados
- **Seguridad** con validaciones y reglas de acceso apropiadas
- **Performance** con optimizaciones y lazy loading

Las funcionalidades críticas están implementadas y probadas, proporcionando una base estable para futuras expansiones.