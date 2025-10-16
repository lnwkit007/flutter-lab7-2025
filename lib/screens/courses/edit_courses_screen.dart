import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/courses.dart';

import 'package:lab7/config/config_api.dart';

class EditCourseScreen extends StatefulWidget {
  final Course? course;
  final Function()? onCourseUpdated;

  const EditCourseScreen({super.key, this.course, this.onCourseUpdated});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  Course? course;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    course = widget.course!;
    _codeController.text = course!.courseCode;
    _nameController.text = course!.courseName;
    _creditController.text = course!.credit;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  Future<void> _updateCourse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCourse = Course(
        courseCode: _codeController.text.trim(),
        courseName: _nameController.text.trim(),
        credit: _creditController.text.trim(),
      );

      final int statusCode = await updateCourse(course!.courseCode, updatedCourse);

      if (statusCode == 200) {
        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Call callback to refresh parent screen
        if (widget.onCourseUpdated != null) {
          widget.onCourseUpdated!();
        }

        // Navigate back
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update course. Status code: $statusCode');
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

  String? _validateCourseName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter course name';
    }
    if (value.length < 5) {
      return 'Course name must be at least 5 characters';
    }
    return null;
  }

  String? _validateCredit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter credit';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    final credit = int.parse(value);
    if (credit < 0) {
      return 'Credit cannot be negative';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Course",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
              onPressed: _updateCourse,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Course Code Field (Disabled)
              TextField(
                controller: _codeController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code, color: Colors.blue),
                ),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Course Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name *',
                  hintText: 'Enter course name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school, color: Colors.blue),
                ),
                validator: _validateCourseName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Credit Field
              TextFormField(
                controller: _creditController,
                decoration: const InputDecoration(
                  labelText: 'Credit *',
                  hintText: 'Enter credit (any positive number)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card, color: Colors.blue),
                ),
                validator: _validateCredit,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _updateCourse,
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
                    _isLoading ? 'Updating Course...' : 'Update Course',
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

// API function to update course
Future<int> updateCourse(String oldCourseCode, Course course) async {
  final response = await http.put(
    Uri.parse(
      '${ConfigAPI.baseUrl}/courses.php?course_code=$oldCourseCode',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'course_code': course.courseCode,
      'course_name': course.courseName,
      'credit': course.credit,
    }),
  );

  // Debug print
  print('Update Course - Status code: ${response.statusCode}');
  print('Update Course - Response body: ${response.body}');

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to update course. Server responded with status: ${response.statusCode}');
  }
}