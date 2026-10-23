import 'package:flutter/material.dart';

const String studentName = 'I Made Duta Aryawan';
const String studentId = '2415051044';

// DATA COURSE
final List<Map<String, dynamic>> courseData = [
  {'code': 'PTI-01', 'title': 'Berpikir Komputasional', 'credits': 3, 'status': 'Active', 'desc': 'Modul ajar CT untuk SMK Fase E.'},
  {'code': 'PTI-02', 'title': 'Mobile UI Flutter', 'credits': 3, 'status': 'Active', 'desc': 'Pengembangan antarmuka responsif.'},
  {'code': 'PTI-03', 'title': 'Jaringan Komputer', 'credits': 2, 'status': 'Planned', 'desc': 'Analisis topologi dan pemetaan IP.'},
  {'code': 'PTI-04', 'title': 'Metodologi Penelitian', 'credits': 2, 'status': 'Completed', 'desc': 'Penyusunan proposal riset EdTech.'},
  {'code': 'PTI-05', 'title': 'Desain Instruksional', 'credits': 3, 'status': 'Active', 'desc': 'Penerapan Kurikulum Merdeka.'},
];

// =======================================================
// TAHAP 5: MEMBUAT CHANGENOTIFIER (STATE MANAGEMENT LOGIC)
// =======================================================
class CourseProvider extends ChangeNotifier {
  final Set<String> _favorites = {};

  // Getter agar favorites tidak bisa dimodifikasi langsung dari luar
  Set<String> get favorites => _favorites;

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    // Wajib dipanggil untuk memberitahu widget listener agar rebuild
    notifyListeners();
  }
}

void main() {
  runApp(const CourseExplorerApp());
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
// (Di tahap 6 nanti, state ini akan digantikan oleh Provider)
// =======================================================
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});
  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _currentIndex = 0;
  
  // Masih menggunakan state lama sebelum dipasang Provider di Tahap 6
  final Set<String> _favorites = {'PTI-01', 'PTI-02'};

  void _handleFavoriteChanged(String code) {
    setState(() {
      if (_favorites.contains(code)) {
        _favorites.remove(code);
      } else {
        _favorites.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        totalCourses: courseData.length,
        favorites: _favorites,
      ),
      CoursesPage(
        favorites: _favorites,
        onFavoriteChanged: _handleFavoriteChanged,
      ),
      const ProfilePage(),
      const DebugPage(),
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
  final int totalCourses;
  final int favoriteCount;

  const CourseSummaryBanner({
    super.key,
    required this.totalCourses,
    required this.favoriteCount,
  });

  @override
  Widget build(BuildContext context) {
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
  final int totalCourses;
  final Set<String> favorites;

  const HomePage({
    super.key,
    required this.totalCourses,
    required this.favorites,
  });

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
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer - Tahap 5')),
      body: Column(
        children: [
          const StudentHeader(),
          CourseSummaryBanner(
            totalCourses: widget.totalCourses,
            favoriteCount: widget.favorites.length,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code, size: 64, color: Colors.lightBlue[400]),
                    const SizedBox(height: 12),
                    const Text(
                      'Tahap 5: ChangeNotifier telah dibuat di kode',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const CourseCard({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                course: course,
                isFavorite: isFavorite,
              ),
            ),
          );
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
                    child: Text(course['code'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue[800], fontSize: 12)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                    onPressed: onFavoriteChanged,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(course['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('${course['credits']} SKS • ${course['status']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
  final Set<String> favorites;
  final ValueChanged<String> onFavoriteChanged;

  const CoursesPage({
    super.key,
    required this.favorites,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Course')),
      body: Column(
        children: [
          const StudentHeader(),
          CourseSummaryBanner(totalCourses: courseData.length, favoriteCount: favorites.length),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: courseData.length,
                        itemBuilder: (context, index) {
                          final code = courseData[index]['code'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CourseCard(course: courseData[index], isFavorite: favorites.contains(code), onFavoriteChanged: () => onFavoriteChanged(code)),
                          );
                        },
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.7),
                      itemCount: courseData.length,
                      itemBuilder: (context, index) {
                        final code = courseData[index]['code'] as String;
                        return CourseCard(course: courseData[index], isFavorite: favorites.contains(code), onFavoriteChanged: () => onFavoriteChanged(code));
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
  final Map<String, dynamic> course;
  final bool isFavorite;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course['code'])),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(course['desc'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                Chip(
                  avatar: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
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