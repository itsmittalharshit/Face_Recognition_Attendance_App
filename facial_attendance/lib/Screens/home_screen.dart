import 'package:flutter/material.dart';
import 'register_face_screen.dart';
import 'recognize_face_screen.dart';
import 'view_attendance_screen.dart';
import '/Widgets/export_csv.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Attendance System"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildButton(context, Icons.person_add, "Register Face", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegisterFaceScreen()));
            }),
            _buildButton(context, Icons.camera, "Recognize Face", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RecognizeFaceScreen()));
            }),
            _buildButton(context, Icons.list_alt, "View Attendance", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ViewAttendanceScreen()));
            }),
            _buildButton(context, Icons.download, "Export CSV", () async {
              await exportAttendanceToCSV(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 60, color: Colors.white),
                const SizedBox(height: 12),
                Text(label,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

