import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import 'course_data_source.dart'; // IMPORT KONTRAK

// TAHAP 9: Class ini sekarang mengimplementasikan CourseDataSource
class CourseApiService implements CourseDataSource {
  CourseApiService(this.baseUrl);
  final String baseUrl;

  @override
  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course (HTTP ${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    
    String errMsg = 'Gagal membuat course (HTTP ${response.statusCode})';
    try {
      final errBody = jsonDecode(response.body);
      if (errBody['error'] != null) errMsg = errBody['error'];
    } catch (_) {}
    
    throw Exception(errMsg);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errMsg = 'Gagal memperbarui course (HTTP ${response.statusCode})';
      try {
        final errBody = jsonDecode(response.body);
        if (errBody['error'] != null) errMsg = errBody['error'];
      } catch (_) {}
      throw Exception(errMsg);
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/courses/$id'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal menghapus course (HTTP ${response.statusCode})');
    }
  }
}