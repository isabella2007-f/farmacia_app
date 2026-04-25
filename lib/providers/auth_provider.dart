import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/laboratorio_repository.dart';
import '../services/notification_service.dart';

// Estados posibles de autenticación
enum AuthStatus { inicial, autenticado, noAutenticado, cargando }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final LaboratorioRepository _labRepo = LaboratorioRepository();

  AuthStatus _status = AuthStatus.inicial;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.autenticado;
  bool get isLoading => _status == AuthStatus.cargando;

  AuthProvider() {
    // Escuchar cambios de autenticación automáticamente
    _authRepo.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _status = AuthStatus.autenticado;
        // Inicializar laboratorios de ejemplo si es la primera vez
        await _labRepo.seedLaboratorios();
      } else {
        _status = AuthStatus.noAutenticado;
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading();
      final credential = await _authRepo.loginWithEmail(email: email, password: password);
      if (credential.user != null) {
        await NotificationService().guardarTokenEnServidor();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String farmacia,
  }) async {
    try {
      _setLoading();
      await _authRepo.registerWithEmail(
        email: email,
        password: password,
        nombre: nombre,
        farmacia: farmacia,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authRepo.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading() {
    _status = AuthStatus.cargando;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.noAutenticado;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

}