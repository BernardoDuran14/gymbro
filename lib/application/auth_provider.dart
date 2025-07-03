import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final User? user;
  final String? error;
  final bool isLoading;

  AuthState({this.user, this.error, this.isLoading = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      state = AuthState(isLoading: true);
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      state = AuthState(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message ?? "Error desconocido");
    }
  }

  Future<void> register(String email, String password) async {
    try {
      state = AuthState(isLoading: true);
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      state = AuthState(user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      state = AuthState(error: e.message ?? "Error desconocido");
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
