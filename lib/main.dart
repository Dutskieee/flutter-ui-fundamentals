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
// ARSITEKTUR UTAMA (PARENT PEMILIK STATE DI TAHAP 2)
// =======================================================
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});
  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _currentIndex = 0;

  // TAHAP 2: Satu nilai favorites pada parent (ResponsiveShell)
  final Set<String> _favorites = {'PTI-01'};

  // Callback pada parent untuk mengubah favorites
  void _toggleFavorite(String code) {
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
    // TAHAP 2: Meneruskan nilai favorites & callback ke child melalui constructor (Prop Drilling)
    final List<Widget> pages = [
      HomePage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
      ),
      CoursesPage(
        favorites: _favorites,
        onToggleFavorite: _toggleFavorite,
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
// WIDGET PERANTARA (MENUNJUKKAN PROP DRILLING DI TAHAP 2)
// Widget ini sebenarnya tidak butuh favorites, tapi terpaksa
// menerimanya di constructor hanya untuk diteruskan ke CourseCard!
// =======================================================
class CourseListSection extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const CourseListSection({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courseData.length,
            itemBuilder: (context, index) {
              final course = courseData[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CourseCard(
                  course: course,
                  isFavorite: favorites.contains(course['code']),
                  onToggleFavorite: () => onToggleFavorite(course['code']),
                ),
              );
            },
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.7,
          ),
          itemCount: courseData.length,
          itemBuilder: (context, index) {
            final course = courseData[index];
            return CourseCard(
              course: course,
              isFavorite: favorites.contains(course['code']),
              onToggleFavorite: () => onToggleFavorite(course['code']),
            );
          },
        );
      },
    );
  }
}

// =======================================================
// REUSABLE WIDGET 2: COURSE CARD (CHILD LEVE TERBAWAH)
// =======================================================
class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const CourseCard({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                course: widget.course,
                isFavorite: widget.isFavorite,
                onToggleFavorite: widget.onToggleFavorite,
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
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.course['code'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          showPreview ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey[700],
                        ),
                        onPressed: () => setState(() => showPreview = !showPreview),
                      ),
                      // Mengirim callback ke parent pemilik state
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: widget.onToggleFavorite,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.course['title'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showPreview) ...[
                const SizedBox(height: 6),
                Text(
                  '${widget.course['credits']} SKS • Status: ${widget.course['status']}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// HALAMAN 1: HOME (CHILD 1 YANG MENERIMA FAVORITES)
// =======================================================
class HomePage extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const HomePage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer - Tahap 2')),
      body: Column(
        children: [
          const StudentHeader(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_tree_outlined, size: 64, color: Colors.lightBlue[400]),
                    const SizedBox(height: 12),
                    const Text(
                      'Tahap 2: Prop Drilling & State Ownership',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Menampilkan ringkasan dari state parent
                    Card(
                      color: Colors.lightBlue[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              'Total Favorites: ${favorites.length}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Kode Favorit: ${favorites.isEmpty ? "-" : favorites.join(", ")}'),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => onToggleFavorite('PTI-02'),
                              icon: const Icon(Icons.favorite),
                              label: const Text('Toggle Favorite PTI-02 dari Home'),
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
// HALAMAN 2: COURSES (CHILD 2 YANG MENERIMA & MENERUSKAN FAVORITES)
// =======================================================
class CoursesPage extends StatelessWidget {
  final Set<String> favorites;
  final ValueChanged<String> onToggleFavorite;

  const CoursesPage({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Course (Fav: ${favorites.length})')),
      body: Column(
        children: [
          const StudentHeader(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                // Prop Drilling lanjut ke CourseListSection -> CourseCard
                child: CourseListSection(
                  favorites: favorites,
                  onToggleFavorite: onToggleFavorite,
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
  final VoidCallback onToggleFavorite;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onToggleFavorite,
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
                  label: Text(isFavorite ? 'Tersimpan di Favorit' : 'Belum Favorit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}