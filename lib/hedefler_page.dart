import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'yeni_hedef_ekle_page.dart';
import 'hedef_detay_page.dart';

class HedeflerPage extends StatefulWidget {
  @override
  _HedeflerPageState createState() => _HedeflerPageState();
}

class _HedeflerPageState extends State<HedeflerPage> {
  List<Map<String, dynamic>> hedefler = [];
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _hedefleriYukle();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _hedefleriYukle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hedeflerStr = prefs.getString('hedefler_listesi');
    if (hedeflerStr != null) {
      List<dynamic> liste = jsonDecode(hedeflerStr);
      List<Map<String, dynamic>> parsed = List<Map<String, dynamic>>.from(liste);
      setState(() {
        hedefler = parsed;
      });

      for (var hedef in parsed) {
        DateTime bitis = DateTime.parse(hedef['bitisTarih']);
        if (DateTime.now().isAfter(bitis)) {
          _confettiController.play();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("🎉 Tebrikler!"),
                content: Text("Hedefini başarıyla tamamladın!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Kapat"),
                  ),
                ],
              ),
            );
          });
          break;
        }
      }
    }
  }

  Future<void> _hedefEkle(Map<String, dynamic> hedef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hedefler.add(hedef);
    await prefs.setString('hedefler_listesi', jsonEncode(hedefler));
    setState(() {});
  }

  Future<void> _hedefSil(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hedefler.removeAt(index);
    await prefs.setString('hedefler_listesi', jsonEncode(hedefler));
    setState(() {});
  }

  void _silmeOnayi(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hedefi Sil'),
        content: Text('Bu hedefi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _hedefSil(index);
            },
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _yeniHedefDialog() async {
    final yeniHedef = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => YeniHedefEklePage()),
    );
    if (yeniHedef != null) {
      await _hedefEkle(yeniHedef);
    }
  }

  void _hedefeGit(Map<String, dynamic> hedef) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HedefDetayPage(hedef: hedef)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedefler', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
            child: ListView.builder(
              itemCount: hedefler.length,
              itemBuilder: (context, index) {
                final h = hedefler[index];
                return Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      h['baslik'],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${h['baslangicTarih']} - ${h['bitisTarih']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _silmeOnayi(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: () => _hedefeGit(h),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.pink, Colors.orange, Colors.green, Colors.blue],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: _yeniHedefDialog,
      ),
    );
  }
}
