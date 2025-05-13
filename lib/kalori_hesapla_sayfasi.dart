import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KaloriHesaplaSayfasi extends StatefulWidget {
  @override
  _KaloriHesaplaSayfasiState createState() => _KaloriHesaplaSayfasiState();
}

class _KaloriHesaplaSayfasiState extends State<KaloriHesaplaSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _kiloController = TextEditingController();
  final _boyController = TextEditingController();
  final _yasController = TextEditingController();

  String? _cinsiyet;
  String? _hedef;

  double? _bmr;
  double? _kaloriKorumak;
  double? _kaloriVermek;
  double? _kaloriAlmak;

  double? _bmi;
  String? _bmiDurumu;

  void _hesapla() async {
    if (_formKey.currentState!.validate()) {
      final kilo = double.parse(_kiloController.text);
      final boy = double.parse(_boyController.text);
      final yas = double.parse(_yasController.text);

      double bmr = (_cinsiyet == 'Erkek')
          ? 10 * kilo + 6.25 * boy - 5 * yas + 5
          : 10 * kilo + 6.25 * boy - 5 * yas - 161;
      double korumak = bmr * 1.2;
      double vermek = korumak - 500;
      double almak = korumak + 500;

      double boyMetre = boy / 100;
      double bmi = kilo / (boyMetre * boyMetre);
      String durum;

      if (bmi < 18.5) {
        durum = 'Zayıf';
      } else if (bmi < 25) {
        durum = 'Normal';
      } else if (bmi < 30) {
        durum = 'Fazla kilolu';
      } else {
        durum = 'Obez';
      }

      double hedefKalori = _hedef == 'Kilo Vermek'
          ? vermek
          : _hedef == 'Kilo Almak'
              ? almak
              : korumak;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('hedefKalori', hedefKalori);

      setState(() {
        _bmr = bmr;
        _kaloriKorumak = korumak;
        _kaloriVermek = vermek;
        _kaloriAlmak = almak;
        _bmi = bmi;
        _bmiDurumu = durum;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        validator: (v) => v!.isEmpty ? '$label giriniz' : null,
      ),
    );
  }

  Widget _buildSonuc() {
    String hedefMetni = '';
    double? kaloriDegeri;

    if (_hedef == 'Korumak') {
      hedefMetni = 'Kilonuzu korumak için önerilen günlük kalori ihtiyacınız';
      kaloriDegeri = _kaloriKorumak;
    } else if (_hedef == 'Kilo Vermek') {
      hedefMetni = 'Kilo vermek için önerilen günlük kalori ihtiyacınız';
      kaloriDegeri = _kaloriVermek;
    } else if (_hedef == 'Kilo Almak') {
      hedefMetni = 'Kilo almak için önerilen günlük kalori ihtiyacınız';
      kaloriDegeri = _kaloriAlmak;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hedefMetni,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            '${kaloriDegeri!.toStringAsFixed(0)} kcal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'BMI(Vücut Kitle İndeksi): ${_bmi!.toStringAsFixed(1)} ($_bmiDurumu)',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalori Hesaplayıcı', style: TextStyle(color: Colors.white)),
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
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 20, left: 16, right: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _cinsiyet,
                  decoration: _inputDecoration('Cinsiyet'),
                  dropdownColor: Colors.deepPurple[400],
                  style: TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      enabled: false,
                      child: Text('Seçiniz', style: TextStyle(color: Colors.white54)),
                    ),
                    DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                  ],
                  onChanged: (val) => setState(() => _cinsiyet = val),
                  validator: (val) => val == null ? 'Lütfen cinsiyet seçiniz' : null,
                ),
                _buildTextField('Kilo (kg)', _kiloController),
                _buildTextField('Boy (cm)', _boyController),
                _buildTextField('Yaş', _yasController),
                DropdownButtonFormField<String>(
                  value: _hedef,
                  decoration: _inputDecoration('Hedef'),
                  dropdownColor: Colors.deepPurple[400],
                  style: TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      enabled: false,
                      child: Text('Seçiniz', style: TextStyle(color: Colors.white54)),
                    ),
                    DropdownMenuItem(value: 'Korumak', child: Text('Korumak')),
                    DropdownMenuItem(value: 'Kilo Vermek', child: Text('Kilo Vermek')),
                    DropdownMenuItem(value: 'Kilo Almak', child: Text('Kilo Almak')),
                  ],
                  onChanged: (val) => setState(() => _hedef = val),
                  validator: (val) => val == null ? 'Lütfen hedef seçiniz' : null,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _hesapla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Hesapla'),
                ),
                SizedBox(height: 24),
                if (_kaloriKorumak != null) _buildSonuc(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
