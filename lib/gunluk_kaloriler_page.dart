import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class GunlukKalorilerPage extends StatefulWidget {
  @override
  _GunlukKalorilerPageState createState() => _GunlukKalorilerPageState();
}

class _GunlukKalorilerPageState extends State<GunlukKalorilerPage> {
  List<Map<String, dynamic>> _gunlukKayitlar = [];
  final _kaloriController = TextEditingController();
  final int _gunlukHedef = 2200; // Burayı kullanıcı hedefinden çekebilirsin

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? kayitStr = prefs.getString('gunluk_kaloriler');
    if (kayitStr != null) {
      List<dynamic> jsonList = jsonDecode(kayitStr);
      setState(() {
        _gunlukKayitlar = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _verileriKaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gunluk_kaloriler', jsonEncode(_gunlukKayitlar));
  }

  void _kaydet() async {
    if (_kaloriController.text.isNotEmpty) {
      setState(() {
        _gunlukKayitlar.insert(0, {
          'tarih': DateTime.now().toIso8601String(),
          'kalori': int.parse(_kaloriController.text),
        });
        _kaloriController.clear();
      });
      await _verileriKaydet();
    }
  }

  void _kayitSil(int index) async {
    setState(() {
      _gunlukKayitlar.removeAt(index);
    });
    await _verileriKaydet();
  }

  String _tarihFormat(String isoTarih) {
    DateTime tarih = DateTime.parse(isoTarih);
    return '${tarih.day.toString().padLeft(2, '0')}.${tarih.month.toString().padLeft(2, '0')}.${tarih.year}';
  }

  Widget _buildKaloriGrafik() {
    final son7 = _gunlukKayitlar.take(7).toList().reversed.toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: son7.map((e) => (e['kalori'] as int).toDouble()).fold<double>(0, (prev, el) => el > prev ? el : prev) + 200,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}', style: TextStyle(color: Colors.white, fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < son7.length) {
                  final tarih = DateTime.parse(son7[index]['tarih']);
                  return Text('${tarih.day}/${tarih.month}', style: TextStyle(color: Colors.white, fontSize: 10));
                }
                return Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(son7.length, (i) {
          final kalori = (son7[i]['kalori'] as int).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: kalori,
                color: Colors.white,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _build30GunOzeti() {
  final now = DateTime.now();
  final son30Gun = _gunlukKayitlar.where((e) {
    final tarih = DateTime.parse(e['tarih']);
    return tarih.isAfter(now.subtract(Duration(days: 30)));
  }).toList();

  final toplam = son30Gun.fold<int>(0, (sum, e) => sum + (e['kalori'] as int));
  final hedef = _gunlukHedef * 30;
  final fark = toplam - hedef;

  String mesaj;
  Color renk;
  if (fark == 0) {
    mesaj = 'Tam hedefte kaldınız!';
    renk = Colors.yellow;
  } else if (fark > 0) {
    mesaj = 'Kalori fazlası: +$fark kcal';
    renk = Colors.redAccent;
  } else {
    mesaj = 'Kalori açığı: $fark kcal';
    renk = Colors.greenAccent;
  }

  return Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Son 30 günde toplam alınan: $toplam kcal',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Text(
            'Hedef: $hedef kcal',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            mesaj,
            style: TextStyle(color: renk, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Günlük Kalorileriniz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugünkü toplam kalorinizi girin ve kaydedin:',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kaloriController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Toplam Kalori',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _kaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Kaydet'),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (_gunlukKayitlar.length >= 2) ...[
              Text(
                'Grafik (Son 7 Gün):',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildKaloriGrafik(),
                ),
              ),
            ],
            Text(
              'Geçmiş Günler:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _gunlukKayitlar.isEmpty
                  ? Center(child: Text('Henüz kayıt yok.', style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: _gunlukKayitlar.length,
                      itemBuilder: (context, index) {
                        final kayit = _gunlukKayitlar[index];
                        return ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.white),
                          title: Text(
                            _tarihFormat(kayit['tarih']),
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${kayit['kalori']} kcal',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Kaydı Sil'),
                                      content: Text('Bu kaydı silmek istediğinize emin misiniz?'),
                                      actions: [
                                        TextButton(
                                          child: Text('İptal'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: Text('Sil', style: TextStyle(color: Colors.red)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _kayitSil(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            _build30GunOzeti(),
          ],
        ),
      ),
    );
  }
}
