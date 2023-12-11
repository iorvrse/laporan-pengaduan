<?php

include 'koneksi.php';

$response = array();

try {
    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        // Get data from the request body
        $data = json_decode(file_get_contents("php://input"));

        // Extract data
        $id = $data->id;
        $tipeLaporan = $data->tipe_laporan;
        $namaPelapor = $data->nama_pelapor;
        $teleponPelapor = $data->telepon_pelapor;
        $lokasiKejadian = $data->lokasi_kejadian;
        $tanggalKejadian = $data->tanggal_kejadian;
        $isiLaporan = $data->isi_laporan;

        // Format the date as a string (assuming 'Y-m-d' format)
        $formattedDate = date_format(date_create($tanggalKejadian), 'Y-m-d');

        // SQL query to update data in the database
        $query = "UPDATE laporan SET tipe_laporan=?, nama_pelapor=?, telepon_pelapor=?, lokasi_kejadian=?, tanggal_kejadian=?, isi_laporan=? WHERE id=?";

        // Prepare the SQL statement
        $stmt = $conn->prepare($query);

        // Bind parameters using bindParam
        $stmt->bindParam(1, $tipeLaporan);
        $stmt->bindParam(2, $namaPelapor);
        $stmt->bindParam(3, $teleponPelapor);
        $stmt->bindParam(4, $lokasiKejadian);
        $stmt->bindParam(5, $formattedDate); // Use the formatted date
        $stmt->bindParam(6, $isiLaporan);
        $stmt->bindParam(7, $id); // Bind the ID

        // Execute the statement
        $stmt->execute();

        // Check if any rows were affected
        $rowCount = $stmt->rowCount();

        if ($rowCount > 0) {
            // Set success message
            $response['success'] = true;
            $response['message'] = "Data laporan berhasil diperbarui";
            // You can also include additional information like the updated ID or other relevant details
        } else {
            // No rows were affected, indicating that the ID was not found
            $response['success'] = false;
            $response['message'] = "Data laporan tidak ditemukan";
        }
    }
} catch (Exception $e) {
    // Handle errors and set error message
    $response['success'] = false;
    $response['message'] = "Gagal: " . $e->getMessage();
}

// Output the response as JSON
http_response_code($response['success'] ? 200 : 400);
header('Content-Type: application/json');
echo json_encode($response);

?>