<?php

include 'koneksi.php'; // Adjust the filename as per your connection file

$response = null;

try {
    if ($_SERVER['REQUEST_METHOD'] == 'GET' && isset($_GET['action'])) {
        // Check if the action is to delete
        if ($_GET['action'] == 'delete' && isset($_GET['id'])) {
            $id = $_GET['id'];
            
            // Query to delete the record from the laporan table
            $query = "DELETE FROM laporan WHERE id = ?";
            
            // Prepare the SQL statement
            $stmt = $conn->prepare($query);
            
            // Bind the parameter
            $stmt->bindParam(1, $id);
            
            // Execute the statement
            $stmt->execute();
            
            // Set the response message
            $response['message'] = "Laporan berhasil dihapus";
        }
    }
} catch (Exception $e) {
    // Handle errors and set an error message
    $response['error'] = "Error: " . $e->getMessage();
}

// Send the response as JSON
echo json_encode($response);

?>