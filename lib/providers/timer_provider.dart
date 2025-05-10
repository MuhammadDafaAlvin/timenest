import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import 'dart:convert';

class TimerProvider with ChangeNotifier {
  int _workDuration = 25 * 60; // Default 25 menit
  int _shortBreakDuration = 5 * 60; // Default 5 menit
  int _longBreakDuration = 15 * 60; // Default 15 menit
  int _timeLeft = 25 * 60;
  bool _isRunning = false;
  String _currentMode = 'Work';
  Timer? _timer;
  List<Task> _tasks = [];
  int _completedPomodorosToday = 0;
  int _sessionsBeforeLongBreak = 4; // Default: Long Break setelah 4 sesi
  int _sessionCount = 0;
  bool _notificationsEnabled = true; // Default: Notifikasi aktif
  String _notificationSound = 'default'; // default, silent, custom_sound

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Getter untuk pengaturan
  int get workDuration => _workDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;
  bool get notificationsEnabled => _notificationsEnabled;
  String get notificationSound => _notificationSound;

  // Getter yang sudah ada
  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  String get currentMode => _currentMode;
  List<Task> get tasks => _tasks;
  int get completedPomodorosToday => _completedPomodorosToday;

  TimerProvider() {
    loadSettings();
    _loadTasks();
    _initNotifications();
  }

  // Memuat semua pengaturan dari SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = prefs.getInt('workDuration') ?? 25 * 60;
    _shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5 * 60;
    _longBreakDuration = prefs.getInt('longBreakDuration') ?? 15 * 60;
    _sessionsBeforeLongBreak = prefs.getInt('sessionsBeforeLongBreak') ?? 4;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _notificationSound = prefs.getString('notificationSound') ?? 'default';
    _timeLeft =
        _currentMode == 'Work'
            ? _workDuration
            : _currentMode == 'Short Break'
            ? _shortBreakDuration
            : _longBreakDuration;
    notifyListeners();
  }

  // Menyimpan durasi timer
  Future<void> setDurations(int work, int shortBreak, int longBreak) async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = work;
    _shortBreakDuration = shortBreak;
    _longBreakDuration = longBreak;
    await prefs.setInt('workDuration', work);
    await prefs.setInt('shortBreakDuration', shortBreak);
    await prefs.setInt('longBreakDuration', longBreak);
    // Validasi _timeLeft agar sesuai dengan durasi baru
    final maxDuration =
        _currentMode == 'Work'
            ? _workDuration
            : _currentMode == 'Short Break'
            ? _shortBreakDuration
            : _longBreakDuration;
    _timeLeft = _timeLeft.clamp(0, maxDuration);
    if (!_isRunning) {
      resetTimer();
    }
    notifyListeners();
  }

  // Menyimpan jumlah sesi sebelum Long Break
  Future<void> setSessionsBeforeLongBreak(int sessions) async {
    final prefs = await SharedPreferences.getInstance();
    _sessionsBeforeLongBreak = sessions;
    await prefs.setInt('sessionsBeforeLongBreak', sessions);
    notifyListeners();
  }

  // Mengatur status notifikasi
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = enabled;
    await prefs.setBool('notificationsEnabled', enabled);
    notifyListeners();
  }

  // Mengatur suara notifikasi
  Future<void> setNotificationSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    _notificationSound = sound;
    await prefs.setString('notificationSound', sound);
    notifyListeners();
  }

  // Reset semua pengaturan ke default
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = 25 * 60;
    _shortBreakDuration = 5 * 60;
    _longBreakDuration = 15 * 60;
    _sessionsBeforeLongBreak = 4;
    _notificationsEnabled = true;
    _notificationSound = 'default';
    await prefs.setInt('workDuration', _workDuration);
    await prefs.setInt('shortBreakDuration', _shortBreakDuration);
    await prefs.setInt('longBreakDuration', _longBreakDuration);
    await prefs.setInt('sessionsBeforeLongBreak', _sessionsBeforeLongBreak);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('notificationSound', _notificationSound);
    _timeLeft = _workDuration;
    _currentMode = 'Work';
    _sessionCount = 0;
    if (!_isRunning) {
      resetTimer();
    }
    notifyListeners();
  }

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          notifyListeners();
        } else {
          _timer?.cancel();
          _isRunning = false;
          _notifySessionComplete();
          _switchMode();
        }
      });
      notifyListeners();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _timeLeft =
        _currentMode == 'Work'
            ? _workDuration
            : _currentMode == 'Short Break'
            ? _shortBreakDuration
            : _longBreakDuration;
    notifyListeners();
  }

  void _switchMode() {
    if (_currentMode == 'Work') {
      _completedPomodorosToday++;
      _sessionCount++;
      if (_tasks.isNotEmpty) {
        _tasks[0].completedPomodoros++;
        _saveTasks();
      }
      if (_sessionCount >= _sessionsBeforeLongBreak) {
        _currentMode = 'Long Break';
        _timeLeft = _longBreakDuration;
        _sessionCount = 0;
      } else {
        _currentMode = 'Short Break';
        _timeLeft = _shortBreakDuration;
      }
    } else {
      _currentMode = 'Work';
      _timeLeft = _workDuration;
    }
    notifyListeners();
  }

  void addTask(String title) {
    _tasks.add(
      Task(id: DateTime.now().toString(), title: title, date: DateTime.now()),
    );
    _saveTasks();
    notifyListeners();
  }

  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', json.encode(tasksJson));
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  void _notifySessionComplete() async {
    if (!_notificationsEnabled) return;
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound:
          _notificationSound == 'default'
              ? const RawResourceAndroidNotificationSound('notification')
              : null,
    );
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await _notificationsPlugin.show(
      0,
      'Sesi $_currentMode Selesai',
      'Waktunya untuk ${_currentMode == 'Work' ? 'istirahat' : 'bekerja kembali'}!',
      platformDetails,
    );
  }
}
