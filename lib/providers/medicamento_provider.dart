import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicamento_model.dart';
import '../models/laboratorio_model.dart';
import '../repositories/medicamento_repository.dart';

class MedicamentoProvider extends ChangeNotifier {
  final MedicamentoRepository _repo = MedicamentoRepository();
  final _uuid = const Uuid();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── STREAMS (tiempo real) ────────────────────────────────

  Stream<List<MedicamentoModel>> get medicamentosStream =>
      _repo.getMedicamentosStream();

  Stream<List<MedicamentoModel>> get vencidosStream =>
      _repo.getMedicamentosVencidosStream();

  Stream<List<MedicamentoModel>> get porVencerStream =>
      _repo.getMedicamentosPorVencerStream();

  Stream<List<MedicamentoModel>> get stockBajoStream =>
      _repo.getMedicamentosStockBajoStream();

  Stream<List<MedicamentoModel>> medicamentosStockBajoStream({
    int umbral = 10,
  }) => _repo.getMedicamentosStockBajoStream(umbral: umbral);

  // ─── CRUD ─────────────────────────────────────────────────

  /// Crea un nuevo medicamento calculando la fecha de alerta automáticamente
  Future<bool> agregarMedicamento({
    required String nombre,
    required LaboratorioModel laboratorio,
    required DateTime fechaVencimiento,
    required int cantidad,
  }) async {
    try {
      _setLoading();

      // ⚡ LÓGICA CLAVE: calcular fecha de alerta según el laboratorio
      final fechaAlerta = fechaVencimiento.subtract(
        Duration(days: laboratorio.diasAlerta),
      );

      final medicamento = MedicamentoModel(
        id: _uuid.v4(),  // ID único
        nombre: nombre.trim(),
        laboratorioId: laboratorio.id,
        laboratorioNombre: laboratorio.nombre,
        fechaVencimiento: fechaVencimiento,
        fechaAlerta: fechaAlerta,
        cantidad: cantidad,
        userId: FirebaseAuth.instance.currentUser!.uid,
        alertaEnviada: false,
        creadoEn: DateTime.now(),
        diasAlertaLaboratorio: laboratorio.diasAlerta,
      );

      await _repo.agregarMedicamento(medicamento);
      _clearLoading();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Actualiza medicamento recalculando fecha de alerta si cambió laboratorio
  Future<bool> actualizarMedicamento({
    required MedicamentoModel medicamento,
    required String nombre,
    required LaboratorioModel laboratorio,
    required DateTime fechaVencimiento,
    required int cantidad,
  }) async {
    try {
      _setLoading();

      // Recalcular fecha de alerta con el nuevo laboratorio
      final fechaAlerta = fechaVencimiento.subtract(
        Duration(days: laboratorio.diasAlerta),
      );

      final actualizado = medicamento.copyWith(
        nombre: nombre.trim(),
        laboratorioId: laboratorio.id,
        laboratorioNombre: laboratorio.nombre,
        fechaVencimiento: fechaVencimiento,
        fechaAlerta: fechaAlerta,
        cantidad: cantidad,
        diasAlertaLaboratorio: laboratorio.diasAlerta,
        alertaEnviada: false, // Resetear alerta al editar
      );

      await _repo.actualizarMedicamento(actualizado);
      _clearLoading();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> eliminarMedicamento(String id) async {
    try {
      _setLoading();
      await _repo.eliminarMedicamento(id);
      _clearLoading();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<List<MedicamentoModel>> buscar(String query) async {
    return await _repo.buscarMedicamentos(query);
  }

  void _setLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _clearLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}