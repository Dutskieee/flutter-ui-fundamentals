import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  // Menggunakan 'supabase' sesuai penamaan di worksheet Tahap 12-15
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id', ascending: true);
        
    return data.map((json) => Course.fromJson(json)).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final data = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();
        
    return Course.fromJson(data);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    // TAHAP 14: UPDATE berdasarkan id
    await supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id); 
  }

  @override
  Future<void> deleteCourse(int id) async {
    // TAHAP 15: DELETE berdasarkan id
    await supabase
        .from('courses')
        .delete()
        .eq('id', id);
  }
}