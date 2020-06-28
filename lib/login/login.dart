import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:sudoku/models/uye.dart';
import 'package:sudoku/utils/fonksiyonlar.dart';
import 'package:sudoku/utils/renkler.dart';

Future kullaniciKontrol(FirebaseUser user) async {
  Fnks.uye = Uye(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoUrl);

  CollectionReference cr = Firestore.instance.collection('uyeler');

//  Query ornekSorgu = cr.where('jetonlar.sudoku_ipucu', isEqualTo: 0).limit(10).orderBy('uid');

  DocumentReference dr = cr.document(user.uid);

  DocumentSnapshot documentSnapshot = await dr.get();
//  QuerySnapshot querySnapshot = await ornekSorgu.getDocuments();

  if (!documentSnapshot.exists) {
    await dr.setData(Fnks.uye.toMap());
  }

  Hive.box('ayarlar').put('uye', Fnks.uye.toMap());
}

Future<void> signOut() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  try {
    await FirebaseAuth.instance.signOut();
    bool googleSignedIn = await googleSignIn.isSignedIn();
    if (googleSignedIn) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }
    Fnks.uye = null;
    Hive.box('ayarlar').delete('uye');
  } catch (e) {}
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _islem = false, _gittim = false;

  Future _appleIleGirisYap() async {
    _islem = true;
    if (!_gittim) setState(() {});
    AppleSignIn.onCredentialRevoked.listen((_) {
      print("Credentials revoked");
    });

    if (await AppleSignIn.isAvailable()) {
      try {
        final AuthorizationResult result = await AppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]);

        switch (result.status) {
          case AuthorizationStatus.authorized:
            print(result.credential.user); //All the required credentials
            final AppleIdCredential appleIdCredential = result.credential;
            OAuthProvider oAuthProvider = new OAuthProvider(providerId: "apple.com");

            final AuthCredential credential = oAuthProvider.getCredential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            final AuthResult res = await FirebaseAuth.instance.signInWithCredential(credential);

            if (res.user != null) await kullaniciKontrol(res.user);

            break;
          case AuthorizationStatus.error:
            Fluttertoast.showToast(msg: 'Apple ile Giriş esnasında hata oluştu ${result.error.localizedDescription}');
            print("Sign in failed: ${result.error.localizedDescription}");
            break;
          case AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
        }
      } on PlatformException catch (e) {
        Fluttertoast.showToast(msg: 'işlem gerçekleştirilirken hata oluştu: ${e.toString()}');

        print(e);
      } catch (e) {
        print(e);
      }
    } else {
      Fluttertoast.showToast(msg: 'Apple ile Giriş cihazınızla uyumlu değil');
    }
    _islem = false;
    if (!_gittim) setState(() {});
  }

  Future _googleIleGirisYap() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    _islem = true;
    if (!_gittim) setState(() {});

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        try {
          AuthResult res = await FirebaseAuth.instance.signInWithCredential(credential);
          if (res.user != null) await kullaniciKontrol(res.user);
        } on PlatformException catch (e) {
          Fluttertoast.showToast(msg: 'işlem gerçekleştirilirken hata oluştu: ${e.toString()}');

          print(e);
        } catch (e) {
          print(e);
        }
      }
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: 'işlem gerçekleştirilirken hata oluştu: ${e.toString()}');

      print(e);
    } catch (e) {
      print(e);
    }
    _islem = false;
    if (!_gittim) setState(() {});
  }

  @override
  void dispose() {
    _gittim = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HiveListener(
      box: Hive.box('ayarlar'),
      keys: ['uye'],
      builder: (box) {
        Map u = box.get('uye', defaultValue: {});
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/giris_back.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 40.0),
                Center(child: Image.asset('assets/icon/sudoku.png')),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Sudoku Dershub",
                    style: GoogleFonts.courgette(
                      textStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 40.0),
                if (u['email'] != null) Center(child: Text(u['displayName'])),
                if (u['email'] == null)
                  _islem
                      ? Center(child: CircularProgressIndicator(backgroundColor: Renk.yesil2))
                      : Column(
                          children: <Widget>[
                            Center(
                              child: IntrinsicWidth(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Renk.yesil2.withOpacity(0.4),
                                        blurRadius: 5,
                                        offset: Offset(0, 02),
                                      ),
                                    ],
                                  ),
                                  child: FlatButton(
                                    color: Renk.beyaz,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                    onPressed: _googleIleGirisYap,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.google, color: Renk.yesil2),
                                        SizedBox(width: 10),
                                        Text('Google ile giriş yap')
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.0),
                            if (Platform.isIOS)
                              FlatButton.icon(
                                color: Renk.siyah,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                splashColor: Renk.beyaz.withOpacity(0.2),
                                onPressed: _appleIleGirisYap,
                                icon: Icon(FontAwesomeIcons.apple, color: Renk.beyaz),
                                label: Text('Apple ile Giriş Yap', style: TextStyle(color: Renk.beyaz)),
                              ),
                          ],
                        ),
              ],
            ),
          ),
        );
      },
    );
  }
}
