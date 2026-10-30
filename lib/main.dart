import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'models/course.dart';
import 'services/course_service.dart';
import 'repositories/course_repository.dart';
import 'providers/course_provider.dart';

const String studentName = 'I Made Duta Aryawan';
const String studentId = '2415051044';
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

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
      title: 'Course Data Manager',
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
    // REVISI: Kata 'const' dihilangkan di sini agar tidak memicu error garis merah
    final List<Widget> pages = [
      const HomePage(),
      const CoursesPage(),
      const FavoritesPage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Course Data Manager')),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))],
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
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                const SizedBox(height: 4),
                Text(studentId, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseSummaryBanner extends StatelessWidget {
  const CourseSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildSummaryBox('Courses', '${provider.courses.length}', Icons.library_books)),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryBox('Favorites', '${provider.favorites.length}', Icons.favorite)),
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

class CourseCardMinimal extends StatelessWidget {
  final Course course;
  const CourseCardMinimal({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<CourseProvider>().favorites.contains(course.code);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(6)),
                      child: Text(course.status.toLowerCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.grey.shade400, size: 28),
                onPressed: () => context.read<CourseProvider>().toggleFavorite(course.code),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> fetchCoursesTest(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GET Sukses! Mengambil ${data.length} item dari API.'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return Column(
      children: [
        const StudentHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () => fetchCoursesTest(context),
            icon: const Icon(Icons.cloud_download),
            label: const Text('Test GET API'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const CourseSummaryBanner(),
        Expanded(
          child: provider.isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: provider.courses.length,
                  itemBuilder: (context, index) => CourseCardMinimal(course: provider.courses[index]),
                ),
        ),
      ],
    );
  }
}

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