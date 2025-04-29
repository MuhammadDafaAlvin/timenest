import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/timer_provider.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.grey[800],
    minimumSize: const Size(100, 45),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
  );

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final minutes = (timerProvider.timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerProvider.timeLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeNest'),
        backgroundColor: Colors.grey[900],
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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withAlpha((0.5 * 255).round()),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      timerProvider.currentMode,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      progressColor: const Color.fromARGB(255, 4, 196, 103),
                      backgroundColor: Colors.grey[800]!,
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
                          style: buttonStyle,
                          child: Text(
                            timerProvider.isRunning ? 'Jeda' : 'Mulai',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: timerProvider.resetTimer,
                          style: buttonStyle,
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tambah Tugas',
                labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
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
