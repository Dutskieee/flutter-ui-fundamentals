import 'package:flutter/material.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;
  
  CourseProvider(this.repository);

  final Set<String> _favorites = {};
  Set<String> get favorites => _favorites;

  List<Course> courses = [];
  bool isLoading = false;
  bool isSaving = false; 
  String? error;
  bool _isInitialized = false;

  Future<void> loadCourses() async {
    if (_isInitialized) return; 
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
      _isInitialized = true;
    } catch (e) {
      error = "Gagal memuat data: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCourse(Course course) async {
    isSaving = true;
    notifyListeners(); 
    try {
      await repository.createCourse(course);
      _isInitialized = false; 
      await loadCourses();    
      return true;
    } catch (e) {
      throw Exception(e.toString()); 
    } finally {
      isSaving = false;
      notifyListeners(); 
    }
  }

  Future<bool> editCourse(int id, Course course) async {
    isSaving = true;
    notifyListeners();
    try {
      await repository.updateCourse(id, course);
      _isInitialized = false; 
      await loadCourses();    
      return true;
    } catch (e) {
      throw Exception(e.toString()); 
    } finally {
      isSaving = false;
      notifyListeners(); 
    }
  }

  // TAHAP 8: Fungsi hapus course
  Future<bool> removeCourse(int id, String courseCode) async {
    isSaving = true;
    notifyListeners();
    try {
      await repository.deleteCourse(id);
      
      // TAHAP 8: Hapus dari favorit agar tidak yatim
      if (_favorites.contains(courseCode)) {
        _favorites.remove(courseCode);
      }
      
      _isInitialized = false; 
      await loadCourses();    
      return true;
    } catch (e) {
      throw Exception(e.toString()); 
    } finally {
      isSaving = false;
      notifyListeners(); 
    }
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }
}