import 'package:flutter/material.dart';

class YeniHedefEklePage extends StatefulWidget {
  @override
  _YeniHedefEklePageState createState() => _YeniHedefEklePageState();
}

class _YeniHedefEklePageState extends State<YeniHedefEklePage> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _baslangicKiloController = TextEditingController();
  final _hedefKiloController = TextEditingController();
  DateTime _baslangicTarih = DateTime.now();
  DateTime _bitisTarih = DateTime.now().add(Duration(days: 30));

  Future<void> _tarihSec(bool baslangic) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: baslangic ? _baslangicTarih : _bitisTarih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (secilen != null) {
      setState(() {
        if (baslangic) {
          _baslangicTarih = secilen;
        } else {
          _bitisTarih = secilen;
        }
      });
    }
  }

  void _kaydet() {
    if (_formKey.currentState!.validate()) {
      final double basKilo = double.parse(_baslangicKiloController.text);
      final double hedefKilo = double.parse(_hedefKiloController.text);
      final int gun = _bitisTarih.difference(_baslangicTarih).inDays;
      final double kaloriFarki = ((hedefKilo - basKilo) * 7700) / gun;

      Navigator.pop(context, {
        'baslik': _baslikController.text,
        'baslangicKilo': basKilo,
        'hedefKilo': hedefKilo,
        'baslangicTarih': _baslangicTarih.toIso8601String(),
        'bitisTarih': _bitisTarih.toIso8601String(),
        'gunlukKaloriHedefi': kaloriFarki,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Hedef'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 20, left: 16, right: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField('Hedef Başlığı', _baslikController),
                _buildTextField('Başlangıç Kilosu', _baslangicKiloController),
                _buildTextField('Hedef Kilosu', _hedefKiloController),
                ListTile(
                  title: Text(
                    'Başlangıç: ${_baslangicTarih.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white),
                  onTap: () => _tarihSec(true),
                ),
                ListTile(
                  title: Text(
                    'Bitiş: ${_bitisTarih.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.white),
                  onTap: () => _tarihSec(false),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _kaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        keyboardType: label.contains("Kilo") ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: (v) => v!.isEmpty ? '$label girin' : null,
      ),
    );
  }
}
