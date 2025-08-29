import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class Authentication {
  static final Logger _logger = Logger();

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();

        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
        _logger.i('Inicio de sesión exitoso en web: ${user?.email}');
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();

        // Verificar si ya hay un usuario firmado
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }

        final GoogleSignInAccount? googleSignInAccount =
            await googleSignIn.signIn();

        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
          _logger.i('Inicio de sesión exitoso en móvil: ${user?.email}');
        } else {
          _logger.w('Inicio de sesión cancelado por el usuario');
          return null;
        }
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Error de autenticación: ${e.code} - ${e.message}');
      // Note: UI feedback should be handled by the calling code
      rethrow; // Re-throw to let calling code handle UI
    } catch (e) {
      _logger.e('Error inesperado en inicio de sesión: $e');
      // Note: UI feedback should be handled by the calling code
      rethrow; // Re-throw to let calling code handle UI
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      _logger.i('Cierre de sesión exitoso');
    } catch (e) {
      _logger.e('Error al cerrar sesión: $e');
      // Note: UI feedback should be handled by the calling code
      rethrow; // Re-throw to let calling code handle UI
    }
  }
}
