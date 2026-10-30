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

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }
}