# Instrucciones para Configurar Google Maps en la Aplicación

## Requisitos previos

1. Tener una cuenta de Google Cloud Platform
2. Tener un proyecto creado en Google Cloud Platform
3. Tener activada la facturación en el proyecto

## Pasos para obtener la API Key

1. Accede a la [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto o crea uno nuevo
3. Ve a "APIs y servicios" > "Credenciales"
4. Haz clic en "Crear credenciales" > "Clave API"
5. Copia la clave API generada

## Configuración en Android

1. Reemplaza "TU_API_KEY_AQUI" en el archivo `android/app/src/main/AndroidManifest.xml` con tu clave API real
2. Asegúrate de que los permisos de ubicación estén correctamente configurados

## Configuración en iOS

1. Reemplaza "TU_API_KEY_AQUI" en los archivos:
   - `ios/Runner/AppDelegate.swift`
   - `ios/Runner/Info.plist`
2. Asegúrate de que los permisos de ubicación estén correctamente configurados

## Activar APIs necesarias

En la Google Cloud Console, activa las siguientes APIs:
1. Maps SDK for Android
2. Maps SDK for iOS
3. Directions API (si usas rutas)
4. Geocoding API (si usas geocodificación)

## Restricciones de seguridad (recomendado)

Para mayor seguridad, aplica restricciones a tu clave API:
1. Ve a "APIs y servicios" > "Credenciales"
2. Haz clic en tu clave API
3. En "Restricciones de aplicación", selecciona el tipo de aplicación (Android/iOS)
4. Para Android, añade tu firma SHA-1 y nombre de paquete
5. Para iOS, añade tu bundle identifier
6. En "Restricciones de API", selecciona solo las APIs que estás usando

## Pruebas

Después de configurar la API key:
1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Ejecuta la aplicación en un dispositivo o emulador
4. Verifica que el mapa se cargue correctamente

## Problemas comunes

1. **Mapa no se muestra**: Verifica que la API key sea correcta y que las APIs necesarias estén activadas
2. **Permisos denegados**: Asegúrate de que los permisos de ubicación estén correctamente configurados
3. **Errores de facturación**: Verifica que la facturación esté activada en tu proyecto de Google Cloud