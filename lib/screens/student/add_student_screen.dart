import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/student.dart';

import 'package:lab7/config/config_api.dart';

class AddStudentScreen extends StatefulWidget {
  final Function()? onStudentAdded;

  const AddStudentScreen({super.key, this.onStudentAdded});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _dropdownValue = "M";
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final student = Student(
        studentCode: _codeController.text.trim(),
        studentName: _nameController.text.trim(),
        gender: _dropdownValue,
      );

      final int statusCode = await addStudent(student);

      if (statusCode == 200) {
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Call callback to refresh parent screen
        if (widget.onStudentAdded != null) {
          widget.onStudentAdded!();
        }

        // Navigate back
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        throw Exception('Failed to add student. Status code: $statusCode');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateStudentCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter student code';
    }
    if (value.length < 3) {
      return 'Student code must be at least 3 characters';
    }
    return null;
  }

  String? _validateStudentName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter student name';
    }
    if (value.length < 2) {
      return 'Student name must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Student"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _addStudent,
              tooltip: 'Save Student',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Student Code Field
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Student Code *',
                  hintText: 'Enter student code (e.g., B1234567)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: _validateStudentCode,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Student Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: _validateStudentName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _dropdownValue,
                onChanged: (String? value) {
                  setState(() {
                    _dropdownValue = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'M',
                    child: Text('Male (M)'),
                  ),
                  DropdownMenuItem(
                    value: 'F',
                    child: Text('Female (F)'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addStudent,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Adding Student...' : 'Save Student',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              // Cancel Button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.cancel),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
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

// API function to add student
Future<int> addStudent(Student student) async {
  final response = await http.post(
    Uri.parse('${ConfigAPI.baseUrl}/student.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': student.studentCode,
      'student_name': student.studentName,
      'gender': student.gender,
    }),
  );

  // Debug print
  print('Add Student - Status code: ${response.statusCode}');
  print('Add Student - Response body: ${response.body}');

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to add student. Server responded with status: ${response.statusCode}');
  }
}