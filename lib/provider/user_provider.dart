import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  /// Establece el usuario actual y notifica a los listeners
  void setUser(User? newUser) {
    _user = newUser;
    notifyListeners();
  }

  /// Obtiene el usuario actual
  User? getUser() {
    return _user;
  }

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => _user != null;

  /// Obtiene el ID del usuario actual
  String? get userId => _user?.uid;

  /// Obtiene el email del usuario actual
  String? get userEmail => _user?.email;

  /// Obtiene el nombre del usuario actual
  String? get userName => _user?.displayName;

  /// Obtiene la URL de la foto de perfil del usuario
  String? get userPhotoUrl => _user?.photoURL;

  /// Limpia los datos del usuario (para cierre de sesión)
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
