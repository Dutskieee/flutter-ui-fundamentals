import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;
  
  CourseRepository(this.service);

  Future<List<Course>> getCourses() => service.getCourses();
  Future<Course> createCourse(Course course) => service.createCourse(course);
  Future<void> updateCourse(int id, Course course) => service.updateCourse(id, course);
  
  // TAHAP 8: Meneruskan perintah delete ke service
  Future<void> deleteCourse(int id) => service.deleteCourse(id);
}