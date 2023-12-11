<?php

include 'koneksi.php';

$response = null;

try {
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        // Query to select all records from the laporan table
        $query = "SELECT * FROM laporan";

        // Prepare the SQL statement
        $stmt = $conn->prepare($query);

        // Execute the statement
        $stmt->execute();

        // Fetch all rows as an associative array
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Set the response data
        $response['data'] = $data;
    }
} catch (Exception $e) {
    // Handle errors and set an error message
    $response['error'] = "Error: " . $e->getMessage();
}

// Send the response as JSON
echo json_encode($response);

?>