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
    final data = await _supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();
        
    return Course.fromJson(data);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    // TAHAP 13: Fungsi UPDATE untuk mengubah data di tabel 'courses'
    // Wajib menggunakan .eq('id', id) agar tidak mengubah seluruh data di tabel!
    await _supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id); 
  }

  @override
  Future<void> deleteCourse(int id) async {
    // Akan dikerjakan di Tahap 14
    throw UnimplementedError('Belum diimplementasikan');
  }
}