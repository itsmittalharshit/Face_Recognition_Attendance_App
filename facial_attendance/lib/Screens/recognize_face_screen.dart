import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import '/Widgets/attendance_db.dart';

class RecognizeFaceScreen extends StatefulWidget {
  const RecognizeFaceScreen({super.key});

  @override
  State<RecognizeFaceScreen> createState() => _RecognizeFaceScreenState();
}

class _RecognizeFaceScreenState extends State<RecognizeFaceScreen> {
  CameraController? controller;
  bool _isDetecting = false;
  String _result = '';
  final String baseUrl = "http://10.136.70.2:5001";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _result = "No cameras available");
      return;
    }
    CameraDescription frontCamera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.front,);

    controller = CameraController(
      frontCamera, 
      ResolutionPreset.high,
      enableAudio: false,
      );

    await controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  // Call this to capture one frame and send to backend
  Future<void> recognizeFace() async {
    if (controller == null || _isDetecting || !controller!.value.isInitialized) return;

    _isDetecting = true;
    setState(() {});

    try {
      // takePicture returns an XFile (no path argument)
      final XFile rawImage = await controller!.takePicture();

      // Option A: Use the returned path directly (many platforms provide it)
      String imagePath = rawImage.path;

      // Option B: If you prefer to control the filename/location:
      // final tempDir = await getTemporaryDirectory();
      // imagePath = '${tempDir.path}/frame.jpg';
      // await rawImage.saveTo(imagePath);

      // prepare multipart request
      var uri = Uri.parse('$baseUrl/recognize');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();
      var resData = await http.Response.fromStream(response);
      final jsonRes = json.decode(resData.body);

      if (jsonRes['status'] == 'success') {
        final name = jsonRes['name'];
        setState(() => _result = "Recognized: $name ✅");

        // Store attendance in local DB
        await AttendanceDB.instance.insertAttendance(name);
      } else {
        setState(() => _result = jsonRes['message'] ?? 'Not recognized');
      }
    } catch (e) {
      setState(() => _result = "Error: $e");
    } finally {
      _isDetecting = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Recognize Face")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: CameraPreview(controller!),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: recognizeFace,
            child: _isDetecting
                ? const Text("Detecting...")
                : const Text("Detect Face"),
          ),
          const SizedBox(height: 10),
          Text(_result, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

