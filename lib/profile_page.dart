import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _isimController = TextEditingController();
  final _soyisimController = TextEditingController();
  final _boyController = TextEditingController();
  final _kiloController = TextEditingController();
  String _cinsiyet = 'Seçiniz';

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();

    _isimController.text = prefs.getString('isim') ?? '';
    _soyisimController.text = prefs.getString('soyisim') ?? '';
    _boyController.text = prefs.getString('boy') ?? '';
    _kiloController.text = prefs.getString('kilo') ?? '';

    final kayitliCinsiyet = prefs.getString('cinsiyet');
    if (kayitliCinsiyet != null && (kayitliCinsiyet == 'Erkek' || kayitliCinsiyet == 'Kadın')) {
      _cinsiyet = kayitliCinsiyet;
    } else {
      _cinsiyet = 'Seçiniz';
    }

    setState(() {}); // arayüzü güncelle
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('isim', _isimController.text);
      await prefs.setString('soyisim', _soyisimController.text);
      await prefs.setString('boy', _boyController.text);
      await prefs.setString('kilo', _kiloController.text);
      await prefs.setString('cinsiyet', _cinsiyet);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil bilgileri kaydedildi')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Profil Bilgileri', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              _buildTextField('İsim', _isimController),
              _buildTextField('Soyisim', _soyisimController),
              _buildTextField('Boy (cm)', _boyController),
              _buildTextField('Kilo (kg)', _kiloController),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
               value: ['Seçiniz', 'Erkek', 'Kadın'].contains(_cinsiyet) ? _cinsiyet : 'Seçiniz',

                dropdownColor: Colors.deepPurple[400],
                decoration: _inputDecoration('Cinsiyet'),
                style: TextStyle(color: Colors.white),
                items: ['Seçiniz', 'Erkek', 'Kadın']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _cinsiyet = val!),
                validator: (v) =>
                    (v == null || v == 'Seçiniz') ? 'Lütfen cinsiyet seçin' : null,
              ),
              SizedBox(height: 24),
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: label.contains("cm") || label.contains("kg")
            ? TextInputType.number
            : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        validator: (v) => v == null || v.trim().isEmpty ? '$label girin' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    );
  }
}
