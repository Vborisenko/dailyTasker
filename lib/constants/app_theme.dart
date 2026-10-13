import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App theme configuration based on design specification
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      
      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        surface: AppColors.cardBackground,
        onPrimary: AppColors.primaryBackground,
        onSecondary: AppColors.primaryBackground,
        onSurface: AppColors.primaryColor,
      ),
      
      // Typography
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryText,
        ),
      ),
      
      // Components
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          foregroundColor: AppColors.primaryBackground,
          minimumSize: const Size(double.infinity, 48.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.accentColor, width: 2.0),
        ),
      ),
    );
  }
} 