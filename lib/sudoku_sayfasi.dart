import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'sudokular.dart';
import 'dil.dart';

// Hergün dökümandan bir şeyler okuyun
// Dökümantasyon inceleme
// Aldığınız hata kodlarınız mutlaka paylaşın
// İngilizce öğrenin
// StackOverFlow.Com

///
/// Bilal Şimşek: ​alınan hata.
/// alınan hatanın kod bloğu, çözmek için neler denendi.
/// bunların bilgisi verilmeli.
/// birde flutter da hata bildirim altyapısı o kadar gelişmiş ki.
/// hatanın çözümü de içinde olabiliyor bazen.
///
/// Hive
///
///

final Map<String, int> sudokuSeviyeleri = {
  dil['seviye1']: 62,
  dil['seviye2']: 53,
  dil['seviye3']: 44,
  dil['seviye4']: 35,
  dil['seviye5']: 26,
  dil['seviye6']: 17,
};

class SudokuSayfasi extends StatefulWidget {
  @override
  _SudokuSayfasiState createState() => _SudokuSayfasiState();
}

class _SudokuSayfasiState extends State<SudokuSayfasi> {
  final List ornekSudoku =
      List.generate(9, (i) => List.generate(9, (j) => j + 1));
  final Box _sudokuKutu = Hive.box('sudoku');

  List _sudoku = [];
  String _sudokuString;

  void _sudokuOlustur() {
    int gorulecekSayisi = sudokuSeviyeleri[
        _sudokuKutu.get('seviye', defaultValue: dil['seviye2'])];

    _sudokuString = sudokular[Random().nextInt(sudokular.length)];

    _sudoku = List.generate(
      9,
      (i) => List.generate(
        9,
        (j) => int.tryParse(
            _sudokuString.substring(i * 9, (i + 1) * 9).split('')[j]),
      ),
    );

    int i = 0;
    while (i < 81 - gorulecekSayisi) {
      int x = Random().nextInt(9);
      int y = Random().nextInt(9);

      if (_sudoku[x][y] != 0) {
        print(_sudoku[x][y]);
        _sudoku[x][y] = 0;
        i++;
      }
    }

    setState(() {});

    print(_sudokuString);
    print(gorulecekSayisi);
  }

  @override
  void initState() {
    _sudokuOlustur();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dil['sudoku_title']),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _sudokuOlustur)
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              _sudokuKutu.get('seviye', defaultValue: dil['seviye2']),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.amber,
                padding: EdgeInsets.all(2.0),
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    for (int x = 0; x < 9; x++)
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  for (int y = 0; y < 9; y++)
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.all(1.0),
                                              color: Colors.blue,
                                              alignment: Alignment.center,
                                              child: Text(
                                                _sudoku[x][y] > 0
                                                    ? _sudoku[x][y].toString()
                                                    : "",
                                              ),
                                            ),
                                          ),
                                          if (y == 2 || y == 5)
                                            SizedBox(width: 2),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (x == 2 || x == 5) SizedBox(height: 2),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(
                                  child: Container(
                                    margin: EdgeInsets.all(3.0),
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Container(
                                    margin: EdgeInsets.all(3.0),
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Card(
                                  child: Container(
                                    margin: EdgeInsets.all(3.0),
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  child: Container(
                                    margin: EdgeInsets.all(3.0),
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        for (int i = 1; i < 10; i += 3)
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                for (int j = 0; j < 3; j++)
                                  Expanded(
                                    child: Card(
                                      color: Colors.amber,
                                      shape: CircleBorder(),
                                      child: InkWell(
                                        onTap: () {
                                          print("${i + j}");
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(3.0),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${i + j}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
