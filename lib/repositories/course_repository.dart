import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;
  
  CourseRepository(this.service);

  Future<List<Course>> getCourses() => service.getCourses();

  // TAHAP 6: Meneruskan data ke service
  Future<Course> createCourse(Course course) => service.createCourse(course);
}