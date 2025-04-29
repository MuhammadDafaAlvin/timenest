import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import 'glass_container.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      opacity: 0.1, // Latar belakang lebih transparan
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Teks utama lebih terang
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Pomodoro selesai: ${task.completedPomodoros}',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[200], // Teks sekunder lebih terang
              ),
            ),
          ],
        ),
      ),
    );
  }
}
