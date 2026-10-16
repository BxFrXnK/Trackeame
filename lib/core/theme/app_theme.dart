import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color backgroundColor = Color(0xFFF4F5F9);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);

  // Paleta de colores acentuados para los hábitos
  static const Color habitYellow = Color(0xFFFFD600);
  static const Color habitBlue = Color(0xFF007AFF);
  static const Color habitPurple = Color(0xFFAF52DE);
  static const Color habitGreen = Color(0xFF34C759);
  static const Color habitRed = Color(0xFFFF3B30);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: habitBlue,
        surface: cardColor,
      ),

      // Estilo de la barra superior (AppBar)
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),

      // Estilo por defecto de las tarjetas redondeadas
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Configuración del BottomNavigationBar flotante
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        indicatorColor: const Color(0xFFE5E5EA),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
