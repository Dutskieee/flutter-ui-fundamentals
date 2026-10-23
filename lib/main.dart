import 'dart:convert'; // TAHAP 9: Untuk jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TAHAP 9: Untuk rootBundle
import 'package:provider/provider.dart';

const String studentName = 'I Made Duta Aryawan';
const String studentId = '2415051044';

// =======================================================
// TAHAP 8: MODEL COURSE
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
// TAHAP 9: COURSE SERVICE (DATA SOURCE)
// Bertanggung jawab murni untuk membaca data JSON dari aset
// =======================================================
class CourseService {
  Future<List<Course>> loadCourses() async {
    // Membaca file JSON dari asset
    final jsonString = await rootBundle.loadString('assets/data/student_data.json');
    // Parsing string ke Map JSON
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    // Mengambil list yang ada di key 'courses'
    final list = data['courses'] as List<dynamic>;
    // Mapping list dynamic menjadi List<Course>
    return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// DATA JSON MENTAH SEMENTARA (Akan diganti full dengan Service di Tahap 11)
final List<Map<String, dynamic>> rawCourseData = [
  {'code': 'PTI-01', 'title': 'Berpikir Komputasional', 'credits': 3, 'status': 'Active', 'desc': 'Modul ajar CT untuk SMK Fase E.'},
  {'code': 'PTI-02', 'title': 'Mobile UI Flutter', 'credits': 3, 'status': 'Active', 'desc': 'Pengembangan antarmuka responsif.'},
  {'code': 'PTI-03', 'title': 'Jaringan Komputer', 'credits': 2, 'status': 'Planned', 'desc': 'Analisis topologi dan pemetaan IP.'},
  {'code': 'PTI-04', 'title': 'Metodologi Penelitian', 'credits': 2, 'status': 'Completed', 'desc': 'Penyusunan proposal riset EdTech.'},
  {'code': 'PTI-05', 'title': 'Desain Instruksional', 'credits': 3, 'status': 'Active', 'desc': 'Penerapan Kurikulum Merdeka.'},
];
final List<Course> coursesList = rawCourseData.map((e) => Course.fromJson(e)).toList();

// =======================================================
// TAHAP 5-7: CHANGENOTIFIER
// =======================================================
class CourseProvider extends ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

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
// MAIN & PROVIDER SETUP
// =======================================================
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(),
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
// ARSITEKTUR UTAMA
// =======================================================
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});
  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = const [
      HomePage(),
      CoursesPage(),
      ProfilePage(),
      DebugPage(),
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
                    NavigationRailDestination(icon: Icon(Icons.bug_report_outlined), selectedIcon: Icon(Icons.bug_report), label: Text('Debug')),
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
              NavigationDestination(icon: Icon(Icons.bug_report_outlined), selectedIcon: Icon(Icons.bug_report), label: 'Debug'),
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
    final favoriteCount = context.watch<CourseProvider>().favorites.length;
    final totalCourses = coursesList.length; 

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
  
  // TAHAP 9: Local state loading khusus untuk tombol uji coba Service
  bool _isTestingService = false;

  @override
  void dispose() {
    _interactionCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer - Tahap 9')),
      body: Column(
        children: [
          const StudentHeader(),
          const CourseSummaryBanner(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storage, size: 64, color: Colors.lightBlue[400]),
                    const SizedBox(height: 12),
                    const Text(
                      'Tahap 9: CourseService\n(Membaca student_data.json)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // TAHAP 9: Tombol untuk menguji CourseService
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _isTestingService ? null : () async {
                        setState(() => _isTestingService = true);
                        try {
                          // Memanggil service secara langsung untuk uji coba
                          final service = CourseService();
                          final data = await service.loadCourses();
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('SUKSES! Berhasil membaca ${data.length} course dari JSON asli.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ERROR: $e\n(Pastikan assets di pubspec.yaml sudah benar!)'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isTestingService = false);
                        }
                      },
                      icon: _isTestingService 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.file_download),
                      label: Text(_isTestingService ? 'Loading JSON...' : 'Uji Coba loadCourses()'),
                    ),
                    const SizedBox(height: 24),

                    // Kotak Demo ValueNotifier
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
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Course')),
      body: Column(
        children: [
          const StudentHeader(),
          const CourseSummaryBanner(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: coursesList.length,
                        itemBuilder: (context, index) {
                          return Padding(padding: const EdgeInsets.only(bottom: 12), child: CourseCard(course: coursesList[index]));
                        },
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.7),
                      itemCount: coursesList.length,
                      itemBuilder: (context, index) {
                        return CourseCard(course: coursesList[index]);
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
// HALAMAN 4: DEBUG
// =======================================================
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  bool isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debugging')),
      body: Column(
        children: [
          const StudentHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Kasus A: Text Panjang di Row', style: TextStyle(fontWeight: FontWeight.bold)),
                      Card(
                        elevation: 2,
                        color: Colors.lightBlue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: const [
                              Icon(Icons.info, color: Colors.lightBlue),
                              SizedBox(width: 8),
                              Expanded(child: Text('Teks ini sangat panjang dan akan menyebabkan overflow jika tidak dibungkus menggunakan Expanded.')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Kasus B: ListView dalam Column', style: TextStyle(fontWeight: FontWeight.bold)),
                      Card(
                        elevation: 2,
                        color: Colors.lightBlue[50],
                        child: Container(
                          height: 120,
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daftar Item:'),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) => Text('- Item List ${index + 1}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Kasus C: Pancingan Keyboard', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Tap di sini (Layar tidak akan error)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Kasus D: Cegah Navigasi Ganda', style: TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: isNavigating ? null : () async {
                          setState(() => isNavigating = true);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Scaffold(
                              appBar: AppBar(title: const Text('Halaman Dummy')),
                              body: const Center(child: Text('Berhasil pindah halaman!')),
                            )),
                          );
                          if (mounted) setState(() => isNavigating = false);
                        },
                        child: const Text('Buka Halaman (Tap Cepat!)'),
                      ),
                    ],
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