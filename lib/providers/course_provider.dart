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
  bool isSaving = false; // TAHAP 6: Flag agar tombol submit tidak bisa di-spam
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

  // TAHAP 6: Fungsi tambah course ke state
  Future<bool> addCourse(Course course) async {
    isSaving = true;
    notifyListeners(); // Tampilkan animasi loading di tombol
    
    try {
      await repository.createCourse(course);
      _isInitialized = false; // Reset agar list memaksa refresh
      await loadCourses();    // Refresh data dari API
      return true;
    } catch (e) {
      throw Exception(e.toString()); // Lempar error untuk ditangkap UI (SnackBar)
    } finally {
      isSaving = false;
      notifyListeners(); // Matikan animasi loading
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