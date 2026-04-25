import 'package:flutter/material.dart';

class AppColors {
  // Paleta elegante - azul marino y dorado
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2FF);

  // Primario - azul marino profundo
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryLighter = Color(0xFFE8EAF6);

  // Acento dorado
  static const Color accent = Color(0xFFFFB300);
  static const Color accentLight = Color(0xFFFFF8E1);

  // Texto
  static const Color textPrimary = Color(0xFF0D0D2B);
  static const Color textSecondary = Color(0xFF5C5C8A);
  static const Color textHint = Color(0xFFB0B0CC);

  // Estados
  static const Color success = Color(0xFF00897B);
  static const Color successLight = Color(0xFFE0F2F1);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Bordes
  static const Color border = Color(0xFFE0E0F0);
  static const Color borderDark = Color(0xFFC5C5E0);

  // Sombra
  static const Color shadow = Color(0x1A1A237E);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFFFCA28)],
  );

  static const LinearGradient loveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
  );
}