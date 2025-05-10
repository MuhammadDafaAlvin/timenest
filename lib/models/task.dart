class Task {
  final String id;
  final String title;
  final DateTime date;
  int completedPomodoros;

  Task({
    required this.id,
    required this.title,
    required this.date,
    this.completedPomodoros = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'completedPomodoros': completedPomodoros,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    date: DateTime.parse(json['date']),
    completedPomodoros: json['completedPomodoros'],
  );
}
