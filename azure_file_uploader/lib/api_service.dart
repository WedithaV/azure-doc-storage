import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:5032/api/documents'; // for Android emulator

  static Future<String?> uploadFile(File file) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr)['fileUrl'];
    }
    return null;
  }

  static Future<List<String>> listFiles() async {
    final uri = Uri.parse('$baseUrl/list');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    }
    return [];
  }

  static Future<bool> deleteFile(String fileName) async {
    final uri = Uri.parse('$baseUrl/delete/$fileName');
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  static Future<http.Response> downloadFile(String fileName) async {
    final uri = Uri.parse('$baseUrl/download/$fileName');
    return await http.get(uri);
  }
}
