import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const String studentName = 'I Made Duta Aryawan';
const String studentId = '2415051044';

// =======================================================
// MODEL COURSE
// =======================================================
class Course {
  final String code;
  final String title;
  final int credits;
  final String status;
  final String desc;

  Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
    required this.desc,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: json['status'] as String,
      desc: json['desc'] as String? ?? 'Tidak ada deskripsi',
    );
  }
}

// =======================================================
// COURSE SERVICE (DATA SOURCE)
// =======================================================
class CourseService {
  Future<List<Course>> loadCourses() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
    final jsonString = await rootBundle.loadString('assets/data/student_data.json');
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;
    return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// =======================================================
// COURSE REPOSITORY
// =======================================================
class CourseRepository {
  final CourseService service;
  
  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }
}

// =======================================================
// COURSE PROVIDER DENGAN ASYNC STATE
// =======================================================
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

// =======================================================
// MAIN & DEPENDENCY INJECTION
// =======================================================
void main() {
  final courseService = CourseService();
  final courseRepository = CourseRepository(courseService);

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(courseRepository),
      child: const CourseExplorerApp(),
    ),
  );
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer v2',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2), 
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
      home: const ResponsiveShell(),
    );
  }
}

// =======================================================
// ARSITEKTUR UTAMA & CUSTOM BOTTOM NAV
// =======================================================
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});
  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = const [
      HomePage(),
      CoursesPage(),
      FavoritesPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer v2'),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3)),
          ],
        ),
        child: SafeArea( 
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem('Home', 0),
                _buildNavItem('Courses', 1),
                _buildNavItem('Favorites', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF1565C0).withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// UI COMPONENTS
// =======================================================

// 1. Header Identitas dengan Foto Profil (SUDAH DIPERBAIKI)
class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1976D2), width: 2), 
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage('assets/images/profile.jpg'), 
              backgroundColor: Color(0xFFE3F2FD),
              // child: Icon dihapus agar wajah tidak tertimpa
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 4),
                Text(
                  studentId,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Kotak Summary
class CourseSummaryBanner extends StatelessWidget {
  const CourseSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryBox('Courses', '${provider.courses.length}', Icons.library_books),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryBox('Favorites', '${provider.favorites.length}', Icons.favorite),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.blue.shade300),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1))),
        ],
      ),
    );
  }
}

// 3. Card Item Course Minimalis
class CourseCardMinimal extends StatelessWidget {
  final Course course;
  const CourseCardMinimal({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<CourseProvider>().favorites.contains(course.code);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1), 
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.status.toLowerCase(), 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00695C)) 
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : Colors.grey.shade400,
              size: 28,
            ),
            onPressed: () => context.read<CourseProvider>().toggleFavorite(course.code),
          )
        ],
      ),
    );
  }
}

// =======================================================
// HALAMAN 1: HOME
// =======================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Column(
      children: [
        const StudentHeader(),
        const CourseSummaryBanner(),
        Expanded(
          child: provider.isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: provider.courses.length,
                  itemBuilder: (context, index) {
                    return CourseCardMinimal(course: provider.courses[index]);
                  },
                ),
        ),
      ],
    );
  }
}

// =======================================================
// HALAMAN 2 & 3: COURSES & FAVORITES
// =======================================================
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.courses.length,
              itemBuilder: (context, index) => CourseCardMinimal(course: provider.courses[index]),
            ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteCourses = provider.courses.where((c) => provider.favorites.contains(c.code)).toList();

    return Scaffold(
      body: favoriteCourses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada course favorit.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteCourses.length,
              itemBuilder: (context, index) => CourseCardMinimal(course: favoriteCourses[index]),
            ),
    );
  }
}