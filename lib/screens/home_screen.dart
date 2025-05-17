import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/timer_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: null,
    backgroundColor: null,
    minimumSize: const Size(100, 45),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timenest',
          style: GoogleFonts.inter(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<TimerProvider>(
          builder: (context, timerProvider, child) {
            final minutes = (timerProvider.timeLeft ~/ 60).toString().padLeft(
              2,
              '0',
            );
            final seconds = (timerProvider.timeLeft % 60).toString().padLeft(
              2,
              '0',
            );

            final duration =
                timerProvider.currentMode == 'Work'
                    ? timerProvider.workDuration
                    : timerProvider.currentMode == 'Short Break'
                    ? timerProvider.shortBreakDuration
                    : timerProvider.longBreakDuration;
            final percent =
                duration > 0
                    ? (timerProvider.timeLeft / duration).clamp(0.0, 1.0)
                    : 0.0;

            final buttonColor =
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[700]
                    : Colors.blue;

            return Column(
              children: [
                GlassContainer(
                  opacity:
                      Theme.of(context).brightness == Brightness.dark
                          ? 0.4
                          : 0.5,
                  borderRadius: 30.0,
                  blur: 5.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          timerProvider.currentMode,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CircularPercentIndicator(
                          radius: 100.0,
                          lineWidth: 15.0,
                          percent: percent,
                          center: Text(
                            '$minutes:$seconds',
                            style: GoogleFonts.inter(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          progressColor: buttonColor,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha((0.3 * 255).toInt()),
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
                              style: buttonStyle.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                  buttonColor,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                              ),
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
                              style: buttonStyle.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                  buttonColor,
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tambah Tugas',
                    labelStyle: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
                        child: GestureDetector(
                          onLongPress: () {
                            timerProvider.removeTask(index);
                          },
                          child: TaskCard(
                            task: timerProvider.tasks[index],
                            onDelete: () {
                              timerProvider.removeTask(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
