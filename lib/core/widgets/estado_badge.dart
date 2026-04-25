import 'package:flutter/material.dart';
import '../../models/medicamento_model.dart';
import '../constants/app_colors.dart';

class EstadoBadge extends StatelessWidget {
  final EstadoMedicamento estado;
  final bool small;

  const EstadoBadge({
    super.key,
    required this.estado,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String texto;

    switch (estado) {
      case EstadoMedicamento.vigente:
        color = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.1);
        texto = 'Vigente';
        break;
      case EstadoMedicamento.porVencer:
        color = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
        texto = 'Por vencer';
        break;
      case EstadoMedicamento.vencido:
        color = AppColors.error;
        bgColor = AppColors.error.withOpacity(0.1);
        texto = 'Vencido';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}