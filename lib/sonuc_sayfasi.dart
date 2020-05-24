import 'package:flutter/material.dart';

import 'dil.dart';

class SonucSayfasi extends StatefulWidget {
  @override
  _SonucSayfasiState createState() => _SonucSayfasiState();
}

class _SonucSayfasiState extends State<SonucSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: dil['sonuc_title'],
      ),
    );
  }
}
