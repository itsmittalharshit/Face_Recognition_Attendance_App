import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'attendance_db.dart';

Future<void> exportAttendanceToCSV(context) async {
  try {
    final records = await AttendanceDB.instance.getAll();

    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No records to export")),
      );
      return;
    }

    List<List<dynamic>> rows = [
      ["Name", "Timestamp"]
    ];


    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (var r in records) {
      final rawDate = r['date'];
      DateTime parsedDate;

      if (rawDate is int) {

        parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
      } else if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }

      rows.add([
        r['name'],
        dateFormat.format(parsedDate),
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Documents');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }


    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir!.path}/attendance_$timestamp.csv');


    await file.writeAsString(csvData);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Exported successfully to: ${file.path}"),
        duration: const Duration(seconds: 3),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to export: $e")),
    );
  }
}
