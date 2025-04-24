import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/timer_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final minutes = (timerProvider.timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerProvider.timeLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeNest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      timerProvider.currentMode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 15.0,
                      percent:
                          timerProvider.timeLeft /
                          (timerProvider.currentMode == 'Work'
                              ? 25 * 60
                              : timerProvider.currentMode == 'Short Break'
                              ? 5 * 60
                              : 15 * 60),
                      center: Text(
                        '$minutes:$seconds',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.blue,
                      backgroundColor: Colors.grey[300]!,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              timerProvider.isRunning
                                  ? timerProvider.pauseTimer
                                  : timerProvider.startTimer,
                          child: Text(
                            timerProvider.isRunning ? 'Jeda' : 'Mulai',
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: timerProvider.resetTimer,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tambah Tugas',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  timerProvider.addTask(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: timerProvider.tasks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TaskCard(task: timerProvider.tasks[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
