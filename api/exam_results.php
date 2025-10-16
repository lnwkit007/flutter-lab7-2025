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


// Method GET 
if ($requestMethod == 'GET') {

    if (isset($_GET['course_code']) && !empty($_GET['course_code']) && isset($_GET['student_code']) && !empty($_GET['student_code'])) {
        $key_course = $_GET['course_code'];
        $key_student = $_GET['student_code'];

        $sql = "SELECT * FROM exam_results WHERE course_code = '$key_course' AND student_code = '$key_student' ";
    } else {
        // แสดงข้อมูลทั้งหมด
        $sql = "SELECT * FROM exam_results";
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
        $course_code = $result['course_code'];
        $student_code = $result['student_code'];
        $point = $result['point'];

        $sql = "INSERT INTO exam_results (course_code, student_code, point) VALUES ('$course_code', '$student_code', '$point')";

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

    $id = $_GET['id'];

    $course_code = $result['course_code'];
    $student_code = $result['student_code'];
    $point = $result['point'];

    $sql = "UPDATE exam_results SET course_code = '$course_code', student_code = '$student_code', point = '$point' WHERE id = '$id'";

    $result = mysqli_query($link, $sql);
    if ($result) {
        echo json_encode(['status' => 'ok', 'message' => 'Update Data Complete']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error']);
    }
}


// Method DELETE
if ($requestMethod == 'DELETE') {

    if (isset($_GET['id']) && isset($_GET['id'])) {
        $id = $_GET['id'];

        $sql = "DELETE FROM exam_results WHERE id = '$id'";

        $result = mysqli_query($link, $sql);
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Delete Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error']);
        }
    }
}

?>