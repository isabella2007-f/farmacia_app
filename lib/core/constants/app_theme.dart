import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      
      // Tipografía Inter (moderna y legible)
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadow,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textHint,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textSecondary,
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}