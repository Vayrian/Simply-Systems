// lib/theme/app_theme.dart
/*
 -----------------------------------------------------------------------------
 Simply Systems
 A mobile app (iOS & Android) for plural systems to manage system members,
 track fronting history, communicate internally via real-time chat, etc.
-----------------------------------------------------------------------------
 Copyright (C) 2026 Vayrian

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published
 by the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with this program.  If not, see https://www.gnu.org/licenses/.

*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppTheme {
  static const Color background = Color(0xFF0F1117);
  static const Color cardBg = Color(0xFF1A1F2E);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);

  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color accentPurple = Color(0xFFC084FC);

  static const Color primaryNeon = accentTeal;     
  static const Color secondaryNeon = accentAmber;  
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.dark(
          primary: accentTeal,
          secondary: accentAmber,
          tertiary: accentPurple,
          surface: cardBg,
          background: background,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: textPrimary,
          onBackground: textPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        cardTheme: CardThemeData(
          color: cardBg.withOpacity(0.85),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          shadowColor: accentTeal.withOpacity(0.15),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentTeal,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentAmber,
          foregroundColor: Colors.black,
          elevation: 8,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? accentTeal : textSecondary),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? accentTeal.withOpacity(0.4)
                  : cardBg),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      );

  // Glassmorphic card style
  static BoxDecoration glassCard({double opacity = 0.85}) {
    return BoxDecoration(
      color: cardBg.withOpacity(opacity),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: accentTeal.withOpacity(0.2), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: accentTeal.withOpacity(0.12),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
