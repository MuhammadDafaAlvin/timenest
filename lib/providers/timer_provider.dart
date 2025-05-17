import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'dart:convert';

class TimerProvider with ChangeNotifier {
  int _workDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;
  int _timeLeft = 25 * 60;
  bool _isRunning = false;
  String _currentMode = 'Work';
  Timer? _timer;
  List<Task> _tasks = [];
  int _completedPomodorosToday = 0;
  int _sessionsBeforeLongBreak = 4;
  int _sessionCount = 0;

  int get workDuration => _workDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get sessionsBeforeLongBreak => _sessionsBeforeLongBreak;

  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  String get currentMode => _currentMode;
  List<Task> get tasks => _tasks;
  int get completedPomodorosToday => _completedPomodorosToday;

  TimerProvider() {
    loadSettings();
    _loadTasks();
    _restoreTimerState();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = prefs.getInt('workDuration') ?? 25 * 60;
    _shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5 * 60;
    _longBreakDuration = prefs.getInt('longBreakDuration') ?? 15 * 60;
    _sessionsBeforeLongBreak = prefs.getInt('sessionsBeforeLongBreak') ?? 4;
    notifyListeners();
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timeLeft', _timeLeft);
    await prefs.setBool('isRunning', _isRunning);
    await prefs.setString('currentMode', _currentMode);
    await prefs.setInt('sessionCount', _sessionCount);
    await prefs.setInt('completedPomodorosToday', _completedPomodorosToday);
  }

  Future<void> _restoreTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    _timeLeft = prefs.getInt('timeLeft') ?? _workDuration;
    _isRunning = prefs.getBool('isRunning') ?? false;
    _currentMode = prefs.getString('currentMode') ?? 'Work';
    _sessionCount = prefs.getInt('sessionCount') ?? 0;
    _completedPomodorosToday = prefs.getInt('completedPomodorosToday') ?? 0;

    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          _saveTimerState();
          notifyListeners();
        } else {
          _timer?.cancel();
          _isRunning = false;
          _switchMode();
          _saveTimerState();
        }
      });
    }
    notifyListeners();
  }

  Future<void> setDurations(int work, int shortBreak, int longBreak) async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = work;
    _shortBreakDuration = shortBreak;
    _longBreakDuration = longBreak;
    await prefs.setInt('workDuration', work);
    await prefs.setInt('shortBreakDuration', shortBreak);
    await prefs.setInt('longBreakDuration', longBreak);
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
    _saveTimerState();
    notifyListeners();
  }

  Future<void> setSessionsBeforeLongBreak(int sessions) async {
    final prefs = await SharedPreferences.getInstance();
    _sessionsBeforeLongBreak = sessions;
    await prefs.setInt('sessionsBeforeLongBreak', sessions);
    _saveTimerState();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', json.encode(tasksJson));
  }

  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = 25 * 60;
    _shortBreakDuration = 5 * 60;
    _longBreakDuration = 15 * 60;
    _sessionsBeforeLongBreak = 4;
    await prefs.setInt('workDuration', _workDuration);
    await prefs.setInt('shortBreakDuration', _shortBreakDuration);
    await prefs.setInt('longBreakDuration', _longBreakDuration);
    await prefs.setInt('sessionsBeforeLongBreak', _sessionsBeforeLongBreak);
    _timeLeft = _workDuration;
    _currentMode = 'Work';
    _sessionCount = 0;
    _completedPomodorosToday = 0;
    _timer?.cancel();
    _isRunning = false;
    _saveTimerState();
    notifyListeners();
  }

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          _saveTimerState();
          notifyListeners();
        } else {
          _timer?.cancel();
          _isRunning = false;
          _switchMode();
          _saveTimerState();
        }
      });
      _saveTimerState();
      notifyListeners();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _saveTimerState();
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
    _saveTimerState();
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
    _saveTimerState();
    notifyListeners();
  }

  void addTask(String title) {
    _tasks.add(
      Task(id: DateTime.now().toString(), title: title, date: DateTime.now()),
    );
    _saveTasks();
    notifyListeners();
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

  void removeTask(int index) async {
    _tasks.removeAt(index);
    await _saveTasks();
    notifyListeners();
  }
}
