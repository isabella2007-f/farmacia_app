import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _umbralStockKey = 'umbral_stock';
  static const String _notificacionesKey = 'notificaciones_activas';
  static const String _nombreFarmaciaKey = 'nombre_farmacia';

  // Singleton
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  // ─── UMBRAL DE STOCK ──────────────────────────────────────

  Future<int> getUmbralStock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_umbralStockKey) ?? 10; // Default: 10
  }

  Future<void> setUmbralStock(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_umbralStockKey, valor);
  }

  // ─── NOTIFICACIONES ───────────────────────────────────────

  Future<bool> getNotificacionesActivas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificacionesKey) ?? true;
  }

  Future<void> setNotificacionesActivas(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificacionesKey, valor);
  }

  // ─── NOMBRE FARMACIA ──────────────────────────────────────

  Future<String> getNombreFarmacia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nombreFarmaciaKey) ?? '';
  }

  Future<void> setNombreFarmacia(String valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nombreFarmaciaKey, valor);
  }

  // Limpiar todo (al cerrar sesión)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}