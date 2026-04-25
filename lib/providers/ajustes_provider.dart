import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class AjustesProvider extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();

  int _umbralStock = 10;
  bool _notificacionesActivas = true;
  String _nombreFarmacia = '';
  bool _isLoading = false;

  int get umbralStock => _umbralStock;
  bool get notificacionesActivas => _notificacionesActivas;
  String get nombreFarmacia => _nombreFarmacia;
  bool get isLoading => _isLoading;

  // Cargar preferencias al iniciar
  Future<void> cargarPreferencias() async {
    _isLoading = true;
    notifyListeners();

    _umbralStock = await _prefs.getUmbralStock();
    _notificacionesActivas = await _prefs.getNotificacionesActivas();
    _nombreFarmacia = await _prefs.getNombreFarmacia();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUmbralStock(int valor) async {
    _umbralStock = valor;
    await _prefs.setUmbralStock(valor);
    notifyListeners();
  }

  Future<void> setNotificaciones(bool valor) async {
    _notificacionesActivas = valor;
    await _prefs.setNotificacionesActivas(valor);
    notifyListeners();
  }

  Future<void> setNombreFarmacia(String valor) async {
    _nombreFarmacia = valor;
    await _prefs.setNombreFarmacia(valor);
    notifyListeners();
  }
}