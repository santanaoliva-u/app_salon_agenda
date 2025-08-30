import 'dart:ui';
import 'app_localizations.dart';

/// The translations for Spanish (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([super.locale = const Locale('es')]);

  @override
  String get appTitle => 'Aplicación de Reservas de Salón';

  String get home => 'Inicio';

  String get booking => 'Reservas';

  String get maps => 'Mapas';

  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

  @override
  String get bookAppointment => 'Reservar Cita';

  String get selectService => 'Seleccionar Servicio';

  String get selectDate => 'Seleccionar Fecha';

  String get selectTime => 'Seleccionar Hora';

  String get customerName => 'Nombre del Cliente';

  String get customerPhone => 'Número de Teléfono';

  String get customerEmail => 'Correo Electrónico (Opcional)';

  String get notes => 'Notas (Opcional)';

  String get confirmBooking => 'Confirmar Reserva';

  String get bookingSuccess => '¡Reserva confirmada exitosamente!';

  String get bookingError =>
      'Error al crear la reserva. Por favor inténtalo de nuevo.';

  String get loading => 'Cargando...';

  String get error => 'Error';

  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  String get ok => 'Aceptar';

  @override
  String get save => 'Guardar';

  String get delete => 'Eliminar';

  String get edit => 'Editar';

  String get search => 'Buscar';

  String get filter => 'Filtrar';

  String get sort => 'Ordenar';

  @override
  String get location => 'Ubicación';

  String get address => 'Dirección';

  String get phone => 'Teléfono';

  String get email => 'Correo';

  String get website => 'Sitio Web';

  String get about => 'Acerca de';

  String get contact => 'Contacto';

  String get services => 'Servicios';

  String get workers => 'Trabajadores';

  String get appointments => 'Citas';

  String get history => 'Historial';

  String get upcoming => 'Próximas';

  String get completed => 'Completadas';

  String get cancelled => 'Canceladas';

  String get pending => 'Pendientes';

  String get confirmed => 'Confirmadas';

  String get available => 'Disponible';

  String get unavailable => 'No Disponible';

  String get distance => 'Distancia';

  String get duration => 'Duración';

  String get price => 'Precio';

  String get total => 'Total';

  String get tax => 'Impuestos';

  String get discount => 'Descuento';

  String get payment => 'Pago';

  String get payNow => 'Pagar Ahora';

  String get payLater => 'Pagar Después';

  String get online => 'En Línea';

  String get offline => 'Sin Conexión';

  String get connected => 'Conectado';

  String get disconnected => 'Desconectado';

  String get noInternet => 'Sin Conexión a Internet';

  String get checkConnection =>
      'Por favor verifica tu conexión a internet e inténtalo de nuevo.';

  String get tryAgain => 'Intentar de Nuevo';

  String get goBack => 'Regresar';

  String get continue_ => 'Continuar';

  String get skip => 'Omitir';

  String get next => 'Siguiente';

  String get previous => 'Anterior';

  String get finish => 'Finalizar';

  String get done => 'Hecho';

  String get close => 'Cerrar';

  String get open => 'Abrir';

  String get closed => 'Cerrado';

  String get openingHours => 'Horarios de Apertura';

  String get monday => 'Lunes';

  String get tuesday => 'Martes';

  String get wednesday => 'Miércoles';

  String get thursday => 'Jueves';

  String get friday => 'Viernes';

  String get saturday => 'Sábado';

  String get sunday => 'Domingo';

  String get today => 'Hoy';

  String get tomorrow => 'Mañana';

  String get yesterday => 'Ayer';

  String get dateFormat => 'dd/MM/yyyy';

  String get timeFormat => 'HH:mm';

  String get currencySymbol => '€';

  String get currencyFormat => '#,##0.00€';

  String get language => 'Idioma';

  String get english => 'Inglés';

  String get spanish => 'Español';

  String get theme => 'Tema';

  String get light => 'Claro';

  String get dark => 'Oscuro';

  String get system => 'Sistema';

  String get notifications => 'Notificaciones';

  String get enableNotifications => 'Habilitar Notificaciones';

  String get reminderHours => 'Horas de Recordatorio';

  String get privacy => 'Privacidad';

  String get terms => 'Términos de Servicio';

  String get policy => 'Política de Privacidad';

  String get help => 'Ayuda';

  String get support => 'Soporte';

  String get feedback => 'Comentarios';

  String get rateApp => 'Calificar App';

  String get shareApp => 'Compartir App';

  String get logout => 'Cerrar Sesión';

  String get login => 'Iniciar Sesión';

  String get register => 'Registrarse';

  String get forgotPassword => '¿Olvidaste tu Contraseña?';

  String get resetPassword => 'Restablecer Contraseña';

  String get changePassword => 'Cambiar Contraseña';

  String get currentPassword => 'Contraseña Actual';

  String get newPassword => 'Nueva Contraseña';

  String get confirmPassword => 'Confirmar Contraseña';

  String get passwordMismatch => 'Las contraseñas no coinciden';

  String get invalidEmail => 'Dirección de correo inválida';

  String get invalidPhone => 'Número de teléfono inválido';

  String get fieldRequired => 'Este campo es obligatorio';

  String get minLength => 'Longitud mínima de {count} caracteres';

  String get maxLength => 'Longitud máxima de {count} caracteres';

  String get invalidFormat => 'Formato inválido';

  String get networkError => 'Error de red. Por favor verifica tu conexión.';

  String get serverError =>
      'Error del servidor. Por favor inténtalo más tarde.';

  String get unknownError =>
      'Ocurrió un error desconocido. Por favor inténtalo de nuevo.';

  String get permissionDenied => 'Permiso denegado';

  String get locationPermissionRequired =>
      'Se requiere permiso de ubicación para mostrar servicios cercanos';

  String get cameraPermissionRequired =>
      'Se requiere permiso de cámara para tomar fotos';

  String get storagePermissionRequired =>
      'Se requiere permiso de almacenamiento para guardar archivos';

  String get notificationPermissionRequired =>
      'Se requiere permiso de notificaciones para enviar recordatorios';

  String get enableLocation => 'Habilitar Ubicación';

  String get enableCamera => 'Habilitar Cámara';

  String get enableStorage => 'Habilitar Almacenamiento';

  String get enableNotifications_ => 'Habilitar Notificaciones';

  String get goToSettings => 'Ir a Configuración';

  String get later => 'Después';

  String get allow => 'Permitir';

  String get deny => 'Denegar';

  String get bookingReminder => 'Recordatorio de Cita';

  String get bookingReminderMessage => 'Tienes una cita en {hours} horas';

  String get bookingConfirmed => 'Reserva Confirmada';

  String get bookingConfirmedMessage =>
      'Tu cita ha sido confirmada para {date} a las {time}';

  String get bookingCancelled => 'Reserva Cancelada';

  String get bookingCancelledMessage =>
      'Tu cita para {date} a las {time} ha sido cancelada';

  String get bookingUpdated => 'Reserva Actualizada';

  String get bookingUpdatedMessage => 'Tu cita ha sido actualizada';

  String get welcome => 'Bienvenido';

  String get welcomeMessage =>
      'Bienvenido a nuestra aplicación de reservas de salón';

  String get getStarted => 'Comenzar';

  String get onboardingTitle1 => 'Encuentra el Servicio Perfecto';

  String get onboardingDesc1 =>
      'Explora nuestra amplia gama de servicios de belleza';

  String get onboardingTitle2 => 'Reserva con Facilidad';

  String get onboardingDesc2 => 'Programa citas a tu conveniencia';

  String get onboardingTitle3 => 'Rastrea tus Citas';

  String get onboardingDesc3 =>
      'Mantén un registro de todas tus citas próximas y pasadas';

  String get noBookings => 'No se encontraron reservas';

  String get noBookingsDesc =>
      'Aún no has hecho ninguna reserva. ¡Comienza reservando un servicio!';

  String get noServices => 'No hay servicios disponibles';

  String get noServicesDesc =>
      'No hay servicios disponibles actualmente. Por favor inténtalo de nuevo más tarde.';

  String get noWorkers => 'No hay trabajadores disponibles';

  String get noWorkersDesc =>
      'No hay trabajadores disponibles actualmente. Por favor inténtalo de nuevo más tarde.';

  String get serviceUnavailable => 'Servicio No Disponible';

  String get serviceUnavailableDesc =>
      'Este servicio no está disponible actualmente. Por favor elige otro servicio.';

  String get workerUnavailable => 'Trabajador No Disponible';

  String get workerUnavailableDesc =>
      'Este trabajador no está disponible actualmente. Por favor elige otro trabajador.';

  String get timeSlotUnavailable => 'Horario No Disponible';

  String get timeSlotUnavailableDesc =>
      'Este horario ya no está disponible. Por favor elige otra hora.';

  String get bookingConflict => 'Conflicto de Reserva';

  String get bookingConflictDesc =>
      'Hay un conflicto con tu reserva. Por favor elige una hora o servicio diferente.';

  String get bookingLimitReached => 'Límite de Reservas Alcanzado';

  String get bookingLimitReachedDesc =>
      'Has alcanzado el número máximo de reservas permitidas.';

  String get accountSuspended => 'Cuenta Suspendida';

  String get accountSuspendedDesc =>
      'Tu cuenta ha sido suspendida. Por favor contacta al soporte.';

  String get maintenance => 'Mantenimiento';

  String get maintenanceDesc =>
      'La aplicación está actualmente en mantenimiento. Por favor inténtalo de nuevo más tarde.';

  String get updateRequired => 'Actualización Requerida';

  String get updateRequiredDesc =>
      'Por favor actualiza la aplicación para continuar usándola.';

  String get updateNow => 'Actualizar Ahora';

  String get updateAvailable => 'Actualización Disponible';

  String get updateAvailableDesc =>
      'Hay una nueva versión de la aplicación disponible. ¿Te gustaría actualizarla?';

  String get whatsNew => '¿Qué hay de Nuevo?';

  String get version => 'Versión';

  String get build => 'Compilación';

  String get releaseDate => 'Fecha de Lanzamiento';

  String get changelog => 'Registro de Cambios';

  String get bugFixes => 'Correcciones de Errores';

  String get improvements => 'Mejoras';

  String get newFeatures => 'Nuevas Funcionalidades';

  String get experimental => 'Experimental';

  String get beta => 'Beta';

  String get stable => 'Estable';

  String get development => 'Desarrollo';

  String get production => 'Producción';

  String get debug => 'Depuración';

  String get info => 'Información';

  String get warning => 'Advertencia';

  String get critical => 'Crítico';

  String get error_ => 'Error';

  String get success => 'Éxito';

  String get failure => 'Fallo';

  String get pending_ => 'Pendiente';

  String get processing => 'Procesando';

  String get completed_ => 'Completado';

  String get failed => 'Fallido';

  String get cancelled_ => 'Cancelado';

  String get expired => 'Expirado';

  String get active => 'Activo';

  String get inactive => 'Inactivo';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Deshabilitado';

  String get on => 'Encendido';

  String get off => 'Apagado';

  String get yes => 'Sí';

  String get no => 'No';

  String get true_ => 'Verdadero';

  String get false_ => 'Falso';

  String get none => 'Ninguno';

  String get all => 'Todos';

  String get any => 'Cualquiera';

  String get other => 'Otro';

  String get custom => 'Personalizado';

  String get default_ => 'Predeterminado';

  String get automatic => 'Automático';

  String get manual => 'Manual';

  String get advanced => 'Avanzado';

  String get basic => 'Básico';

  String get simple => 'Simple';

  String get complex => 'Complejo';

  String get easy => 'Fácil';

  String get hard => 'Difícil';

  String get fast => 'Rápido';

  String get slow => 'Lento';

  String get small => 'Pequeño';

  String get medium => 'Mediano';

  String get large => 'Grande';

  String get short => 'Corto';

  String get long => 'Largo';

  String get high => 'Alto';

  String get low => 'Bajo';

  String get normal => 'Normal';

  String get priority => 'Prioridad';

  String get urgent => 'Urgente';

  String get important => 'Importante';

  String get optional => 'Opcional';

  String get required => 'Requerido';

  String get recommended => 'Recomendado';

  String get suggested => 'Sugerido';

  String get popular => 'Popular';

  String get trending => 'Tendencia';

  String get featured => 'Destacado';

  String get new_ => 'Nuevo';

  String get hot => 'Caliente';

  String get cool => 'Genial';

  String get warm => 'Cálido';

  String get cold => 'Frío';

  String get fresh => 'Fresco';

  String get old => 'Viejo';

  String get recent => 'Reciente';

  String get latest => 'Último';

  String get oldest => 'Más Antiguo';

  String get first => 'Primero';

  String get last => 'Último';

  String get next_ => 'Siguiente';

  String get previous_ => 'Anterior';

  String get current => 'Actual';

  String get future => 'Futuro';

  String get past => 'Pasado';

  String get now => 'Ahora';

  String get soon => 'Pronto';

  String get later_ => 'Después';

  String get ago => 'atrás';

  String get fromNow => 'desde ahora';

  String get justNow => 'ahora mismo';

  String get seconds => 'segundos';

  String get minutes => 'minutos';

  String get hours => 'horas';

  String get days => 'días';

  String get weeks => 'semanas';

  String get months => 'meses';

  String get years => 'años';

  String get second => 'segundo';

  String get minute => 'minuto';

  String get hour => 'hora';

  String get day => 'día';

  String get week => 'semana';

  String get month => 'mes';

  String get year => 'año';

  String plural(String word, int count) {
    if (count == 1) return word;
    // En español, la mayoría de las palabras pluralizan agregando 's' o 'es'
    if (word.endsWith('ión')) {
      return '${word.substring(0, word.length - 3)}iones';
    }
    if (word.endsWith('dad') || word.endsWith('tad') || word.endsWith('tud')) {
      return '${word}es';
    }
    if (word.endsWith('s') || word.endsWith('x') || word.endsWith('z')) {
      return '${word}es';
    }
    return '${word}s';
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'hace $years ${plural('año', years)}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months ${plural('mes', months)}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace $weeks ${plural('semana', weeks)}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} ${plural('día', difference.inDays)}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} ${plural('hora', difference.inHours)}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} ${plural('minuto', difference.inMinutes)}';
    } else {
      return justNow;
    }
  }

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)}€';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${plural('día', duration.inDays)} ${duration.inHours % 24} ${plural('hora', duration.inHours % 24)}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${plural('hora', duration.inHours)} ${duration.inMinutes % 60} ${plural('minuto', duration.inMinutes % 60)}';
    } else {
      return '${duration.inMinutes} ${plural('minuto', duration.inMinutes)} ${duration.inSeconds % 60} ${plural('segundo', duration.inSeconds % 60)}';
    }
  }
}
