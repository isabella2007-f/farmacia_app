import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal - minimalista y elegante
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFB0B0B0);
  
  // Acento
  static const Color primary = Color(0xFF2D2D2D);
  static const Color primaryLight = Color(0xFF4A4A4A);
  
  // Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Bordes
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderDark = Color(0xFFD0D0D0);
  
  // Sombras
  static const Color shadow = Color(0x0F000000);
  
  // Gradiente sutil
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)],
  );
}