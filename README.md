# Sistema de Reserva de Salón con Modo de Respaldo

Este proyecto es una aplicación Flutter para reservas de salón de belleza que opera de manera autónoma sin requerir claves de API al inicio, con modos de respaldo integrados.

## 🚀 Características Principales

### ✅ Funcionamiento Sin API Keys
- **Inicio sin configuración**: La aplicación funciona completamente sin claves de API
- **Modo de respaldo automático**: Funcionalidad limitada pero operativa cuando faltan servicios externos
- **Configuración dinámica**: Las API keys se pueden agregar en tiempo de ejecución sin reiniciar

### 🗺️ Sistema de Mapas Inteligente
- **Google Maps completo**: Funcionalidad completa cuando se configura la API key
- **Modo respaldo**: Vista estática del salón con información de contacto cuando no hay API key
- **Transición fluida**: Cambia automáticamente entre modos sin interrupciones

### 🔥 Firebase con Respaldo
- **Base de datos en la nube**: Sincronización completa cuando Firebase está habilitado
- **Modo sin conexión**: Funcionalidad básica sin Firebase
- **Configuración opcional**: Firebase se puede deshabilitar completamente

### 🌍 Soporte Multiidioma
- **Español nativo**: Interfaz completamente en español
- **Inglés soportado**: Fácil extensión a otros idiomas
- **Localización automática**: Detecta el idioma del dispositivo

## 📋 Requisitos del Sistema

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Dispositivo o emulador para pruebas

## 🛠️ Instalación y Configuración

### 1. Clonación del Repositorio
```bash
git clone <repository-url>
cd salon_booking_app
```

### 2. Instalación de Dependencias
```bash
flutter pub get
```

### 3. Configuración de Variables de Entorno (Opcional)
Crea un archivo `.env` en la raíz del proyecto:
```env
# Google Maps API Key (opcional)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

### 4. Configuración de Firebase (Opcional)
1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agrega tu archivo `google-services.json` en `android/app/`
3. Habilita Firestore Database
4. Configura Authentication si es necesario

## 🎯 Uso de la Aplicación

### Modo Sin Configuración
1. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```
2. La aplicación iniciará automáticamente en modo respaldo
3. Todas las funciones básicas estarán disponibles

### Configuración de API Keys
1. **Accede a Configuración**: Navega a la pantalla de configuración desde el menú
2. **Google Maps**: Ingresa tu API key de Google Maps
3. **Firebase**: Habilita/deshabilita Firebase según necesites
4. **Guarda cambios**: Los cambios se aplican inmediatamente

### Funcionalidades por Modo

#### 🔸 Modo Básico (Sin API Keys)
- ✅ Pantalla de reservas con interfaz completa
- ✅ Lista de servicios (datos de ejemplo)
- ✅ Información de contacto del salón
- ✅ Vista de mapa estática
- ❌ Rutas en tiempo real
- ❌ Sincronización con base de datos

#### 🔸 Modo Completo (Con API Keys)
- ✅ Todas las funciones del modo básico
- ✅ Mapa interactivo con Google Maps
- ✅ Rutas y direcciones
- ✅ Sincronización con Firestore
- ✅ Autenticación de usuarios
- ✅ Reservas en tiempo real

## 🏗️ Arquitectura del Sistema

### Componentes Principales

#### 1. ApiConfigService
```dart
// Servicio central para gestión de configuraciones
final apiConfigService = ApiConfigService();
```

**Responsabilidades**:
- Gestión de claves de API
- Estado de servicios (habilitado/deshabilitado)
- Persistencia de configuraciones
- Notificación de cambios

#### 2. BackupMapWidget
```dart
// Widget de mapa sin dependencias externas
BackupMapWidget(
  locationName: 'Salón de Belleza',
  onGetDirections: () => _showDirections(),
)
```

#### 3. SettingsScreen
Pantalla completa para configuración de:
- Claves de API de Google Maps
- Estado de Firebase
- Restablecimiento de configuraciones

### Flujo de Funcionamiento

```
Inicio de App
      ↓
¿API Keys configuradas?
      ↓
     SÍ → Modo Completo
      ↓
     NO → Modo Respaldo
      ↓
Configuración dinámica disponible
```

## 🔧 Configuración Avanzada

### Variables de Entorno
```env
# Archivo .env
GOOGLE_MAPS_API_KEY=your_api_key_here
```

### Configuración Programática
```dart
// Configurar API key dinámicamente
await apiConfigService.updateGoogleMapsApiKey('your_api_key');

// Habilitar/deshabilitar Firebase
await apiConfigService.toggleFirebase(true);
```

### Personalización de Modo Respaldo
```dart
// En lib/widgets/backup_map_widget.dart
BackupMapWidget(
  latitude: 37.42796133580664,
  longitude: -122.085749655962,
  locationName: 'Tu Salón de Belleza',
  onGetDirections: () => _openMapsApp(),
)
```

## 🧪 Pruebas

### Ejecutar Pruebas
```bash
flutter test
```

### Escenarios de Prueba

#### 1. Modo Sin API Keys
```dart
// Verificar que la aplicación inicia correctamente
test('App starts without API keys', () async {
  // Test implementation
});
```

#### 2. Configuración Dinámica
```dart
// Verificar cambio de modos
test('Dynamic API key configuration', () async {
  // Test implementation
});
```

#### 3. Modo Respaldo de Mapas
```dart
// Verificar widget de respaldo
test('Backup map widget displays correctly', () async {
  // Test implementation
});
```

## 📱 Screenshots y Demostraciones

### Modo Completo
- Mapa interactivo con Google Maps
- Lista de servicios desde Firestore
- Reservas en tiempo real

### Modo Respaldo
- Vista estática del salón
- Información de contacto
- Funcionalidad básica de reservas

## 🚨 Solución de Problemas

### Problema: La aplicación no inicia
**Solución**: Verifica que todas las dependencias estén instaladas
```bash
flutter clean
flutter pub get
```

### Problema: Google Maps no funciona
**Solución**: Verifica la API key en configuración
1. Ve a Configuración
2. Ingresa una API key válida de Google Maps
3. Habilita los servicios necesarios en Google Cloud Console

### Problema: Firebase no se conecta
**Solución**: Verifica la configuración de Firebase
1. Archivo `google-services.json` presente
2. Proyecto Firebase configurado correctamente
3. Reglas de Firestore permiten acceso

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu función (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:
- Crea un issue en GitHub
- Contacta al equipo de desarrollo
- Consulta la documentación completa

---

**Desarrollado con ❤️ para la comunidad Flutter**
