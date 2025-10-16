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

// http://IP/test_flutter_lab7/lab-7/api/courses.php

// Method GET 
if ($requestMethod == 'GET') {

    if (isset($_GET['course_code']) && !empty($_GET['course_code'])) {
        $key_course = $_GET['course_code'];

        $sql = "SELECT * FROM courses WHERE course_code = '$key_course'";
    } else {
        $sql = "SELECT * FROM courses";
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
        $course_name = $result['course_name'];
        $credit = $result['credit'];

        $sql = "INSERT INTO courses (course_code, course_name, credit) VALUES ('$course_code', '$course_name', '$credit')";

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
    $key_course = $_GET['course_code']; 

    $course_code = $result['course_code'];
    $course_name = $result['course_name'];
    $credit = $result['credit'];

    $sql = "UPDATE courses SET course_code = '$course_code' , course_name = '$course_name' , credit = '$credit' WHERE course_code = '$key_course'";

    $result = mysqli_query($link, $sql);
    if ($result) {
        echo json_encode(['status' => 'ok', 'message' => 'Update Data Complete']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error']);
    }
}


// Method DELETE
if ($requestMethod == 'DELETE') {

    if (isset($_GET['course_code']) && !empty($_GET['course_code'])) {
        $key_course = $_GET['course_code'];

        $sql = "DELETE FROM courses WHERE course_code = '$key_course'";

        $result = mysqli_query($link, $sql);
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Delete Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error']);
        }
    }
}

?>