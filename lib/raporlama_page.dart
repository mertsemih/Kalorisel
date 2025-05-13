import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class RaporlamaPage extends StatefulWidget {
  @override
  _RaporlamaPageState createState() => _RaporlamaPageState();
}

class _RaporlamaPageState extends State<RaporlamaPage> {
  DateTime? _baslangic;
  DateTime? _bitis;
  List<Map<String, dynamic>> _kayitlar = [];
  List<Map<String, dynamic>> _filtreli = [];
  bool _grafikGoster = false;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('gunluk_kaloriler');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      _kayitlar = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  void _tarihSec() async {
    final today = DateTime.now();

    final baslangic = await showDatePicker(
      context: context,
      initialDate: today.subtract(Duration(days: 7)),
      firstDate: DateTime(2024),
      lastDate: today,
    );

    if (baslangic == null) return;

    final bitis = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: baslangic,
      lastDate: today,
    );

    if (bitis == null) return;

    setState(() {
      _baslangic = baslangic;
      _bitis = bitis;
      _filtrele();
      _grafikGoster = false;
    });
  }

  void _filtrele() {
    _filtreli = _kayitlar.where((e) {
      DateTime t = DateTime.parse(e['tarih']);
      return t.isAfter(_baslangic!.subtract(Duration(days: 1))) &&
          t.isBefore(_bitis!.add(Duration(days: 1)));
    }).toList();
  }

  int get _toplam => _filtreli.fold(0, (t, e) => t + e['kalori'] as int);

  double get _ortalama =>
      _filtreli.isEmpty ? 0 : _toplam / _filtreli.length;

  int get _enYuksek =>
      _filtreli.map((e) => e['kalori'] as int).fold(0, (a, b) => a > b ? a : b);

  int get _enDusuk =>
      _filtreli.map((e) => e['kalori'] as int).fold(99999, (a, b) => a < b ? a : b);

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i >= 0 && i < _filtreli.length) {
                  final date = DateTime.parse(_filtreli[i]['tarih']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('${date.day}.${date.month}', style: TextStyle(color: Colors.white, fontSize: 10)),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _filtreli.length,
              (i) {
                final k = _filtreli[i]['kalori'] as int;
                final fark = k - 2200;
                return FlSpot(i.toDouble(), fark.toDouble());
              },
            ),
            isCurved: true,
            color: Colors.greenAccent,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aralikYazi = (_baslangic != null && _bitis != null)
        ? '${_baslangic!.day}.${_baslangic!.month} – ${_bitis!.day}.${_bitis!.month}'
        : 'Tarih seçilmedi';

    return Scaffold(
      appBar: AppBar(
        title: Text('İstatistikleriniz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 48),
            Center(
              child: ElevatedButton(
                onPressed: _tarihSec,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: Size(180, 40),
                ),
                child: Text('Tarih Aralığı Seç'),
              ),
            ),
            SizedBox(height: 24),
            if (_baslangic != null && _bitis != null && _filtreli.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarih Aralığı: $aralikYazi', style: TextStyle(color: Colors.white)),
                  Text('Gün Sayısı: ${_filtreli.length}', style: TextStyle(color: Colors.white)),
                  Text('Toplam Kalori: $_toplam kcal', style: TextStyle(color: Colors.white)),
                  Text('Ortalama Günlük Kalori: ${_ortalama.toStringAsFixed(1)} kcal',
                      style: TextStyle(color: Colors.white)),
                  Text('En Yüksek Gün: $_enYuksek kcal', style: TextStyle(color: Colors.white)),
                  Text('En Düşük Gün: $_enDusuk kcal', style: TextStyle(color: Colors.white)),
                ],
              ),
            if (_filtreli.isNotEmpty) ...[
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => _grafikGoster = !_grafikGoster),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(_grafikGoster ? 'Grafiği Gizle' : 'Grafiklendir'),
                ),
              ),
              if (_grafikGoster) ...[
                SizedBox(height: 16),
                SizedBox(height: 250, child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildChart(),
                )),
              ],
            ]
          ],
        ),
      ),
    );
  }
}
