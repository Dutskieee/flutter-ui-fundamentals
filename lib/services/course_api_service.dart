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
}