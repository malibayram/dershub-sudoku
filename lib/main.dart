import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sudoku/login/login.dart';
import 'package:sudoku/models/uye.dart';
import 'package:sudoku/sudoku/kategorisec.dart';
import 'package:sudoku/utils/fonksiyonlar.dart';
import 'package:sudoku/utils/renkler.dart';

import 'sudoku/finished_puzzle.dart';

///  Bu seride öğreneceklerimiz?Ø
///  Seviye: Başlangıç üstü - Orta
/*
/1.  Flutter projesi oluşturma
/2.  Otomatik uygulama ikonu oluşturma android/iOS
/3.  Native splash screen düzenleme
/4.  Temel native-flutter ilişkisi
5.  Hive veritabanı CRUD işlemleri
6.  Hive ile state-management (deneysel)
7.  WakeLock ile telefon ekranını uyanık tutma
8.  GoogleFont kullanımı
9.  Detaylı liste işlemleri
10. Uygulama yayınlama işlemleri
11. Github temel işlemler

// İpucu butonuna yeni ipuçları kazanması için
// Google admob reklam izleme
// Uygulama içi satın alma
// Uygulamaya farklı dil destekleri ekleme
// Uygulama ismi-ikonu dile göre değiştirelim
// Market tarafında aynı şekilde

/// Fikirsel tartışılacak konular
/// firebase google - apple ile giriş ekleyelim
/// oynadığı sudokuları firestore kaydedip herkese açık hale getirme


21 Haziran

FirebaseAuth
Google Sign In
Apple Sign In

Firestore

Google Admob Rewarded Ad
In-App Purchase

CRUD
*/

/// In-App Purchase
/*
Prerequisites:

AndroidManifest must include "com.android.vending.BILLING" permission.
APK is built in release mode.
APK is signed with the release certificate(s).
APK is uploaded to alpha/beta distribution channel (previously - as a draft) 
to the developer console at least once. (takes some time ~2h-24h).
IAB products are published and their status set to active.
Test account(s) is added in developer console.
Testing requirements:

Test APK has the same versionCode as the one uploaded to developer console.
Test APK is signed with the same certificate(s) as the one uploaded to dev.console.
Test account (not developer) - is the main account on the device.
Test account is opted-in as a tester and it's linked to a valid payment method.  

*/

void main() async {
  await Hive.initFlutter('dershub-sudoku');

  // Box => sql veritabanlarındaki tablolara denk gelir
  await Hive.openBox('ayarlar');
  Hive.registerAdapter(FinishedPuzzleAdapter());

  FirebaseAdMob.instance.initialize(appId: "ca-app-pub-6288838616447002~5756160571");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primaryColor: Renk.dhMavi,
      ),
      locale: Locale('tr', 'TR'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale('tr', 'TR')],
      home: Container(
        color: Renk.gKirmizi.withOpacity(0.65),
        child: SafeArea(
          child: HiveListener(
            box: Hive.box('ayarlar'),
            keys: ['uye'],
            builder: (box) {
              Map m = box.get('uye', defaultValue: {});
              if (m['displayName'] == null)
                return FutureBuilder<FirebaseUser>(
                  future: FirebaseAuth.instance.currentUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done)
                      return Center(child: CircularProgressIndicator());
                    else {
                      if (snapshot.data == null)
                        return Login();
                      else {
                        kullaniciKontrol(snapshot.data);
                        return KategoriSec();
                      }
                    }
                  },
                );
              else {
                Fnks.uye = Uye.fromMap(m);
                return KategoriSec();
              }
            },
          ),
        ),
      ),
    );
  }
}
