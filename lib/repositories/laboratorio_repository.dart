import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/laboratorio_model.dart';

class LaboratorioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Referencia a la colección
  CollectionReference get _collection => 
      _firestore.collection('laboratorios');

  // Obtener todos los laboratorios (stream en tiempo real)
  Stream<List<LaboratorioModel>> getLaboratoriosStream() {
    return _collection
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LaboratorioModel.fromFirestore(doc))
            .toList());
  }

  // Obtener lista una sola vez (para dropdowns)
  Future<List<LaboratorioModel>> getLaboratorios() async {
    final snapshot = await _collection.orderBy('nombre').get();
    return snapshot.docs
        .map((doc) => LaboratorioModel.fromFirestore(doc))
        .toList();
  }

  // Crear laboratorio
  Future<String> crearLaboratorio(LaboratorioModel laboratorio) async {
    final docRef = await _collection.add(laboratorio.toFirestore());
    return docRef.id;
  }

  // Actualizar laboratorio
  Future<void> actualizarLaboratorio(LaboratorioModel laboratorio) async {
    await _collection
        .doc(laboratorio.id)
        .update(laboratorio.toFirestore());
  }

  // Eliminar laboratorio
  Future<void> eliminarLaboratorio(String id) async {
    await _collection.doc(id).delete();
  }

  // Crear laboratorios de ejemplo al iniciar la app (semilla)
  Future<void> seedLaboratorios() async {
    final snapshot = await _collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // Ya existen, no repetir

    final laboratoriosIniciales = [
      {'nombre': 'Laboratorio A', 'diasAlerta': 30, 'contactoEmail': 'alertas@laba.com'},
      {'nombre': 'Laboratorio B', 'diasAlerta': 15, 'contactoEmail': 'alertas@labb.com'},
      {'nombre': 'Laboratorio C', 'diasAlerta': 45, 'contactoEmail': 'alertas@labc.com'},
      {'nombre': 'Pfizer', 'diasAlerta': 60, 'contactoEmail': ''},
      {'nombre': 'Bayer', 'diasAlerta': 30, 'contactoEmail': ''},
      {'nombre': 'Genérico', 'diasAlerta': 20, 'contactoEmail': ''},
    ];

    final batch = _firestore.batch();
    for (final lab in laboratoriosIniciales) {
      final ref = _collection.doc();
      batch.set(ref, {
        ...lab,
        'creadoEn': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}