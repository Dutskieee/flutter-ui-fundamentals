import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl);
  final String baseUrl;

  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course (HTTP ${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  // TAHAP 6: Fungsi POST untuk membuat resource baru
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    
    // Menangkap pesan error dari backend (misal error 400 atau 409 duplikat)
    String errMsg = 'Gagal membuat course (HTTP ${response.statusCode})';
    try {
      final errBody = jsonDecode(response.body);
      if (errBody['error'] != null) errMsg = errBody['error'];
    } catch (_) {}
    
    throw Exception(errMsg);
  }
}