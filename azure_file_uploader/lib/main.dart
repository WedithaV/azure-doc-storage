import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';

void main() {
  runApp(const MaterialApp(home: FileUploadScreen()));
}

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  List<String> fileList = [];

  void pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      final url = await ApiService.uploadFile(file);
      if (url != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Uploaded: $url')));
        loadFileList();
      }
    }
  }

  void loadFileList() async {
    final files = await ApiService.listFiles();
    setState(() {
      fileList = files;
    });
  }

  void deleteFile(String fileName) async {
    final deleted = await ApiService.deleteFile(fileName);
    if (deleted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted $fileName')));
      loadFileList();
    }
  }

  @override
  void initState() {
    super.initState();
    loadFileList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Azure Document Manager')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickAndUpload,
            child: const Text('Pick & Upload File'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (context, index) {
                final fileName = fileList[index];
                return ListTile(
                  title: Text(fileName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteFile(fileName),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
