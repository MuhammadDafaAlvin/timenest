class Task {
  String id;
  String title;
  int completedPomodoros;
  DateTime date;

  Task({
    required this.id,
    required this.title,
    this.completedPomodoros = 0,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completedPomodoros': completedPomodoros,
    'date': date.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    completedPomodoros: json['completedPomodoros'],
    date: DateTime.parse(json['date']),
  );
}
