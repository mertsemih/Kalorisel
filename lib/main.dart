import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_page.dart';
import 'kalori_hesapla_sayfasi.dart';
import 'gunluk_kaloriler_page.dart';
import 'hedefler_page.dart';
import 'beslenme_programi_page.dart';
import 'login_page.dart';
import 'raporlama_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(KaloriApp());
}

class KaloriApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalori Hesaplayıcı',
      theme: ThemeData(
  primarySwatch: Colors.deepPurple,
  scaffoldBackgroundColor: Color(0xFFB06AB3),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _isim = '';

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isim = prefs.getString('isim') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Sayfa"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              await _verileriYukle(); // Profil ekranından dönünce ismi güncelle
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isim.isNotEmpty ? 'HOŞGELDİN $_isim'.toUpperCase() : 'HOŞGELDİN',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Hedeflerine Ulaşmaya Hazır Mısın?',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    _buildButton(context, 'Kalori Hesaplama', KaloriHesaplaSayfasi()),
                    SizedBox(height: 16),
                    _buildButton(context, 'Beslenme Programı', BeslenmeProgramiPage()),
                    SizedBox(height: 16),
                    _buildButton(context, 'Günlük Kalorileriniz', GunlukKalorilerPage()),
                    SizedBox(height: 16),
                    _buildButton(context, 'Hedefler', HedeflerPage()),
                    SizedBox(height: 16),
                    _buildButton(context, 'İstatistikleriniz', RaporlamaPage()),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(Icons.info_outline, color: Colors.deepPurple),
              onPressed: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Text('Bilgilendirme', style: TextStyle(color: Colors.black)),
      content: Text(
        'Bu uygulama profesyonel sağlık danışmanları tarafından hazırlanmadı. '
        'Bilgiler internet kaynaklarına dayanmaktadır. Sağlık sorunlarınız için lütfen bir doktora danışınız.',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
          child: Text('Anladım', style: TextStyle(color: Colors.deepPurple)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
},

            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              child: Icon(Icons.mail_outline),
             onPressed: () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Bize Ulaşın',
        style: TextStyle(color: Colors.black),
      ),
      content: Text(
        'semihmertsariyerli.06@gmail.com',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Kapat',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
      ],
    ),
  );
},

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, Widget page) {
    return ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: Size(double.infinity, 50),
        elevation: 5,
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}
