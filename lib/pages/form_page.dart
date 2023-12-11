import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/home_page.dart';

class FormPage extends StatefulWidget {
  final String laporanType;

  FormPage({required this.laporanType});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
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

  TextEditingController _namaPelaporController = TextEditingController();
  TextEditingController _teleponPelaporController = TextEditingController();
  TextEditingController _lokasiKejadianController = TextEditingController();
  TextEditingController _isiLaporanController = TextEditingController();
  TextEditingController _tanggalKejadianController = TextEditingController();

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
    final formattedDate =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    // Kirim data ke server
    final response = await http.post(
      Uri.parse('http://10.0.2.2/laporan_pengaduan/server.php'),
      body: jsonEncode({
        'tipe_laporan': widget.laporanType,
        'nama_pelapor': _namaPelaporController.text,
        'telepon_pelapor': _teleponPelaporController.text,
        'lokasi_kejadian': _lokasiKejadianController.text,
        'tanggal_kejadian': formattedDate,
        'isi_laporan': _isiLaporanController.text,
        'image': base64Encode(await _image!.readAsBytes()),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    // Handle respons dari server
    if (response.statusCode == 200) {
      // Show success SnackBar
      _showSnackBar("Berhasil", "Laporan berhasil dikirim.");

      // Navigate back to the home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Replace HomePage with your home page class
        (route) => false, // This makes sure to remove all previous routes
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
        label: Text("Kirim laporan"),
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
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                // Handle the picked date, you can do something with it if needed
                if (pickedDate != null && pickedDate != DateTime.now()) {
                  print('Selected date: $pickedDate');
                  setState(() {
                    selectedDate = pickedDate;
                    controller.text =
                        "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}";
                  });
                }
              },
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 16.0),
                ),
                enabled: false, // Disable manual editing
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
