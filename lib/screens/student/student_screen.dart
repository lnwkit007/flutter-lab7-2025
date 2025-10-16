import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/student.dart';

import 'package:lab7/config/config_api.dart';

import 'edit_student_screen.dart';
import 'add_student_screen.dart';

class StudentScreen extends StatefulWidget {

  static const routeName = '/';
  const StudentScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _StudentScreenState();
  }
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<List<Student>> students;
  @override
  void initState() {
    super.initState();
    students = fetchStudents();
  }

  void _refreshData() {
    setState(() {
      students = fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStudentScreen(
                    onStudentAdded: _refreshData,
                  ),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // เปลี่ยนเป็นสีขาว
        child: Center(
          child: FutureBuilder<List<Student>>(
            future: students,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                );
              }
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Total ${snapshot.data!.length} items',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: snapshot.data!.isNotEmpty
                          ? ListView.separated(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: snapshot.data![index].gender == 'M' 
                                          ? Colors.blue[100] 
                                          : Colors.pink[100],
                                      child: Icon(
                                        snapshot.data![index].gender == 'M' 
                                            ? Icons.man 
                                            : Icons.woman,
                                        color: snapshot.data![index].gender == 'M' 
                                            ? Colors.blue 
                                            : Colors.pink,
                                      ),
                                    ),
                                    title: Text(
                                      snapshot.data![index].studentName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      snapshot.data![index].studentCode,
                                    ),
                                    trailing: Wrap(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditStudentScreen(
                                                  student: snapshot.data![index],
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.edit, color: Colors.blue),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) => AlertDialog(
                                                title: Text('Confirm Delete'),
                                                content: Text(
                                                  "Do you want to delete: ${snapshot.data![index].studentCode}?",
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: Colors.redAccent,
                                                    ),
                                                    onPressed: () async {
                                                      await deleteStudent(
                                                        snapshot.data![index],
                                                      );
                                                      setState(() {
                                                        students = fetchStudents();
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: Colors.blue,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Close'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.delete, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school,
                                    size: 64,
                                    color: Colors.blue[300],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No students found',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      size: 64,
                      color: Colors.blue[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                );
              }
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

Future<List<Student>> fetchStudents() async {
  final response = await http.get(
    Uri.parse("${ConfigAPI.baseUrl}/student.php"),
  );
  if (response.statusCode == 200) {
    return compute(parsestudents, response.body);
  } else {
    throw Exception('Failed to load Student');
  }
}

List<Student> parsestudents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

Future<int> deleteStudent(Student student) async {
  final response = await http.delete(
    Uri.parse(
      '${ConfigAPI.baseUrl}?student_code=${student.studentCode}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to delete student.');
  }
}