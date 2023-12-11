// update_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class UpdatePage extends StatefulWidget {
  final Map<String, dynamic> reportData;

  UpdatePage({required this.reportData});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late String laporanType;
  late TextEditingController _namaPelaporController;
  late TextEditingController _teleponPelaporController;
  late TextEditingController _lokasiKejadianController;
  late TextEditingController _isiLaporanController;
  late TextEditingController _tanggalKejadianController;

  @override
  void initState() {
    super.initState();

    laporanType = widget.reportData['tipe_laporan'] ?? '';
    
    _namaPelaporController = TextEditingController(text: widget.reportData['nama_pelapor'] ?? '');
    _teleponPelaporController = TextEditingController(text: widget.reportData['telepon_pelapor'] ?? '');
    _lokasiKejadianController = TextEditingController(text: widget.reportData['lokasi_kejadian'] ?? '');
    _isiLaporanController = TextEditingController(text: widget.reportData['isi_laporan'] ?? '');

    // Set selectedDate based on widget.reportData
    final dateFromString = widget.reportData['tanggal_kejadian'] != null
        ? DateTime.parse(widget.reportData['tanggal_kejadian'])
        : DateTime(0, 0, 0); // Set a default value if 'tanggal_kejadian' is null
    selectedDate = dateFromString;

    _tanggalKejadianController = TextEditingController(
      text: "${dateFromString.day.toString().padLeft(2, '0')}/${dateFromString.month.toString().padLeft(2, '0')}/${dateFromString.year}",
    );
    print(_tanggalKejadianController);
  }

  File? _image;
  DateTime? selectedDate;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeri'),
              onTap: () async {
                await _getImage(ImageSource.gallery);
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Kamera'),
              onTap: () async {
                await _getImage(ImageSource.camera);
                Navigator.pop(context); // Close the bottom sheet
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendDataToDatabase() async {
    // Validasi form
    if (_namaPelaporController.text.isEmpty ||
        _teleponPelaporController.text.isEmpty ||
        _lokasiKejadianController.text.isEmpty ||
        _tanggalKejadianController.text.isEmpty ||
        _isiLaporanController.text.isEmpty ||
        _image == null ||
        selectedDate == null) {
      // Tampilkan pesan jika ada field yang kosong
      _showSnackBar("Lengkapi Form", "Semua kolom harus diisi, termasuk tanggal dan gambar harus diunggah.");
      return;
    }

    // Format selectedDate as 'YYYY-MM-DD' for MySQL
    final formattedDate = selectedDate != null
        ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
        : '';

    // Kirim data ke server
    final response = await http.post(
      Uri.parse('http://10.0.2.2/laporan_pengaduan/update.php'),
      body: jsonEncode({
        'id': widget.reportData['id'],  // Add the id field here
        'tipe_laporan': laporanType,
        'nama_pelapor': _namaPelaporController.text,
        'telepon_pelapor': _teleponPelaporController.text,
        'lokasi_kejadian': _lokasiKejadianController.text,
        'tanggal_kejadian': formattedDate,
        'isi_laporan': _isiLaporanController.text,
        'image': base64Encode(await _image!.readAsBytes()),
      }),
        headers: {'Content-Type': 'application/json'},
      );

      // Handle response dari server
      if (response.statusCode == 200) {
        // Show success SnackBar
        _showSnackBar("Berhasil", "Laporan berhasil dikirim.");

        // Navigate back to the home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        // Show error SnackBar
        _showSnackBar("Gagal", "Terjadi kesalahan saat mengirim laporan. Silakan coba lagi.");
      }
    }

  void _showSnackBar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Form Laporan",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoCard(),
              buildImageCard(),
              buildTextInput("Nama Pelapor", "Masukkan nama Anda", TextInputType.text, _namaPelaporController),
              buildTextInput("Telepon Pelapor", "Masukkan telepon Anda", TextInputType.number, _teleponPelaporController),
              buildTextInput("Lokasi Kejadian", "Masukkan lokasi kejadian", TextInputType.multiline, _lokasiKejadianController, isMultiline: true),
              buildDatePickerInput(context, "Tanggal Kejadian", "Pilih tanggal", _tanggalKejadianController),
              buildTextInputIsiLaporan(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _sendDataToDatabase();
        },
        label: Text("Uodate laporan"),
        icon: Icon(Icons.send),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.0),
      color: Colors.redAccent,
      child: Row(
        children: [
          Icon(
            Icons.info,
            size: 24.0,
            color: Colors.white,
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              "Mohon jangan berikan laporan palsu!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 20.0),
      elevation: 5.0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unggah Foto Bukti Laporan",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                InkWell(
                  onTap: () async {
                    await _showImageSourceDialog();
                  },
                  child: Card(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      height: 150.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Color(0xFFC1C1C1),
                      ),
                      child: _image == null
                          ? Center(
                              child: Icon(
                                Icons.cloud_upload,
                                size: 80.0,
                                color: Colors.white,
                              ),
                            )
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget buildTextInput(String label, String hint, TextInputType inputType, TextEditingController controller, {bool isMultiline = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: 20.0),
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              keyboardType: inputType,
              controller: controller,
              maxLines: isMultiline ? null : 1,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDatePickerInput(BuildContext context, String label, String hint, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 20.0),
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            InkWell(
              onTap: () async {
                // Show date picker
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                // Handle the picked date, you can do something with it if needed
                if (pickedDate != null) {
                  print('Selected date: $pickedDate');
                  setState(() {
                    selectedDate = pickedDate;
                    controller.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  });
                }
              },
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 16.0),
                ),
                enabled: false, // Set to false to disable manual editing
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextInputIsiLaporan() {
    return Card(
      margin: EdgeInsets.only(bottom: 20.0),
      elevation: 5.0,
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Isi Laporan",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              keyboardType: TextInputType.multiline,
              controller: _isiLaporanController,
              maxLines: null, // Set maxLines to null for multiline input
              decoration: InputDecoration(
                hintText: "Masukkan laporan Anda",
                hintStyle: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}