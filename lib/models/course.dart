class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned', // Nilai default jika API tidak mengirimkan status
  });

  // TAHAP 3: Konversi dari JSON ke Object Dart
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: (json['status'] as String?) ?? 'planned',
    );
  }

  // TAHAP 3: Konversi dari Object Dart ke JSON (untuk POST/PUT nantinya)
  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'credits': credits,
        'status': status,
      };
}