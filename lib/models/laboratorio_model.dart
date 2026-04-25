import 'package:cloud_firestore/cloud_firestore.dart';

class LaboratorioModel {
  final String id;
  final String nombre;
  final int diasAlerta;         // Días previos al vencimiento para alertar
  final String contactoEmail;   // Email del laboratorio (opcional)
  final DateTime creadoEn;

  LaboratorioModel({
    required this.id,
    required this.nombre,
    required this.diasAlerta,
    required this.contactoEmail,
    required this.creadoEn,
  });

  // Constructor para crear desde documento de Firestore
  factory LaboratorioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LaboratorioModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      diasAlerta: data['diasAlerta'] ?? 30,
      contactoEmail: data['contactoEmail'] ?? '',
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'diasAlerta': diasAlerta,
      'contactoEmail': contactoEmail,
      'creadoEn': Timestamp.fromDate(creadoEn),
    };
  }

  // Copiar con cambios (útil para edición)
  LaboratorioModel copyWith({
    String? id,
    String? nombre,
    int? diasAlerta,
    String? contactoEmail,
    DateTime? creadoEn,
  }) {
    return LaboratorioModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      diasAlerta: diasAlerta ?? this.diasAlerta,
      contactoEmail: contactoEmail ?? this.contactoEmail,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}