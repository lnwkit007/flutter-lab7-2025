import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/student.dart';
import 'package:http/http.dart' as http;

import 'package:lab7/config/config_api.dart';

class EditStudentScreen extends StatefulWidget {
  final Student? student;
  const EditStudentScreen({super.key, this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  Student? student;
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String dropdownValue = "";

  @override
  void initState() {
    super.initState();
    student = widget.student!;
    codeController.text = student!.studentCode;
    nameController.text = student!.studentName;
    dropdownValue = student!.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Student",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              int rt = await updateStudent(
                Student(
                  studentCode: codeController.text,
                  studentName: nameController.text,
                  gender: dropdownValue,
                ),
              );

              if (rt == 200) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // พื้นหลังสีขาว
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Student Code Field
              TextField(
                controller: codeController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Student Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge, color: Colors.blue),
                ),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              // Student Name Field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people, color: Colors.blue),
                ),
                items: ['F', 'M'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value == 'M' ? 'Male (M)' : 'Female (F)',
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    int rt = await updateStudent(
                      Student(
                        studentCode: codeController.text,
                        studentName: nameController.text,
                        gender: dropdownValue,
                      ),
                    );

                    if (rt == 200) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<int> updateStudent(Student student) async {
  final response = await http.put(
    Uri.parse(
      '${ConfigAPI.baseUrl}/student.php?url_student_code=${student.studentCode}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': student.studentCode,
      'student_name': student.studentName,
      'gender': student.gender,
    }),
  );

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to update student.');
  }
}
