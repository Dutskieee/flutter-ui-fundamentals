import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString('assets/data/student_data.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
   
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue.shade50, 
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700, 
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  
  Widget buildStatCard(String value, String label, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.white, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade700), 
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade900)), 
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: studentFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          
          final data = snapshot.data!;
          final student = data['student'] as Map<String, dynamic>;
          final courses = data['courses'] as List<dynamic>;
          
          // Kalkulasi Statistik
          final int completed = courses.where((item) => item['status'] == 'done').length;
          final int totalCourses = courses.length;
          
          int totalSks = 0;
          for (var course in courses) {
            totalSks += (course['credits'] as int? ?? 0);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade200, width: 2), 
                          ),
                          child: const CircleAvatar(
                            radius: 32,
                            backgroundImage: AssetImage('assets/images/profile.jpg'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student['name'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                              const SizedBox(height: 4),
                              Text('NIM: ${student['nim']}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              const Text('Kelas: 5-PTI-IKI', style: TextStyle(fontSize: 13, color: Colors.black54)), 
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 36, color: Colors.blue.shade700), // Ikon biru
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$completed/$totalCourses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade900)),
                            const Text('Materi Selesai', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(child: buildStatCard('$totalCourses', 'Mata Kuliah', Icons.menu_book)),
                    const SizedBox(width: 8),
                    Expanded(child: buildStatCard('$totalSks', 'Total SKS', Icons.school)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Text('Daftar Materi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index] as Map<String, dynamic>;
                      final status = course['status'] as String;
                      
                      String statusText;
                      IconData iconData;
                      Color iconColor;
                      
                      if (status == 'done') {
                        statusText = 'Selesai';
                        iconData = Icons.check_circle;
                        iconColor = Colors.blue.shade600;
                      } else if (status == 'active') {
                        statusText = 'Sedang Dipelajari';
                        iconData = Icons.play_circle_filled;
                        iconColor = Colors.blue.shade300; 
                      } else {
                        statusText = 'Direncanakan';
                        iconData = Icons.access_time_filled;
                        iconColor = Colors.grey.shade400; 
                      }
                      
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(iconData, color: iconColor),
                            title: Text(course['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('${course['code']} - ${course['credits']} SKS', style: const TextStyle(fontSize: 12)),
                            trailing: Text(
                              statusText,
                              style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
              ],
            ),
          );
        },
      ),
    );
  }
}