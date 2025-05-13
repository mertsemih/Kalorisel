import 'package:flutter/material.dart';

class KaloriIpucuPage extends StatelessWidget {
  final List<Map<String, dynamic>> yemekler = [
    {"isim": "1 tabak pilav", "kalori": 220},
    {"isim": "1 tabak makarna", "kalori": 270},
    {"isim": "100g tavuk göğsü", "kalori": 165},
    {"isim": "100g biftek", "kalori": 250},
    {"isim": "1 kase salata", "kalori": 60},
    {"isim": "1 haşlanmış yumurta", "kalori": 78},
    {"isim": "1 dilim ekmek", "kalori": 70},
    {"isim": "1 dilim pizza", "kalori": 280},
    {"isim": "1 hamburger", "kalori": 550},
    {"isim": "1 küçük patates kızartması", "kalori": 300},
    {"isim": "1 bardak süt", "kalori": 150},
    {"isim": "1 dilim kek", "kalori": 165},
    {"isim": "1 adet elma", "kalori": 95},
    {"isim": "1 adet portakal", "kalori": 60},
    {"isim": "1 kare bitter çikolata", "kalori": 50},
    {"isim": "1 adet donut", "kalori": 400},
    {"isim": "1 kutu kola", "kalori": 140},
    {"isim": "1 dilim pasta", "kalori": 350},
    {"isim": "1 kase çorba", "kalori": 90},
    {"isim": "1 avuç üzüm", "kalori": 65},
    {"isim": "1 salatalık", "kalori": 8},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Kalori İpuçları", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.only(top: kToolbarHeight + 16, left: 12, right: 12),
        child: ListView.builder(
          itemCount: yemekler.length,
          itemBuilder: (context, index) {
            final yemek = yemekler[index];
            return ListTile(
              title: Text(yemek["isim"], style: TextStyle(color: Colors.white)),
              subtitle: Text('${yemek["kalori"]} kcal', style: TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, yemek);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
