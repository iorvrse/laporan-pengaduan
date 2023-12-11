<?php

include 'koneksi.php'; // Include your connection file

$response = array();

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        // Get data from the request body
        $data = json_decode(file_get_contents("php://input"));

        // Extract data
        $tipeLaporan = $data->tipe_laporan;
        $namaPelapor = $data->nama_pelapor;
        $teleponPelapor = $data->telepon_pelapor;
        $lokasiKejadian = $data->lokasi_kejadian;
        $tanggalKejadian = $data->tanggal_kejadian;
        $isiLaporan = $data->isi_laporan;
        $imageData = $data->image; // Modify this according to your data structure

        // Decode base64 image data
        $image = base64_decode($imageData);

        // Unique file name to save the image
        $imageName = uniqid() . '.png';

        // Image storage path (adjust according to your folder structure)
        $imagePath = 'uploads/' . $imageName;

        // Save the image to the server
        file_put_contents($imagePath, $image);

        // SQL query to insert data into the database
        $query = "INSERT INTO laporan (tipe_laporan, nama_pelapor, telepon_pelapor, lokasi_kejadian, tanggal_kejadian, isi_laporan, image_path) VALUES (?, ?, ?, ?, ?, ?, ?)";

        // Prepare the SQL statement
        $stmt = $conn->prepare($query);

        // Bind parameters using bindParam
        $stmt->bindParam(1, $tipeLaporan);
        $stmt->bindParam(2, $namaPelapor);
        $stmt->bindParam(3, $teleponPelapor);
        $stmt->bindParam(4, $lokasiKejadian);
        $stmt->bindParam(5, $tanggalKejadian);
        $stmt->bindParam(6, $isiLaporan);
        $stmt->bindParam(7, $imagePath);

        // Execute the statement
        $stmt->execute();

        // Set success message
        $response['message'] = "Data laporan berhasil disimpan";
    }
} catch (Exception $e) {
    // Handle errors and set error message
    $response['message'] = "Gagal: " . $e->getMessage();
}

// Output the response as JSON
echo json_encode($response);

?>