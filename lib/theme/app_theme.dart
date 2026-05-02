import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF14C38E);
  static const Color darkGreen = Color(0xFF0B3D2E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color recyclable = Color(0xFF14C38E);
  static const Color compostable = Color(0xFF8D6E63);
  static const Color waste = Color(0xFF546E7A);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color accent = Color(0xFF0B3D2E);
  static const Color lightGreen = Color(0xFFE8F8F2);
  static const Color lightBrown = Color(0xFFF5EFED);
  static const Color lightBlue = Color(0xFFECEFF1);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.darkGreen,
        surface: AppColors.background,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkGreen,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreen,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreen,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreen,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGreen,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.darkGray,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkGray,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mediumGray,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.divider,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.darkGreen),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.darkGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: AppColors.mediumGray,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGreen,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGreen,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}
