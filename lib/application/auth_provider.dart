import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final User? user;
  final String? error;
  final bool isLoading;

  AuthState({this.user, this.error, this.isLoading = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  Timer? _errorTimer;
  AuthNotifier() : super(AuthState());

  void _clearErrorAfterDelay() {
    _errorTimer?.cancel(); // Cancela el timer existente

    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        state = AuthState(
          user: state.user,
          isLoading: state.isLoading,
        ); // Mantén otros estados pero limpia el error
      }
    });
  }

  @override
  void dispose() {
    _errorTimer?.cancel(); // Importante: limpia el timer al destruir
    super.dispose();
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        // Autenticación con email/contraseña
        case 'invalid-email':
          return 'El formato del correo es inválido';
        case 'user-disabled':
          return 'Esta cuenta ha sido desactivada';
        case 'user-not-found':
          return 'No existe cuenta con este correo';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este correo ya está registrado';
        case 'operation-not-allowed':
          return 'Método de autenticación no permitido';
        case 'weak-password':
          return 'La contraseña debe tener al menos 6 caracteres';
        case 'too-many-requests':
          return 'Demasiados intentos. Bloqueado temporalmente';

        // Errores de red/operación
        case 'network-request-failed':
          return 'Error de conexión a internet';
        case 'requires-recent-login':
          return 'Debes volver a iniciar sesión';
        case 'quota-exceeded':
          return 'Límite de operaciones excedido';

        // Errores menos comunes pero importantes
        case 'keychain-error':
          return 'Error en el almacenamiento seguro (iOS)';
        case 'internal-error':
          return 'Error interno del sistema';
        case 'invalid-credential':
          return 'Credenciales inválidas o expiradas';
        case 'invalid-verification-code':
          return 'Código de verificación inválido';
        case 'invalid-verification-id':
          return 'ID de verificación inválido';

        default:
          if (kDebugMode) {
            return 'Error técnico (${error.code}): ${error.message}';
          }
          return 'Error inesperado. Por favor intenta nuevamente';
      }
    } else if (error is FirebaseException) {
      return 'Error de Firebase: ${error.message}';
    } else if (error is PlatformException) {
      return 'Error del dispositivo: ${error.message}';
    } else if (error is TimeoutException) {
      return 'Tiempo de espera agotado';
    } else if (error is SocketException) {
      return 'Sin conexión a internet';
    } else {
      if (kDebugMode) {
        return 'Error no controlado: ${error.toString()}';
      }
      return 'Ocurrió un error inesperado';
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = AuthState(isLoading: true);
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      state = AuthState(user: userCredential.user);
    } catch (error) {
      state = AuthState(error: _getAuthErrorMessage(error), isLoading: false);
      _clearErrorAfterDelay(); // Inicia el temporizador
    }
  }

  Future<void> register(String email, String password) async {
    try {
      state = AuthState(isLoading: true);
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      state = AuthState(user: userCredential.user);
    } catch (error) {
      state = AuthState(error: _getAuthErrorMessage(error));
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
