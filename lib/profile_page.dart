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

  String? _cinsiyet; // null olabilen şekilde tanımlandı

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
      final cinsiyet = prefs.getString('cinsiyet');
      if (cinsiyet != null && ['Erkek', 'Kadın'].contains(cinsiyet)) {
        _cinsiyet = cinsiyet;
      }
    });
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      if (_cinsiyet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lütfen cinsiyet seçin')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('isim', _isimController.text);
      await prefs.setString('soyisim', _soyisimController.text);
      await prefs.setString('boy', _boyController.text);
      await prefs.setString('kilo', _kiloController.text);
      await prefs.setString('cinsiyet', _cinsiyet!);

      Navigator.pop(context); // Ana sayfaya dön
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Bilgileri')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('İsim', _isimController),
              _buildTextField('Soyisim', _soyisimController),
              _buildTextField('Boy (cm)', _boyController),
              _buildTextField('Kilo (kg)', _kiloController),
           DropdownButtonFormField<String>(
  value: _cinsiyet,
  decoration: InputDecoration(
    labelText: 'Cinsiyet',
    labelStyle: TextStyle(color: Colors.white70),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white), 
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white), 
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white), 
    ),
  ),
  dropdownColor: Color(0xFF7E57C2), 
  iconEnabledColor: Colors.white,
  style: TextStyle(color: Colors.white), 
  items: [
    DropdownMenuItem(
      value: null,
      enabled: false,
      child: Text('Seçiniz', style: TextStyle(color: Colors.white54)),
    ),
    DropdownMenuItem(
      value: 'Erkek',
      child: Text('Erkek', style: TextStyle(color: Colors.white)),
    ),
    DropdownMenuItem(
      value: 'Kadın',
      child: Text('Kadın', style: TextStyle(color: Colors.white)),
    ),
  ],
  onChanged: (val) {
    if (val != null) setState(() => _cinsiyet = val);
  },
  validator: (v) => v == null ? 'Lütfen cinsiyet seçin' : null,
),



              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _kaydet,
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
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? '$label girin' : null,
    ),
  );
}

}
