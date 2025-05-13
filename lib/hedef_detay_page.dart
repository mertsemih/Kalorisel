import 'package:flutter/material.dart';

class HedefDetayPage extends StatelessWidget {
  final Map<String, dynamic> hedef;

  const HedefDetayPage({required this.hedef});

  @override
  Widget build(BuildContext context) {
    final double gunluk = hedef['gunlukKaloriHedefi'];
    final DateTime bas = DateTime.parse(hedef['baslangicTarih']);
    final DateTime bitis = DateTime.parse(hedef['bitisTarih']);
    final kalanGun = bitis.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hedef['baslik'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bilgiSatiri("Başlangıç", bas.toLocal().toString().split(' ')[0]),
              _bilgiSatiri("Bitiş", bitis.toLocal().toString().split(' ')[0]),
              SizedBox(height: 12),
              _bilgiSatiri("Başlangıç Kilo", "${hedef['baslangicKilo']} kg"),
              _bilgiSatiri("Hedef Kilo", "${hedef['hedefKilo']} kg"),
              SizedBox(height: 24),
              Text(
                "Hedeflenen günlük kalori farkı: ${gunluk.toStringAsFixed(0)} kcal",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              _bilgiSatiri("Kalan gün", "$kalanGun"),
              Text(
                "Bugün yaklaşık ${gunluk.toStringAsFixed(0)} kcal ${gunluk < 0 ? 'daha az' : 'fazla'} almalısınız",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bilgiSatiri(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
