<?php
// กำหนดค่า Access-Control-Allow-Origin ให้เครื่องอื่น ๆ สามารถเรียกใช้งานหน้านี้ได้
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: OPTIONS,GET,POST,PUT,DELETE");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// ตั้งค่าการเชื่อมต่อฐานข้อมูล
require_once 'connect_db.php';

$requestMethod = $_SERVER["REQUEST_METHOD"];

// http://IP/test_flutter_lab7/lab7/api/student.php

// Method GET 
if ($requestMethod == 'GET') {

    if (isset($_GET['student_code']) && !empty($_GET['student_code'])) {
        $key_student = $_GET['student_code'];

        $sql = "SELECT * FROM students WHERE student_code = '$key_student'";
    } else {
        $sql = "SELECT * FROM students";
    }

    $result = mysqli_query($link, $sql);

    $arr = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $arr[] = $row;
    }

    echo json_encode($arr);
}


//แปลงข้อมูลทีอ่านได้ เป็น array แล้วเก็บไว้ทีตัวแปร
$data = file_get_contents("php://input");
$result = json_decode($data, true);

// Method POST
if ($requestMethod == 'POST') {
    if (!empty($result)) {
        $student_code = $result['student_code'];
        $student_name = $result['student_name'];
        $gender = $result['gender'];

        $sql = "INSERT INTO students (student_code, student_name, gender) VALUES ('$student_code', '$student_name','$gender')";

        $result = mysqli_query($link, $sql);
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Insert Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error']);
        }
    }
}


// Method PUT
if ($requestMethod == 'PUT') {
    $student_code = $result['student_code'];
    $student_name = $result['student_name'];
    $gender = $result['gender'];

    $sql = "UPDATE students SET student_name = '$student_name' , gender = '$gender' WHERE student_code = '$student_code'";

    $result = mysqli_query($link, $sql);
    if ($result) {
        echo json_encode(['status' => 'ok', 'message' => 'Update Data Complete']);

        echo json_encode([
            'student_code' => $student_code,
            'student_name' => $student_name,
            'gender' => $gender
        ]);
        
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error']);
    }
}


// Method DELETE
if ($requestMethod == 'DELETE') {

    if (isset($_GET['student_code']) && !empty($_GET['student_code'])) {
        $student_code = $_GET['student_code'];

        $sql = "DELETE FROM students WHERE student_code = '$student_code'";

        $result = mysqli_query($link, $sql);
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Delete Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error']);
        }
    }
}
