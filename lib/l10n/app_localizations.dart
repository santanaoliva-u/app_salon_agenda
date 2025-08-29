import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Salon App',
      'bookAppointment': 'Book Your Appointment',
      'location': 'Location',
      'settings': 'Settings',
      'apiKey': 'API Key',
      'save': 'Save',
      'cancel': 'Cancel',
      'configure': 'Configure',
      'limitedMode': 'Limited Mode',
      'getDirections': 'Get Directions',
      'contactInfo': 'Contact Information',
      'businessHours': 'Business Hours',
      'availableSlots': 'Available Slots',
      'selectServices': 'Select Services',
      'bookAppointmentButton': 'Book an appointment',
      'apiRequired': 'API key required for this feature',
      'configureApiKey': 'Configure API Key',
      'googleMaps': 'Google Maps',
      'firebase': 'Firebase',
      'configured': 'Configured',
      'notConfigured': 'Not configured',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'resetSettings': 'Reset Settings',
      'resetConfirmation': 'Reset all settings to default values?',
      'apiKeySaved': 'API Key saved successfully',
      'apiKeyError': 'Error saving API Key',
      'firebaseEnabled': 'Firebase enabled',
      'firebaseDisabled': 'Firebase disabled',
      'restartRequired': 'Restart required to apply changes',
    },
    'es': {
      'appTitle': 'App de Salón',
      'bookAppointment': 'Reserva tu Cita',
      'location': 'Ubicación',
      'settings': 'Configuración',
      'apiKey': 'Clave de API',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'configure': 'Configurar',
      'limitedMode': 'Modo Limitado',
      'getDirections': 'Obtener Direcciones',
      'contactInfo': 'Información de Contacto',
      'businessHours': 'Horarios de Atención',
      'availableSlots': 'Horarios Disponibles',
      'selectServices': 'Seleccionar Servicios',
      'bookAppointmentButton': 'Reservar cita',
      'apiRequired': 'Se requiere clave de API para esta función',
      'configureApiKey': 'Configurar Clave de API',
      'googleMaps': 'Google Maps',
      'firebase': 'Firebase',
      'configured': 'Configurado',
      'notConfigured': 'No configurado',
      'enabled': 'Habilitado',
      'disabled': 'Deshabilitado',
      'resetSettings': 'Restablecer Configuración',
      'resetConfirmation':
          '¿Restablecer todas las configuraciones a valores predeterminados?',
      'apiKeySaved': 'Clave de API guardada correctamente',
      'apiKeyError': 'Error al guardar la clave de API',
      'firebaseEnabled': 'Firebase habilitado',
      'firebaseDisabled': 'Firebase deshabilitado',
      'restartRequired': 'Se requiere reiniciar para aplicar los cambios',
    },
  };

  String get appTitle =>
      _localizedValues[locale.languageCode]?['appTitle'] ?? 'Salon App';
  String get bookAppointment =>
      _localizedValues[locale.languageCode]?['bookAppointment'] ??
      'Book Your Appointment';
  String get location =>
      _localizedValues[locale.languageCode]?['location'] ?? 'Location';
  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get apiKey =>
      _localizedValues[locale.languageCode]?['apiKey'] ?? 'API Key';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get cancel =>
      _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get configure =>
      _localizedValues[locale.languageCode]?['configure'] ?? 'Configure';
  String get limitedMode =>
      _localizedValues[locale.languageCode]?['limitedMode'] ?? 'Limited Mode';
  String get getDirections =>
      _localizedValues[locale.languageCode]?['getDirections'] ??
      'Get Directions';
  String get contactInfo =>
      _localizedValues[locale.languageCode]?['contactInfo'] ??
      'Contact Information';
  String get businessHours =>
      _localizedValues[locale.languageCode]?['businessHours'] ??
      'Business Hours';
  String get availableSlots =>
      _localizedValues[locale.languageCode]?['availableSlots'] ??
      'Available Slots';
  String get selectServices =>
      _localizedValues[locale.languageCode]?['selectServices'] ??
      'Select Services';
  String get bookAppointmentButton =>
      _localizedValues[locale.languageCode]?['bookAppointmentButton'] ??
      'Book an appointment';
  String get apiRequired =>
      _localizedValues[locale.languageCode]?['apiRequired'] ??
      'API key required for this feature';
  String get configureApiKey =>
      _localizedValues[locale.languageCode]?['configureApiKey'] ??
      'Configure API Key';
  String get googleMaps =>
      _localizedValues[locale.languageCode]?['googleMaps'] ?? 'Google Maps';
  String get firebase =>
      _localizedValues[locale.languageCode]?['firebase'] ?? 'Firebase';
  String get configured =>
      _localizedValues[locale.languageCode]?['configured'] ?? 'Configured';
  String get notConfigured =>
      _localizedValues[locale.languageCode]?['notConfigured'] ??
      'Not configured';
  String get enabled =>
      _localizedValues[locale.languageCode]?['enabled'] ?? 'Enabled';
  String get disabled =>
      _localizedValues[locale.languageCode]?['disabled'] ?? 'Disabled';
  String get resetSettings =>
      _localizedValues[locale.languageCode]?['resetSettings'] ??
      'Reset Settings';
  String get resetConfirmation =>
      _localizedValues[locale.languageCode]?['resetConfirmation'] ??
      'Reset all settings to default values?';
  String get apiKeySaved =>
      _localizedValues[locale.languageCode]?['apiKeySaved'] ??
      'API Key saved successfully';
  String get apiKeyError =>
      _localizedValues[locale.languageCode]?['apiKeyError'] ??
      'Error saving API Key';
  String get firebaseEnabled =>
      _localizedValues[locale.languageCode]?['firebaseEnabled'] ??
      'Firebase enabled';
  String get firebaseDisabled =>
      _localizedValues[locale.languageCode]?['firebaseDisabled'] ??
      'Firebase disabled';
  String get restartRequired =>
      _localizedValues[locale.languageCode]?['restartRequired'] ??
      'Restart required to apply changes';

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
