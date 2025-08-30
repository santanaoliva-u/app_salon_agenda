# Esquemas de Base de Datos - Firestore

## Colección: `services`
Almacena información de los servicios ofrecidos por el salón.

### Estructura del documento:
```json
{
  "id": "string (auto-generated)",
  "name": "string (required)",
  "description": "string (optional)",
  "price": "number (required)",
  "duration": "number (minutes, required)",
  "category": "string (optional)",
  "img": "string (URL, optional)",
  "isActive": "boolean (default: true)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Reglas de validación:
- `name`: 2-50 caracteres
- `price`: > 0
- `duration`: 15-480 minutos (15min - 8horas)

---

## Colección: `workers`
Información de los trabajadores/profesionales del salón.

### Estructura del documento:
```json
{
  "id": "string (auto-generated)",
  "name": "string (required)",
  "email": "string (optional)",
  "phone": "string (optional)",
  "specialty": "string (optional)",
  "img": "string (URL, optional)",
  "rating": "number (0-5, default: 0)",
  "reviewCount": "number (default: 0)",
  "isActive": "boolean (default: true)",
  "location": {
    "latitude": "number",
    "longitude": "number"
  },
  "locationUpdatedAt": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Reglas de validación:
- `name`: 2-100 caracteres
- `email`: formato válido si proporcionado
- `rating`: 0.0 - 5.0

---

## Colección: `bookings`
Reservas realizadas por los clientes.

### Estructura del documento:
```json
{
  "id": "string (auto-generated)",
  "serviceId": "string (required, reference to services)",
  "serviceName": "string (required)",
  "workerId": "string (required, reference to workers)",
  "workerName": "string (required)",
  "customerId": "string (required, Firebase Auth UID)",
  "customerName": "string (required)",
  "customerPhone": "string (required)",
  "customerEmail": "string (optional)",
  "dateTime": "timestamp (required)",
  "status": "string (enum: confirmed, completed, cancelled, default: confirmed)",
  "notes": "string (optional)",
  "price": "number (required)",
  "duration": "number (minutes, required)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Reglas de validación:
- `dateTime`: debe ser futura
- `status`: solo valores permitidos del enum
- `customerId`: debe existir en Firebase Auth

---

## Colección: `settings`
Configuraciones globales de la aplicación.

### Documento: `salon_location`
```json
{
  "latitude": "number (required)",
  "longitude": "number (required)",
  "address": "string (optional)",
  "updatedAt": "timestamp"
}
```

### Documento: `salon_info`
```json
{
  "name": "string (required)",
  "address": "string (required)",
  "phone": "string (required)",
  "email": "string (required)",
  "hours": "string (required)",
  "updatedAt": "timestamp"
}
```

---

## Reglas de Seguridad de Firestore

### Reglas principales:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Servicios: lectura pública, escritura solo admin
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Trabajadores: lectura pública, escritura solo admin
    match /workers/{workerId} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Reservas: lectura/escritura solo del propietario o admin
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null &&
        (request.auth.uid == resource.data.customerId ||
         request.auth.token.admin == true);
      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.customerId;
    }

    // Configuraciones: lectura pública, escritura solo admin
    match /settings/{settingId} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

### Funciones de validación:
```javascript
function isValidEmail(email) {
  return email.matches('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}');
}

function isValidPhone(phone) {
  return phone.matches('^[+]?[0-9\\s\\-\\(\\)]+$');
}

function isFutureDate(dateTime) {
  return dateTime > request.time;
}

function isValidBookingStatus(status) {
  return status in ['confirmed', 'completed', 'cancelled'];
}
```

---

## Índices de Firestore

### Índices automáticos requeridos:
1. `bookings` - `customerId` (asc), `dateTime` (desc)
2. `bookings` - `workerId` (asc), `dateTime` (asc)
3. `bookings` - `dateTime` (asc)
4. `workers` - `location` (geopoint)

### Índices compuestos recomendados:
```json
{
  "collectionGroup": "bookings",
  "queryScope": "COLLECTION",
  "fields": [
    {
      "fieldPath": "workerId",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "dateTime",
      "order": "ASCENDING"
    }
  ]
}
```

---

## Consideraciones de rendimiento:

1. **Paginación**: Implementar en consultas grandes
2. **Índices**: Crear índices para consultas frecuentes
3. **Caching**: Usar cache local para datos estáticos
4. **Límites**: Establecer límites en consultas para evitar sobrecarga
5. **Monitoreo**: Configurar alertas para uso excesivo

---

## Estrategia de backup:

1. **Backup automático**: Configurar exportaciones programadas
2. **Backup manual**: Antes de cambios críticos
3. **Validación**: Verificar integridad de backups
4. **Recuperación**: Documentar proceso de restauración