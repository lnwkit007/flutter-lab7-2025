class ExamResult {
  final int id;
  final String courseCode;
  final String studentCode;
  final String point;

  ExamResult({
    required this.id,
    required this.courseCode,
    required this.studentCode,
    required this.point,
  });

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น ExamResult object
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: int.parse(json['id']),
      courseCode: json['course_code'],
      studentCode: json['student_code'],
      point: json['point'],
    );
  }

  // Method สำหรับแปลง object เป็น JSON (ใช้กับ POST, PUT)
  Map<String, dynamic> toJson() {
    return {
      'course_code': courseCode,
      'student_code': studentCode,
      'point': point,
    };
  }
}