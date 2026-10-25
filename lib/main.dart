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
    // TAHAP 11: Simulasi delay jaringan (agar loading spinner terlihat)
    await Future.delayed(const Duration(seconds: 1));
    
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
// TAHAP 11: COURSE PROVIDER DENGAN ASYNC STATE
// =======================================================
class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;
  
  CourseProvider(this.repository);

  // State untuk Favorites
  final Set<String> _favorites = {};
  Set<String> get favorites => _favorites;

  // TAHAP 11: State untuk Data Loading, Error, & Success
  List<Course> courses = [];
  bool isLoading = false;
  String? error;
  bool _isInitialized = false; // Mencegah load berkali-kali

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
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue, primary: Colors.lightBlue[700]!),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const ResponsiveShell(),
    );
  }
}

// =======================================================
// ARSITEKTUR UTAMA (3 TAB SAJA)
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
    // TAHAP 11: Memicu loadCourses() otomatis saat aplikasi pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = const [
      HomePage(),
      CoursesPage(),
      ProfilePage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.lightBlue[50],
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: IconThemeData(color: Colors.lightBlue[800]),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books), label: Text('Courses')),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: pages[_currentIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.lightBlue[50],
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.library_books_outlined), selectedIcon: Icon(Icons.library_books), label: 'Courses'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

// =======================================================
// REUSABLE WIDGET 1: HEADER IDENTITAS PINTAR
// =======================================================
class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isLandscape ? 8 : 16, horizontal: 24),
      color: Colors.lightBlue[100],
      child: Column(
        children: [
          Text(studentName, style: TextStyle(fontSize: isLandscape ? 16 : 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(studentId, style: TextStyle(fontSize: isLandscape ? 12 : 14, color: Colors.black54)),
        ],
      ),
    );
  }
}

// =======================================================
// WIDGET RINGKASAN
// =======================================================
class CourseSummaryBanner extends StatelessWidget {
  const CourseSummaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // TAHAP 11: Membaca jumlah total dari provider.courses secara dinamis
    final provider = context.watch<CourseProvider>();
    final favoriteCount = provider.favorites.length;
    final totalCourses = provider.courses.length; 

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: Colors.lightBlue[800], size: 20),
              const SizedBox(width: 8),
              Text('Courses: $totalCourses', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text('Favorites: $favoriteCount', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// =======================================================
// HALAMAN 1: HOME
// =======================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _interactionCounter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _interactionCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TAHAP 11: Memantau loading state untuk UI Home
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer - Tahap 11')),
      body: Column(
        children: [
          const StudentHeader(),
          const CourseSummaryBanner(),
          Expanded(
            child: Center(
              child: provider.isLoading 
                ? const CircularProgressIndicator() // TAHAP 11: Tampilkan loading
                : provider.error != null
                  ? Text(provider.error!, style: const TextStyle(color: Colors.red)) // TAHAP 11: Tampilkan error
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_done, size: 64, color: Colors.lightBlue[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'Tahap 11: Async State Provider\n(Loading, Error, Success)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Card(
                            elevation: 2,
                            color: Colors.yellow[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text('Demo Tahap 4: ValueNotifier', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  ValueListenableBuilder<int>(
                                    valueListenable: _interactionCounter,
                                    builder: (context, value, child) {
                                      return Text(
                                        'Tombol ditekan: $value kali',
                                        style: const TextStyle(fontSize: 20, color: Colors.deepOrange),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _interactionCounter.value++; 
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Tambah Interaksi'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// REUSABLE WIDGET 2: COURSE CARD 
// =======================================================
class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool showPreview = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailPage(course: widget.course)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.lightBlue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.course.code, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue[800], fontSize: 12)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(showPreview ? Icons.expand_less : Icons.expand_more, color: Colors.grey[700]),
                        onPressed: () => setState(() => showPreview = !showPreview),
                      ),
                      Consumer<CourseProvider>(
                        builder: (context, provider, child) {
                          final isFavorite = provider.favorites.contains(widget.course.code);
                          return IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                            onPressed: () => context.read<CourseProvider>().toggleFavorite(widget.course.code),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.course.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              
              if (showPreview) ...[
                const SizedBox(height: 6),
                Text('${widget.course.credits} SKS • Status: ${widget.course.status}\n${widget.course.desc}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// HALAMAN 2: COURSES
// =======================================================
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TAHAP 11: Memantau loading state untuk UI Courses
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Course')),
      body: Column(
        children: [
          const StudentHeader(),
          const CourseSummaryBanner(),
          Expanded(
            child: Center(
              child: provider.isLoading
                ? const CircularProgressIndicator() // TAHAP 11: Spinner
                : provider.error != null
                  ? Text(provider.error!, style: const TextStyle(color: Colors.red)) // TAHAP 11: Error msg
                  : provider.courses.isEmpty
                    ? const Text('Tidak ada data courses.') // Kasus kosong
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: provider.courses.length,
                                itemBuilder: (context, index) {
                                  return Padding(padding: const EdgeInsets.only(bottom: 12), child: CourseCard(course: provider.courses[index]));
                                },
                              );
                            }
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.7),
                              itemCount: provider.courses.length,
                              itemBuilder: (context, index) {
                                return CourseCard(course: provider.courses[index]);
                              },
                            );
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// HALAMAN 3: PROFILE
// =======================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Feedback')),
      body: Column(
        children: [
          const StudentHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Kirim Umpan Balik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Pesan', border: OutlineInputBorder(), prefixIcon: Icon(Icons.feedback)),
                          maxLines: 3,
                          validator: (value) => (value == null || value.trim().length < 5) ? 'Minimal 5 karakter' : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terkirim!'), backgroundColor: Colors.green));
                            }
                          },
                          child: const Text('Kirim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// HALAMAN DETAIL
// =======================================================
class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<CourseProvider>().favorites.contains(course.code);

    return Scaffold(
      appBar: AppBar(title: Text(course.code)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(course.desc, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Chip(
                  avatar: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                  label: Text(isFavorite ? 'Status: Favorite' : 'Status: Non-Favorite'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}