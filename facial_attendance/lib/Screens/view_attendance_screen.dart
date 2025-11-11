import 'package:flutter/material.dart';
import '/Widgets/attendance_db.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await AttendanceDB.instance.getAll();
    setState(() => _records = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Records")),
      body: _records.isEmpty
          ? const Center(child: Text("No attendance yet"))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(record['name']),
                  subtitle: Text(record['date']),
                );
              },
            ),
    );
  }
}
