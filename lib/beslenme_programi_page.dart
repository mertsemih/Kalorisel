import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'kalori_ipucu_page.dart'; 

class BeslenmeProgramiPage extends StatefulWidget {
  @override
  _BeslenmeProgramiPageState createState() => _BeslenmeProgramiPageState();
}

class _BeslenmeProgramiPageState extends State<BeslenmeProgramiPage> {
  final _formKey = GlobalKey<FormState>();
  final _isimController = TextEditingController();
  final _kaloriController = TextEditingController();

  List<Map<String, dynamic>> _yemekler = [];
  int _toplamKalori = 0;
  late int _hedefKalori;

  @override
  void initState() {
    super.initState();
    _loadHedefKalori();
    _loadYemekler();
  }

  Future<void> _loadHedefKalori() async {
    final prefs = await SharedPreferences.getInstance();
    final hedef = prefs.getDouble('hedefKalori') ?? 2000;
    setState(() {
      _hedefKalori = hedef.round();
    });
  }

  Future<void> _loadYemekler() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('yemekler');
    if (jsonStr != null) {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      setState(() {
        _yemekler = decoded.cast<Map<String, dynamic>>();
        _toplamKalori = _yemekler.fold(0, (sum, item) => sum + (item['kalori'] as int));
      });
    }
  }

  Future<void> _saveYemekler() async {
    final prefs = await SharedPreferences.getInstance();
    final yemeklerJson = jsonEncode(_yemekler);
    await prefs.setString('yemekler', yemeklerJson);
  }

  void _ekle({String? isim, int? kalori}) {
    final eklenenIsim = isim ?? _isimController.text;
    final eklenenKalori = kalori ?? int.tryParse(_kaloriController.text) ?? 0;

    if (eklenenIsim.isNotEmpty && eklenenKalori > 0) {
      setState(() {
        _yemekler.add({
          'isim': eklenenIsim,
          'kalori': eklenenKalori,
        });
        _toplamKalori += eklenenKalori;
        _isimController.clear();
        _kaloriController.clear();
      });
      _saveYemekler();
    }
  }

  void _sil(int index) {
    final silinen = _yemekler[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Silinsin mi?"),
        content: Text("${silinen['isim']} adlı besini silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İptal")),
          TextButton(
            onPressed: () {
              setState(() {
                _toplamKalori -= (silinen['kalori'] as int);
                _yemekler.removeAt(index);
              });
              _saveYemekler();
              Navigator.pop(context);
            },
            child: Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _durumMesaji() {
    if (_toplamKalori < _hedefKalori) {
      int eksik = _hedefKalori - _toplamKalori;
      return 'Günlük Hedefe ulaşmak için $eksik kcal daha alabilirsiniz.';
    } else if (_toplamKalori > _hedefKalori) {
      int fazla = _toplamKalori - _hedefKalori;
      return 'Hedefinizi $fazla kcal aştınız!';
    } else {
      return 'Hedef kalorinizde kaldınız, tebrikler!';
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    );
  }

  Future<void> _kaloriIpucuyaGit() async {
    final secilen = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KaloriIpucuPage()),
    );

    if (secilen != null && secilen is Map<String, dynamic>) {
      _ekle(isim: secilen['isim'], kalori: secilen['kalori']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beslenme Programı', style: TextStyle(color: Colors.white)),
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
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _isimController,
                      style: TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Yiyecek/İçecek'),
                      validator: (v) => v!.isEmpty ? 'İsim giriniz' : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _kaloriController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Kalori'),
                      validator: (v) => v!.isEmpty ? 'Kalori giriniz' : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _ekle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: Size(64, 48),
                    ),
                    child: Text('Ekle'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _kaloriIpucuyaGit,
              icon: Icon(Icons.lightbulb_outline, color: Colors.white),
              label: Text('Kalori İpuçları', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Eklenenler:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _yemekler.length,
                      itemBuilder: (context, index) {
                        final yemek = _yemekler[index];
                        return ListTile(
                          title: Text(yemek['isim'], style: TextStyle(color: Colors.white)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${yemek['kalori']} kcal', style: TextStyle(color: Colors.white)),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _sil(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Toplam Kalori: $_toplamKalori kcal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _durumMesaji(),
                    style: TextStyle(
                      fontSize: 16,
                      color: _toplamKalori > _hedefKalori ? Colors.red[200] : Colors.green[200],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
