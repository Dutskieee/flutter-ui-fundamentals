import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await _supabase
        .from('courses')
        .select()
        .order('id', ascending: true);
        
    return data.map((json) => Course.fromJson(json)).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    // TAHAP 12: Fungsi INSERT untuk menambah data ke tabel 'courses'
    // Penambahan .select().single() penting agar Supabase mengembalikan data yang baru di-insert (termasuk ID-nya)
    final data = await _supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();
        
    return Course.fromJson(data);
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