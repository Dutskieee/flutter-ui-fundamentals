import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  // Memanggil instance Supabase yang sudah diinisialisasi di main.dart
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    // TAHAP 11: Query GET (Select) ke tabel 'courses' di Supabase
    final data = await _supabase
        .from('courses')
        .select()
        .order('id', ascending: true); // Urutkan berdasarkan ID
        
    return data.map((json) => Course.fromJson(json)).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    // Akan dikerjakan di Tahap 12
    throw UnimplementedError('Belum diimplementasikan');
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    // Akan dikerjakan di Tahap 13
    throw UnimplementedError('Belum diimplementasikan');
  }

  @override
  Future<void> deleteCourse(int id) async {
    // Akan dikerjakan di Tahap 14
    throw UnimplementedError('Belum diimplementasikan');
  }
}