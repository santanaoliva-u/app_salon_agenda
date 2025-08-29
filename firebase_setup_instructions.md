# Instrucciones para Configurar Firebase en la Aplicación

## Requisitos previos

1. Tener una cuenta de Firebase
2. Tener un proyecto creado en Firebase
3. Tener instalado Firebase CLI (opcional pero recomendado)

## Pasos para configurar Firebase

### 1. Configuración del proyecto en Firebase Console

1. Accede a la [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. En el panel de control, haz clic en "Agregar app"
4. Selecciona "Android" (y/o "iOS" si es necesario)

### 2. Configuración para Android

1. Registra tu app con el nombre de paquete: `com.example.salon_app`
2. Descarga el archivo `google-services.json`
3. Coloca el archivo en `android/app/src/main/`
4. Asegúrate de que el plugin de Google Services esté configurado en `android/build.gradle` y `android/app/build.gradle`

### 3. Configuración para iOS

1. Registra tu app con el bundle ID: `com.example.salonApp`
2. Descarga el archivo `GoogleService-Info.plist`
3. Coloca el archivo en `ios/Runner/`
4. Asegúrate de que el plugin de Google Services esté configurado en el proyecto iOS

### 4. Configuración de las reglas de Firestore

En la sección "Firestore Database" de Firebase Console, configura las siguientes reglas:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permite lectura a todos los usuarios
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Reglas específicas para diferentes colecciones
    match /services/{service} {
      allow read: if true;  // Lectura pública
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    match /workers/{worker} {
      allow read: if true;  // Lectura pública
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### 5. Configuración de autenticación

1. En la sección "Authentication" de Firebase Console, habilita el método de inicio de sesión con Google
2. Configura el dominio de OAuth si es necesario
3. Asegúrate de que las credenciales de cliente de Google estén configuradas correctamente

### 6. Configuración de Storage (si se usa)

1. En la sección "Storage" de Firebase Console, habilita Firebase Storage
2. Configura las reglas de seguridad según sea necesario

## Verificación de la configuración

Después de completar la configuración:

1. Ejecuta `flutter clean`
2. Ejecuta `flutter pub get`
3. Ejecuta la aplicación en un dispositivo o emulador
4. Verifica que puedas:
   - Iniciar sesión con Google
   - Acceder a los datos de Firestore
   - Usar las funciones de Firebase correctamente

## Problemas comunes

1. **google-services.json no encontrado**: Asegúrate de que el archivo esté en la ubicación correcta
2. **Error de inicialización de Firebase**: Verifica que los plugins de Google Services estén correctamente configurados
3. **Permisos denegados en Firestore**: Revisa las reglas de seguridad
4. **Error de autenticación**: Verifica que el método de inicio de sesión esté habilitado en Firebase Console

## Mantenimiento

- Revisa regularmente las reglas de seguridad
- Monitorea el uso de recursos en la consola de Firebase
- Actualiza las dependencias de Firebase cuando sea necesario