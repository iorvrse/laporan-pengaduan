// riwayat_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'update_page.dart';

class RiwayatPage extends StatefulWidget {
  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    // Fetch history data when the page is initialized
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    try {
      // Replace the URL with the actual URL of your PHP script
      final response = await http.get(Uri.parse('http://10.0.2.2/laporan_pengaduan/riwayat.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if there is an error in the response
        if (data.containsKey('error')) {
          // Handle the error, you can show a Snackbar or set an error state
          print('Error: ${data['error']}');
        } else {
          // Set the history data
          setState(() {
            _historyData = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      } else {
        // Handle the error if the server returns an error status code
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors, such as network errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Laporan'),
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildHistoryList() {
    if (_historyData.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: _historyData.length,
        itemBuilder: (context, index) {
          final report = _historyData[index];
          return ListTile(
            title: Text('${report['tipe_laporan']} - ${report['nama_pelapor']}'),
            subtitle: Text(report['tanggal_kejadian']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _navigateToUpdatePage(report);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(report['id'] as int?);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

void _navigateToUpdatePage(Map<String, dynamic> report) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UpdatePage(reportData: report),
    ),
  );
}

  void _showDeleteConfirmationDialog(int? reportId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Anda yakin ingin menghapus laporan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                if (reportId != null) {
                  _deleteReport(reportId);
                } else {
                  // Handle the case where reportId is null (optional)
                  print('Report id is null');
                }
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReport(int reportId) async {
    try {
      // Replace the URL with the actual URL of your PHP script for deleting
      final response = await http.get(Uri.parse('http://10.0.2.2/laporan_pengaduan/delete.php?action=delete&id=$reportId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if there is an error in the response
        if (data.containsKey('error')) {
          // Handle the error, you can show a Snackbar or set an error state
          print('Error: ${data['error']}');
        } else {
          // Report deleted successfully, you can show a success message
          print('Report deleted successfully');
          // Fetch updated history data
          _fetchHistoryData();
        }
      } else {
        // Handle the error if the server returns an error status code
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle other errors, such as network errors
      print('Error: $e');
    }
  }

}
