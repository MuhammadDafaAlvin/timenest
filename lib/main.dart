import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const TimeNestApp());
}

class TimeNestApp extends StatefulWidget {
  const TimeNestApp({super.key});

  @override
  TimeNestAppState createState() => TimeNestAppState();
}

class TimeNestAppState extends State<TimeNestApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode') ?? 'dark';
    setState(() {
      _themeMode = themeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: MaterialApp(
        title: 'TimeNest',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey[100],
          primaryColor: Colors.blueAccent,
          colorScheme: const ColorScheme.light(
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
            secondary: Color.fromARGB(255, 4, 196, 103),
            onSecondary: Colors.white,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.light().textTheme,
          ).copyWith(
            bodyLarge: GoogleFonts.inter(letterSpacing: -0.5),
            bodyMedium: GoogleFonts.inter(letterSpacing: -0.5),
            titleLarge: GoogleFonts.inter(letterSpacing: -1.0),
            titleMedium: GoogleFonts.inter(letterSpacing: -1.0),
            labelLarge: GoogleFonts.inter(letterSpacing: -0.8),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
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
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: Colors.blueAccent,
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white70,
            secondary: Color.fromARGB(255, 4, 196, 103),
            onSecondary: Colors.white,
          ),
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
            foregroundColor: Colors.white,
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
        themeMode: _themeMode,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/stats': (context) => const StatsScreen(),
          '/settings':
              (context) => SettingsScreen(onThemeChanged: _changeTheme),
        },
      ),
    );
  }
}
