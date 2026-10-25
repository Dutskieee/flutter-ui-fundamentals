// class Course {
//   final String code;
//   final String title;
//   final int credits;
//   final String status;
//   final String desc;

//   Course({
//     required this.code,
//     required this.title,
//     required this.credits,
//     required this.status,
//     required this.desc,
//   });

//   factory Course.fromJson(Map<String, dynamic> json) {
//     return Course(
//       code: json['code'] as String,
//       title: json['title'] as String,
//       credits: json['credits'] as int,
//       status: json['status'] as String,
//       desc: json['desc'] as String? ?? 'Tidak ada deskripsi',
//     );
//   }
// }