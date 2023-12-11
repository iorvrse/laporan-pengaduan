// home_page.dart

import 'package:flutter/material.dart';
import '../pages/form_page.dart';
import '../pages/riwayat_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Laporan Pengaduan PENS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Laporkan jika terjadi keadaan darurat, instansi terdekat akan segera sampai di sana.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  buildCard(
                    'Laporan\nKebersihan',
                    Colors.green,
                    () => navigateToFormPage(context, 'Kebersihan'),
                  ),
                  buildCard(
                    'Laporan\nKehilangan',
                    Colors.blue,
                    () => navigateToFormPage(context, 'Kehilangan'),
                  ),
                  buildCard(
                    'Laporan\nKejahatan',
                    Colors.red,
                    () => navigateToFormPage(context, 'Kejahatan'),
                  ),
                  buildCard(
                    'Riwayat\nLaporan Anda',
                    Colors.black,
                    () => navigateToRiwayatPage(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String title, Color overlayColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5.0,
        child: Stack(
          children: [
            Container(
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: overlayColor,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 40.0,
                    height: 40.0,
                    margin: EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToFormPage(BuildContext context, String laporanType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPage(laporanType: laporanType),
      ),
    );
  }

  void navigateToRiwayatPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiwayatPage(),
      ),
    );
  }
}