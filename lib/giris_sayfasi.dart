import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:sudoku/sudoku_sayfasi.dart';

import 'dil.dart';

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  Box _sudokuKutu;
  Future<Box> _kutuAc() async {
    _sudokuKutu = await Hive.openBox('sudoku');
    return await Hive.openBox('tamamlanan_sudokular');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dil['giris_title']),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Box kutu = Hive.box('ayarlar');
              kutu.put(
                'karanlik_tema',
                !kutu.get('karanlik_tema', defaultValue: false),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.add),
            onSelected: (deger) {
              if (_sudokuKutu.isOpen) {
                _sudokuKutu.put('seviye', deger);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SudokuSayfasi()),
                );
              }
            },
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: dil['seviye_secin'],
                child: Text(
                  dil['seviye_secin'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyText1.color,
                  ),
                ),
                enabled: false,
              ),
              for (String k in sudokuSeviyeleri.keys)
                PopupMenuItem(
                  value: k,
                  child: Text(k),
                ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Box>(
          future: _kutuAc(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (snapshot.data.length == 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          dil['tamanlanan_yok'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lobster(
                            textStyle: TextStyle(fontSize: 24.0),
                          ),
                        ),
                      ),
                    for (var eleman in snapshot.data.values)
                      Center(child: Text("$eleman"))
                  ],
                ),
              );
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
