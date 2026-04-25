import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del usuario actual (reactivo - se actualiza automáticamente)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual sincrónico
  User? get currentUser => _auth.currentUser;

  // Login con email y contraseña
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Registro de nuevo usuario
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String farmacia,
  }) async {
    try {
      // 1. Crear cuenta en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2. Guardar datos adicionales en Firestore
      await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
        'email': email.trim(),
        'nombre': nombre,
        'farmacia': farmacia,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Resetear contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Convertir errores de Firebase a mensajes legibles
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}