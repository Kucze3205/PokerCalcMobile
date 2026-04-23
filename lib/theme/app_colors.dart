import 'package:flutter/material.dart';

class AppColors {
  // Dark navy / poker table base
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF132436);
  static const Color surfaceLight = Color(0xFF1A2F45);

  // Casino green accents (darker)
  static const Color accent = Color(0xFF0B7A4A);
  static const Color accentGold = Color(0xFF12A061);
  static const Color success = Color(0xFF0F8F55);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9BBEAD);

  static const Color cardSlot = Color(0xFF15343D);

  // Suits (keep differentiation, but within green/teal family)
  static const Color hearts = Color(0xFF0F8F55);
  static const Color diamonds = Color(0xFF0D7F73);
  static const Color clubs = Color(0xFF0B7A4A);
  static const Color spades = Color(0xFF0B6D5F);

  // Traditional card suit colors for suit buttons
  static const Color heartsRed = Color(0xFFE53935);
  static const Color diamondsRed = Color(0xFFE53935);
  static const Color clubsWhite = Color(0xFFEEEEEE);
  static const Color spadesGray = Color(0xFF9E9E9E);

  static Color withOpacity(Color color, double opacity) {
    final int alpha = _clampAlpha((opacity * 255).round());
    return color.withAlpha(alpha);
  }

  static int _clampAlpha(int value) {
    if (value < 0) return 0;
    if (value > 255) return 255;
    return value;
  }
}
