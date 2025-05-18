import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/timer_provider.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  double _workDuration = 25;
  double _shortBreakDuration = 5;
  double _longBreakDuration = 15;
  int _sessionsBeforeLongBreak = 4;
  bool _isDarkTheme = true;

  @override
  void initState() {
    super.initState();
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.loadSettings().then((_) {
      setState(() {
        _workDuration = timerProvider.workDuration / 60;
        _shortBreakDuration = timerProvider.shortBreakDuration / 60;
        _longBreakDuration = timerProvider.longBreakDuration / 60;
        _sessionsBeforeLongBreak = timerProvider.sessionsBeforeLongBreak;
      });
    });
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getString('themeMode') != 'light';
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', isDark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.inter(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GlassContainer(
                opacity:
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1,
                borderRadius: 12.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durasi Timer',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Work (menit)',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Slider(
                        value: _workDuration,
                        min: 1,
                        max: 60,
                        divisions: 59,
                        label: _workDuration.round().toString(),
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((255 * 0.3).round()),
                        onChanged:
                            (value) => setState(() => _workDuration = value),
                        onChangeEnd: (value) {
                          timerProvider.setDurations(
                            (value * 60).toInt(),
                            (_shortBreakDuration * 60).toInt(),
                            (_longBreakDuration * 60).toInt(),
                          );
                        },
                      ),
                      Text(
                        'Short Break (menit)',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Slider(
                        value: _shortBreakDuration,
                        min: 1,
                        max: 15,
                        divisions: 14,
                        label: _shortBreakDuration.round().toString(),
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(77),
                        onChanged:
                            (value) =>
                                setState(() => _shortBreakDuration = value),
                        onChangeEnd: (value) {
                          timerProvider.setDurations(
                            (_workDuration * 60).toInt(),
                            (value * 60).toInt(),
                            (_longBreakDuration * 60).toInt(),
                          );
                        },
                      ),
                      Text(
                        'Long Break (menit)',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Slider(
                        value: _longBreakDuration,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: _longBreakDuration.round().toString(),
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(77),
                        onChanged:
                            (value) =>
                                setState(() => _longBreakDuration = value),
                        onChangeEnd: (value) {
                          timerProvider.setDurations(
                            (_workDuration * 60).toInt(),
                            (_shortBreakDuration * 60).toInt(),
                            (value * 60).toInt(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sesi Sebelum Long Break',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      DropdownButton<int>(
                        value: _sessionsBeforeLongBreak,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        items:
                            [1, 2, 3, 4, 5].map((sessions) {
                              return DropdownMenuItem(
                                value: sessions,
                                child: Text(
                                  '$sessions sesi',
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _sessionsBeforeLongBreak = value!);
                          timerProvider.setSessionsBeforeLongBreak(value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                opacity:
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1,
                borderRadius: 12.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tampilan',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(
                          'Tema Gelap',
                          style: GoogleFonts.inter(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        value: _isDarkTheme,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (value) {
                          setState(() => _isDarkTheme = value);
                          _saveTheme(value);
                          if (widget.onThemeChanged != null) {
                            widget.onThemeChanged!(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                opacity:
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1,
                borderRadius: 12.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      timerProvider.resetSettings();
                      setState(() {
                        _workDuration = 25;
                        _shortBreakDuration = 5;
                        _longBreakDuration = 15;
                        _sessionsBeforeLongBreak = 4;
                        _isDarkTheme = true;
                        _saveTheme(true);
                        if (widget.onThemeChanged != null) {
                          widget.onThemeChanged!(ThemeMode.dark);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reset ke Default',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
