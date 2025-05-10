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
  // ignore: unused_field
  bool _notificationsEnabled = true;
  String _notificationSound = 'default';
  bool _isDarkTheme = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai awal dari TimerProvider
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.loadSettings().then((_) {
      setState(() {
        _workDuration = timerProvider.workDuration / 60;
        _shortBreakDuration = timerProvider.shortBreakDuration / 60;
        _longBreakDuration = timerProvider.longBreakDuration / 60;
        _sessionsBeforeLongBreak = timerProvider.sessionsBeforeLongBreak;
        _notificationsEnabled = timerProvider.notificationsEnabled;
        _notificationSound = timerProvider.notificationSound;
      });
    });
    // Load preferensi tema dan bahasa
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getString('themeMode') != 'light';
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Durasi Timer
              GlassContainer(
                opacity: 0.1,
                borderRadius: 12.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durasi Timer',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Work (menit)',
                        style: GoogleFonts.inter(color: Colors.grey[200]),
                      ),
                      Slider(
                        value: _workDuration,
                        min: 10,
                        max: 60,
                        divisions: 50,
                        label: _workDuration.round().toString(),
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.grey[700],
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
                        style: GoogleFonts.inter(color: Colors.grey[200]),
                      ),
                      Slider(
                        value: _shortBreakDuration,
                        min: 3,
                        max: 15,
                        divisions: 12,
                        label: _shortBreakDuration.round().toString(),
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.grey[700],
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
                        style: GoogleFonts.inter(color: Colors.grey[200]),
                      ),
                      Slider(
                        value: _longBreakDuration,
                        min: 10,
                        max: 30,
                        divisions: 20,
                        label: _longBreakDuration.round().toString(),
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.grey[700],
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
                        style: GoogleFonts.inter(color: Colors.grey[200]),
                      ),
                      DropdownButton<int>(
                        value: _sessionsBeforeLongBreak,
                        dropdownColor: Colors.grey[800],
                        style: GoogleFonts.inter(color: Colors.white),
                        items:
                            [2, 3, 4, 5].map((sessions) {
                              return DropdownMenuItem(
                                value: sessions,
                                child: Text(
                                  '$sessions sesi',
                                  style: GoogleFonts.inter(color: Colors.white),
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
              // Tampilan
              GlassContainer(
                opacity: 0.1,
                borderRadius: 12.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tampilan',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(
                          'Tema Gelap',
                          style: GoogleFonts.inter(color: Colors.grey[200]),
                        ),
                        value: _isDarkTheme,
                        activeColor: Colors.blueAccent,
                        onChanged: (value) {
                          setState(() => _isDarkTheme = value);
                          if (widget.onThemeChanged != null) {
                            widget.onThemeChanged!(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                          }
                        },
                      ),
                      Text(
                        'Bahasa',
                        style: GoogleFonts.inter(color: Colors.grey[200]),
                      ),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        dropdownColor: Colors.grey[800],
                        style: GoogleFonts.inter(color: Colors.white),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              'English',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'id',
                            child: Text(
                              'Indonesia',
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value!);
                          _saveLanguage(value!);
                          // TODO: Panggil setLocale di main.dart untuk mengubah bahasa
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notifikasi
              GlassContainer(
                opacity: 0.1,
                borderRadius: 12.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(
                          'Aktifkan Notifikasi',
                          style: GoogleFonts.inter(color: Colors.grey[200]),
                        ),
                        value: timerProvider.notificationsEnabled,
                        activeColor: Colors.blueAccent,
                        onChanged: (value) {
                          timerProvider.setNotificationsEnabled(value);
                        },
                      ),
                      Text(
                        'Suara Notifikasi',
                        style: GoogleFonts.inter(color: Colors.grey[200]),
                      ),
                      DropdownButton<String>(
                        value: _notificationSound,
                        dropdownColor: Colors.grey[800],
                        style: GoogleFonts.inter(color: Colors.white),
                        items:
                            ['default', 'silent', 'custom_sound'].map((sound) {
                              return DropdownMenuItem(
                                value: sound,
                                child: Text(
                                  sound,
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => _notificationSound = value!);
                          timerProvider.setNotificationSound(value!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Reset Pengaturan
              GlassContainer(
                opacity: 0.1,
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
                        _notificationsEnabled = true;
                        _notificationSound = 'default';
                        _isDarkTheme = true;
                        _selectedLanguage = 'en';
                        if (widget.onThemeChanged != null) {
                          widget.onThemeChanged!(ThemeMode.dark);
                        }
                        _saveLanguage('en');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reset ke Default',
                      style: GoogleFonts.inter(
                        color: Colors.white,
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
