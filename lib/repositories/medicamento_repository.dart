import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicamento_model.dart';

class MedicamentoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // UID del usuario actual
  String get _userId => _auth.currentUser!.uid;

  // Referencia a la colección filtrada por usuario
  Query get _userMedicamentos => _firestore
      .collection('medicamentos')
      .where('userId', isEqualTo: _userId);

  // ─── CREATE ───────────────────────────────────────────────

  Future<void> agregarMedicamento(MedicamentoModel medicamento) async {
    await _firestore
        .collection('medicamentos')
        .doc(medicamento.id)
        .set(medicamento.toFirestore());
  }

  // ─── READ ─────────────────────────────────────────────────

  // Stream de todos los medicamentos del usuario (tiempo real)
  Stream<List<MedicamentoModel>> getMedicamentosStream() {
    return _userMedicamentos
        .orderBy('fechaVencimiento')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicamentoModel.fromFirestore(doc))
            .toList());
  }

  // Solo medicamentos vencidos
  Stream<List<MedicamentoModel>> getMedicamentosVencidosStream() {
    return _userMedicamentos
        .where('fechaVencimiento',
            isLessThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicamentoModel.fromFirestore(doc))
            .toList());
  }

  // Medicamentos dentro del período de alerta
  Stream<List<MedicamentoModel>> getMedicamentosPorVencerStream() {
    final now = DateTime.now();
    return _userMedicamentos
        .where('fechaAlerta', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('fechaVencimiento',
            isGreaterThan: Timestamp.fromDate(now))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicamentoModel.fromFirestore(doc))
            .toList());
  }

  // Stock bajo (menos de 10 unidades - ajustable)
  Stream<List<MedicamentoModel>> getMedicamentosStockBajoStream({
    int umbral = 10,
  }) {
    return _userMedicamentos
        .where('cantidad', isLessThanOrEqualTo: umbral)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicamentoModel.fromFirestore(doc))
            .toList());
  }

  // ─── UPDATE ───────────────────────────────────────────────

  Future<void> actualizarMedicamento(MedicamentoModel medicamento) async {
    await _firestore
        .collection('medicamentos')
        .doc(medicamento.id)
        .update(medicamento.toFirestore());
  }

  // ─── DELETE ───────────────────────────────────────────────

  Future<void> eliminarMedicamento(String id) async {
    await _firestore.collection('medicamentos').doc(id).delete();
  }

  // Búsqueda local (Firestore no soporta búsqueda de texto completo nativamente)
  Future<List<MedicamentoModel>> buscarMedicamentos(String query) async {
    final snapshot = await _userMedicamentos.get();
    final todos = snapshot.docs
        .map((doc) => MedicamentoModel.fromFirestore(doc))
        .toList();
    
    // Filtrar localmente (para apps pequeñas es suficiente)
    final queryLower = query.toLowerCase();
    return todos.where((med) {
      return med.nombre.toLowerCase().contains(queryLower) ||
          med.laboratorioNombre.toLowerCase().contains(queryLower);
    }).toList();
  }
}