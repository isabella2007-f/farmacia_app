import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para los estados del medicamento
enum EstadoMedicamento {
  vigente,
  porVencer,    // Dentro del período de alerta del laboratorio
  vencido,
}

class MedicamentoModel {
  final String id;
  final String nombre;
  final String laboratorioId;
  final String laboratorioNombre;
  final DateTime fechaVencimiento;
  final DateTime fechaAlerta;   // Calculada: vencimiento - diasAlerta del laboratorio
  final int cantidad;
  final String userId;
  final bool alertaEnviada;
  final DateTime creadoEn;
  final int diasAlertaLaboratorio; // Guardamos para referencia

  MedicamentoModel({
    required this.id,
    required this.nombre,
    required this.laboratorioId,
    required this.laboratorioNombre,
    required this.fechaVencimiento,
    required this.fechaAlerta,
    required this.cantidad,
    required this.userId,
    required this.alertaEnviada,
    required this.creadoEn,
    required this.diasAlertaLaboratorio,
  });

  // Estado calculado en tiempo real (no se guarda en Firestore)
  EstadoMedicamento get estado {
    final now = DateTime.now();
    if (now.isAfter(fechaVencimiento)) {
      return EstadoMedicamento.vencido;
    } else if (now.isAfter(fechaAlerta)) {
      return EstadoMedicamento.porVencer;
    } else {
      return EstadoMedicamento.vigente;
    }
  }

  // Días restantes para vencer (puede ser negativo si ya venció)
  int get diasParaVencer {
    return fechaVencimiento.difference(DateTime.now()).inDays;
  }

  // Nombre del estado para mostrar en UI
  String get estadoTexto {
    switch (estado) {
      case EstadoMedicamento.vigente:
        return 'Vigente';
      case EstadoMedicamento.porVencer:
        return 'Por vencer';
      case EstadoMedicamento.vencido:
        return 'Vencido';
    }
  }

  factory MedicamentoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicamentoModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      laboratorioId: data['laboratorioId'] ?? '',
      laboratorioNombre: data['laboratorioNombre'] ?? '',
      fechaVencimiento:
          (data['fechaVencimiento'] as Timestamp).toDate(),
      fechaAlerta:
          (data['fechaAlerta'] as Timestamp).toDate(),
      cantidad: data['cantidad'] ?? 0,
      userId: data['userId'] ?? '',
      alertaEnviada: data['alertaEnviada'] ?? false,
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
      diasAlertaLaboratorio: data['diasAlertaLaboratorio'] ?? 30,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'laboratorioId': laboratorioId,
      'laboratorioNombre': laboratorioNombre,
      'fechaVencimiento': Timestamp.fromDate(fechaVencimiento),
      'fechaAlerta': Timestamp.fromDate(fechaAlerta),
      'cantidad': cantidad,
      'userId': userId,
      'alertaEnviada': alertaEnviada,
      'creadoEn': Timestamp.fromDate(creadoEn),
      'diasAlertaLaboratorio': diasAlertaLaboratorio,
    };
  }

  MedicamentoModel copyWith({
    String? id,
    String? nombre,
    String? laboratorioId,
    String? laboratorioNombre,
    DateTime? fechaVencimiento,
    DateTime? fechaAlerta,
    int? cantidad,
    String? userId,
    bool? alertaEnviada,
    DateTime? creadoEn,
    int? diasAlertaLaboratorio,
  }) {
    return MedicamentoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      laboratorioId: laboratorioId ?? this.laboratorioId,
      laboratorioNombre: laboratorioNombre ?? this.laboratorioNombre,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaAlerta: fechaAlerta ?? this.fechaAlerta,
      cantidad: cantidad ?? this.cantidad,
      userId: userId ?? this.userId,
      alertaEnviada: alertaEnviada ?? this.alertaEnviada,
      creadoEn: creadoEn ?? this.creadoEn,
      diasAlertaLaboratorio:
          diasAlertaLaboratorio ?? this.diasAlertaLaboratorio,
    );
  }
}