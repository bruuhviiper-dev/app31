import 'package:flutter/material.dart';

/// Tema do app — teal/petróleo (sereno, reflexivo, profundo).
class AppTheme {
  AppTheme._();

  static const brand = Color(0xFF2C7A7B); // teal/petróleo
  static const brandDark = Color(0xFF14535A);
  static const gold = Color(0xFF9FE0DE);

  /// Gradiente da "frase do dia" e da marca.
  static const hero = [Color(0xFF0F2027), Color(0xFF2C5364)];

  static LinearGradient gradient(List<Color> colors) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );

  static ThemeData light([Color accent = brand]) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFEFF4F5),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }

  static ThemeData dark([Color accent = brand]) {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF0E1518),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
