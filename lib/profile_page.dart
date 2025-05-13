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
  String? _cinsiyet;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isimController.text = prefs.getString('isim') ?? '';
      _soyisimController.text = prefs.getString('soyisim') ?? '';
      _boyController.text = prefs.getString('boy') ?? '';
      _kiloController.text = prefs.getString('kilo') ?? '';
      _cinsiyet = prefs.getString('cinsiyet');
    });
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('isim', _isimController.text);
      await prefs.setString('soyisim', _soyisimController.text);
      await prefs.setString('boy', _boyController.text);
      await prefs.setString('kilo', _kiloController.text);
      await prefs.setString('cinsiyet', _cinsiyet ?? '');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Bilgileri'),
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
        padding: EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('İsim', _isimController),
              _buildTextField('Soyisim', _soyisimController),
              _buildTextField('Boy (cm)', _boyController),
              _buildTextField('Kilo (kg)', _kiloController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _cinsiyet != '' ? _cinsiyet : null,
                  decoration: InputDecoration(
                    labelText: 'Cinsiyet',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Colors.deepPurple,
                  items: ['Erkek', 'Kadın']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _cinsiyet = val),
                  validator: (value) => value == null || value.isEmpty ? 'Lütfen cinsiyet seçin' : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _kaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: Size(double.infinity, 50),
                  elevation: 5,
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
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? '$label girin' : null,
      ),
    );
  }
}
