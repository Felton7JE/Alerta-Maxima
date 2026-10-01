import 'package:flutter/material.dart';

class AppTheme {
  // Cores de Tema (Agradável ao Olho e Profissional)
  static const Color lightBg = Color(0xFFE2E8F0);  // Fundo Principal Suave (Reduz o cansaço visual)
  static const Color panelBg = Color(0xFFF1F5F9);  // Fundo de Painéis Ligeiramente Mais Claro
  static const Color cardBg = Color(0xFFFFFFFF);   // Cartões Brancos
  static const Color appBarBg = Color(0xFF0E7490); // Azul Ciano Sóbrio/Escuro
  static const Color textPrimary = Color(0xFF0F172A); // Texto Escuro
  static const Color textMuted = Color(0xFF64748B);   // Texto Secundário
  static const Color border = Color(0xFFCBD5E1);      // Bordas Suaves

  // Cores de Estado do Alerta (Conforme Especificação)
  static const Color statusNovo = Color(0xFFDC2626);
  static const Color statusAssumido = Color(0xFFEA580C);
  static const Color statusEquipaACaminho = Color(0xFF2563EB);
  static const Color statusEquipaNoLocal = Color(0xFF0D9488);
  static const Color statusResolvido = Color(0xFF16A34A);
  static const Color statusFalsoAlarme = Color(0xFF6B7280);
  static const Color statusExpirado = Color(0xFFCA8A04);

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: appBarBg,
        surface: panelBg,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: const CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.all(0),
      ),
      dividerColor: border,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textPrimary, fontSize: 13),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
