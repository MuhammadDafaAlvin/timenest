import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import 'dart:convert';

class TimerProvider with ChangeNotifier {
  int _workDuration = 25 * 60; // 25 menit dalam detik
  int _shortBreak = 5 * 60; // 5 menit
  int _longBreak = 15 * 60; // 15 menit
  int _timeLeft = 25 * 60;
  bool _isRunning = false;
  String _currentMode = 'Work';
  Timer? _timer;
  List<Task> _tasks = [];
  int _completedPomodorosToday = 0;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TimerProvider() {
    _loadTasks();
    _initNotifications();
  }

  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  String get currentMode => _currentMode;
  List<Task> get tasks => _tasks;
  int get completedPomodorosToday => _completedPomodorosToday;

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
            ? _shortBreak
            : _longBreak;
    notifyListeners();
  }

  void _switchMode() {
    if (_currentMode == 'Work') {
      _completedPomodorosToday++;
      if (_tasks.isNotEmpty) {
        _tasks[0].completedPomodoros++;
        _saveTasks();
      }
      _currentMode =
          _completedPomodorosToday % 4 == 0 ? 'Long Break' : 'Short Break';
      _timeLeft = _currentMode == 'Long Break' ? _longBreak : _shortBreak;
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
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'timer_channel',
          'Timer Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformDetails = NotificationDetails(
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
