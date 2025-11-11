import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterFaceScreen extends StatefulWidget {
  const RegisterFaceScreen({super.key});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  String _result = '';
  final picker = ImagePicker();

  final String baseUrl = "http://10.136.70.2:5001";

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> registerFace() async {
    if (_nameController.text.isEmpty || _image == null) {
      setState(() => _result = "Please enter name and capture photo");
      return;
    }

    var uri = Uri.parse('$baseUrl/register');
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = _nameController.text;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();
    var resData = await http.Response.fromStream(response);
    var jsonRes = json.decode(resData.body);

    setState(() {
      _result = jsonRes['message'] ?? 'Unknown error';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Face')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Enter Name"),
            ),
            const SizedBox(height: 20),
            _image == null
                ? const Icon(Icons.person, size: 120)
                : Image.file(_image!, height: 200),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: pickImage, child: const Text("Capture Face")),
            ElevatedButton(
                onPressed: registerFace, child: const Text("Register")),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
