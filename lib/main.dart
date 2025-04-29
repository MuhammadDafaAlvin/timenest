import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const TimeNestApp());
}

class TimeNestApp extends StatelessWidget {
  const TimeNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: MaterialApp(
        title: 'TimeNest',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: Colors.blueAccent,
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ).copyWith(
            bodyLarge: GoogleFonts.inter(letterSpacing: -0.5),
            bodyMedium: GoogleFonts.inter(letterSpacing: -0.5),
            titleLarge: GoogleFonts.inter(letterSpacing: -1.0),
            titleMedium: GoogleFonts.inter(letterSpacing: -1.0),
            labelLarge: GoogleFonts.inter(letterSpacing: -0.8),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/stats': (context) => const StatsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
