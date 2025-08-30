import 'package:logger/logger.dart';

/// Service for comprehensive form validation across the application
class ValidationService {
  static final Logger _logger = Logger();

  // =============================================================================
  // VALIDATION RULES
  // =============================================================================

  /// Validate email format
  static String? validateEmail(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'El email es requerido' : null;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Formato de email inválido';
    }

    return null;
  }

  /// Validate phone number format
  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'El teléfono es requerido' : null;
    }

    // Remove all non-digit characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }

    if (cleanPhone.length > 15) {
      return 'El teléfono no puede tener más de 15 dígitos';
    }

    // Check if it starts with country code or local number
    if (!cleanPhone.startsWith('52') && cleanPhone.length == 10) {
      // Mexican local number
      return null;
    } else if (cleanPhone.startsWith('52') && cleanPhone.length == 12) {
      // Mexican international format
      return null;
    } else if (cleanPhone.startsWith('1') && cleanPhone.length == 11) {
      // US format
      return null;
    }

    return 'Formato de teléfono inválido';
  }

  /// Validate name format
  static String? validateName(String? value,
      {bool required = true, int minLength = 2, int maxLength = 50}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'El nombre es requerido' : null;
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < minLength) {
      return 'El nombre debe tener al menos $minLength caracteres';
    }

    if (trimmedValue.length > maxLength) {
      return 'El nombre no puede tener más de $maxLength caracteres';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\u00f1\u00d1\s\-']+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'El nombre solo puede contener letras, espacios, guiones y apóstrofes';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value,
      {bool required = true, int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return required ? 'La contraseña es requerida' : null;
    }

    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un número';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un carácter especial';
    }

    return null;
  }

  /// Validate date/time is in the future
  static String? validateFutureDateTime(DateTime? value,
      {bool required = true}) {
    if (value == null) {
      return required ? 'La fecha y hora son requeridas' : null;
    }

    final now = DateTime.now();
    if (value.isBefore(now)) {
      return 'La fecha y hora deben ser en el futuro';
    }

    // Check if it's at least 2 hours in the future
    final minFutureTime = now.add(const Duration(hours: 2));
    if (value.isBefore(minFutureTime)) {
      return 'Las reservas deben hacerse con al menos 2 horas de anticipación';
    }

    return null;
  }

  /// Validate date is not in the past
  static String? validateFutureDate(DateTime? value, {bool required = true}) {
    if (value == null) {
      return required ? 'La fecha es requerida' : null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (value.isBefore(today)) {
      return 'La fecha no puede ser en el pasado';
    }

    return null;
  }

  /// Validate text length
  static String? validateTextLength(String? value,
      {bool required = true,
      int? minLength,
      int? maxLength,
      String? fieldName = 'campo'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'El $fieldName es requerido' : null;
    }

    final trimmedValue = value.trim();

    if (minLength != null && trimmedValue.length < minLength) {
      return 'El $fieldName debe tener al menos $minLength caracteres';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return 'El $fieldName no puede tener más de $maxLength caracteres';
    }

    return null;
  }

  /// Validate numeric value within range
  static String? validateNumeric(String? value,
      {bool required = true, num? min, num? max, String? fieldName = 'valor'}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'El $fieldName es requerido' : null;
    }

    final numericValue = num.tryParse(value.trim());
    if (numericValue == null) {
      return 'El $fieldName debe ser un número válido';
    }

    if (min != null && numericValue < min) {
      return 'El $fieldName debe ser mayor o igual a $min';
    }

    if (max != null && numericValue > max) {
      return 'El $fieldName debe ser menor o igual a $max';
    }

    return null;
  }

  /// Validate URL format
  static String? validateUrl(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'La URL es requerida' : null;
    }

    final urlRegex = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Formato de URL inválido';
    }

    return null;
  }

  // =============================================================================
  // COMPLEX VALIDATION METHODS
  // =============================================================================

  /// Validate complete booking data
  static Map<String, String?> validateBookingData({
    required String serviceId,
    required String workerId,
    required DateTime dateTime,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? notes,
  }) {
    final errors = <String, String?>{};

    // Validate service
    if (serviceId.isEmpty) {
      errors['service'] = 'Debe seleccionar un servicio';
    }

    // Validate worker
    if (workerId.isEmpty) {
      errors['worker'] = 'Debe seleccionar un trabajador';
    }

    // Validate date/time
    final dateTimeError = validateFutureDateTime(dateTime);
    if (dateTimeError != null) {
      errors['dateTime'] = dateTimeError;
    }

    // Validate customer name
    final nameError = validateName(customerName);
    if (nameError != null) {
      errors['customerName'] = nameError;
    }

    // Validate customer phone
    final phoneError = validatePhone(customerPhone);
    if (phoneError != null) {
      errors['customerPhone'] = phoneError;
    }

    // Validate customer email (if provided)
    if (customerEmail != null && customerEmail.isNotEmpty) {
      final emailError = validateEmail(customerEmail, required: false);
      if (emailError != null) {
        errors['customerEmail'] = emailError;
      }
    }

    // Validate notes length (if provided)
    if (notes != null && notes.isNotEmpty) {
      final notesError = validateTextLength(notes,
          required: false, maxLength: 500, fieldName: 'notas');
      if (notesError != null) {
        errors['notes'] = notesError;
      }
    }

    return errors;
  }

  /// Validate user profile data
  static Map<String, String?> validateUserProfile({
    required String name,
    required String email,
    required String phone,
    String? bio,
    String? website,
  }) {
    final errors = <String, String?>{};

    // Validate name
    final nameError = validateName(name);
    if (nameError != null) {
      errors['name'] = nameError;
    }

    // Validate email
    final emailError = validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    // Validate phone
    final phoneError = validatePhone(phone);
    if (phoneError != null) {
      errors['phone'] = phoneError;
    }

    // Validate bio (if provided)
    if (bio != null && bio.isNotEmpty) {
      final bioError = validateTextLength(bio,
          required: false, maxLength: 300, fieldName: 'biografía');
      if (bioError != null) {
        errors['bio'] = bioError;
      }
    }

    // Validate website (if provided)
    if (website != null && website.isNotEmpty) {
      final websiteError = validateUrl(website, required: false);
      if (websiteError != null) {
        errors['website'] = websiteError;
      }
    }

    return errors;
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if a map of errors has any validation errors
  static bool hasErrors(Map<String, String?> errors) {
    return errors.values.any((error) => error != null && error.isNotEmpty);
  }

  /// Get the first error message from a map of errors
  static String? getFirstError(Map<String, String?> errors) {
    for (final error in errors.values) {
      if (error != null && error.isNotEmpty) {
        return error;
      }
    }
    return null;
  }

  /// Log validation errors for debugging
  static void logValidationErrors(String context, Map<String, String?> errors) {
    if (hasErrors(errors)) {
      _logger.w('Validation errors in $context:');
      errors.forEach((field, error) {
        if (error != null && error.isNotEmpty) {
          _logger.w('  $field: $error');
        }
      });
    }
  }

  /// Sanitize user input to prevent XSS and other attacks
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .replaceAll('"', '"')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&')
        .trim();
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.startsWith('52') && cleanPhone.length == 12) {
      // Mexican international format: +52 XX XXXX XXXX
      return '+${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 4)} ${cleanPhone.substring(4, 8)} ${cleanPhone.substring(8)}';
    } else if (cleanPhone.length == 10) {
      // Mexican local format: (XXX) XXX XXXX
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    } else if (cleanPhone.startsWith('1') && cleanPhone.length == 11) {
      // US format: +1 (XXX) XXX XXXX
      return '+${cleanPhone[0]} (${cleanPhone.substring(1, 4)}) ${cleanPhone.substring(4, 7)} ${cleanPhone.substring(7)}';
    }

    return phone; // Return original if format not recognized
  }
}

/// Singleton instance
final validationService = ValidationService();
