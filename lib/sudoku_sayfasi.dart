import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final List ornekSudoku = List.generate(9, (i) => List.generate(9, (j) => j + 1));
  final Box _sudokuKutu = Hive.box('sudoku');

  List _sudoku = [], _sudokuHistory = [];

  String _sudokuString;

  bool _note = false;

  void _sudokuOlustur() {
    int gorulecekSayisi = sudokuSeviyeleri[_sudokuKutu.get('seviye', defaultValue: dil['seviye2'])];

    _sudokuString = sudokular[Random().nextInt(sudokular.length)];
    _sudokuKutu.put('sudokuString', _sudokuString);

    _sudoku = List.generate(
      9,
      (i) => List.generate(
        9,
        (j) => "e" + _sudokuString.substring(i * 9, (i + 1) * 9).split('')[j],
      ),
    );

    int i = 0;
    while (i < 81 - gorulecekSayisi) {
      int x = Random().nextInt(9);
      int y = Random().nextInt(9);

      if (_sudoku[x][y] != "0") {
        print(_sudoku[x][y]);
        _sudoku[x][y] = "0";
        i++;
      }
    }

    _sudokuKutu.put('sudokuRows', _sudoku);
    _sudokuKutu.put('xy', "99");
    _sudokuKutu.put('ipucu', 3);

    print(_sudokuString);
    print(gorulecekSayisi);
  }

  void _adimKaydet() {
    Map historyItem = {
      'sudokuRows': _sudokuKutu.get('sudokuRows'),
      'xy': _sudokuKutu.get('xy'),
      'ipucu': _sudokuKutu.get('ipucu'),
    };

    _sudokuHistory.add(historyItem);

    _sudokuKutu.put('sudokuHistory', _sudokuHistory);
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
        actions: <Widget>[IconButton(icon: Icon(Icons.refresh), onPressed: _sudokuOlustur)],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              _sudokuKutu.get('seviye', defaultValue: dil['seviye2']),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: ValueListenableBuilder<Box>(
                  valueListenable: _sudokuKutu.listenable(keys: ['xy', 'sudokuRows']),
                  builder: (context, box, widget) {
                    String xy = box.get('xy');
                    int xC = int.parse(xy.substring(0, 1)), yC = int.parse(xy.substring(1));
                    List sudokuRows = box.get('sudokuRows');

                    return Container(
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
                                                    color: xC == x && yC == y
                                                        ? Colors.green
                                                        : Colors.blue.withOpacity(xC == x || yC == y ? 0.8 : 1.0),
                                                    alignment: Alignment.center,
                                                    child: "${sudokuRows[x][y]}".startsWith('e')
                                                        ? Text(
                                                            "${sudokuRows[x][y]}".substring(1),
                                                            style:
                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                                                          )
                                                        : InkWell(
                                                            onTap: () {
                                                              print("$x$y");
                                                              _sudokuKutu.put('xy', "$x$y");
                                                            },
                                                            child: Center(
                                                              child: "${sudokuRows[x][y]}".length > 8
                                                                  ? Column(
                                                                      children: <Widget>[
                                                                        for (int i = 0; i < 9; i += 3)
                                                                          Expanded(
                                                                            child: Row(
                                                                              children: <Widget>[
                                                                                for (int j = 0; j < 3; j++)
                                                                                  Expanded(
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        "${sudokuRows[x][y]}"
                                                                                                    .split('')[i + j] ==
                                                                                                "0"
                                                                                            ? ""
                                                                                            : "${sudokuRows[x][y]}"
                                                                                                .split('')[i + j],
                                                                                        style:
                                                                                            TextStyle(fontSize: 10.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                      ],
                                                                    )
                                                                  : Text(
                                                                      sudokuRows[x][y] != "0" ? sudokuRows[x][y] : "",
                                                                      style: TextStyle(fontSize: 20.0),
                                                                    ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                if (y == 2 || y == 5) SizedBox(width: 2),
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
                    );
                  }),
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
                                  color: Colors.amber,
                                  margin: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      String xy = _sudokuKutu.get('xy');
                                      if (xy != "99") {
                                        int xC = int.parse(xy.substring(0, 1)), yC = int.parse(xy.substring(1));
                                        _sudoku[xC][yC] = "0";
                                        _sudokuKutu.put('sudokuRows', _sudoku);
                                        _adimKaydet();
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "Sil",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ValueListenableBuilder<Box>(
                                  valueListenable: _sudokuKutu.listenable(keys: ['ipucu']),
                                  builder: (context, box, widget) {
                                    return Card(
                                      color: Colors.amber,
                                      margin: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          String xy = box.get('xy');

                                          if (xy != "99" && box.get('ipucu') > 0) {
                                            int xC = int.parse(xy.substring(0, 1)), yC = int.parse(xy.substring(1));

                                            String cozumString = box.get('sudokuString');

                                            List cozumSudoku = List.generate(
                                              9,
                                              (i) => List.generate(
                                                9,
                                                (j) => cozumString.substring(i * 9, (i + 1) * 9).split('')[j],
                                              ),
                                            );

                                            if (_sudoku[xC][yC] != cozumSudoku[xC][yC]) {
                                              _sudoku[xC][yC] = cozumSudoku[xC][yC];
                                              box.put('sudokuRows', _sudoku);

                                              box.put('ipucu', box.get('ipucu') - 1);
                                              _adimKaydet();
                                            }
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.lightbulb_outline,
                                                  color: Colors.black,
                                                ),
                                                Text(
                                                  ": ${box.get('ipucu')}",
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "İpucu",
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
                                  color: _note ? Colors.amber.withOpacity(0.6) : Colors.amber,
                                  margin: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () => setState(() => _note = !_note),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.note_add,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "Not",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  color: _note ? Colors.amber.withOpacity(0.6) : Colors.amber,
                                  margin: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (_sudokuHistory.length > 1) {
                                        _sudokuHistory.removeLast();
                                        Map onceki = _sudokuHistory.last;
                                        /* Map historyItem = {
                                          'sudokuRows': _sudokuKutu.get('sudokuRows'),
                                          'xy': _sudokuKutu.get('xy'),
·                                          'ipucu': _sudokuKutu.get('ipucu'),
                                        }; */

                                        print(_sudokuKutu.get('sudokuRows'));
                                        print(_sudokuHistory[_sudokuHistory.length - 2]['sudokuRows']);

                                        _sudokuKutu.put('sudokuRows', onceki['sudokuRows']);
                                        _sudokuKutu.put('xy', onceki['xy']);
                                        _sudokuKutu.put('ipucu', onceki['ipucu']);

                                        _sudokuKutu.put('sudokuHistory', _sudokuHistory);
                                      }

                                      print(_sudokuHistory.length);
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.undo,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          "Geri Al",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
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
                                          String xy = _sudokuKutu.get('xy');
                                          if (xy != "99") {
                                            int xC = int.parse(xy.substring(0, 1)), yC = int.parse(xy.substring(1));
                                            if (!_note)
                                              _sudoku[xC][yC] = "${i + j}";
                                            else {
                                              if ("${_sudoku[xC][yC]}".length < 8) _sudoku[xC][yC] = "000000000";

                                              _sudoku[xC][yC] = "${_sudoku[xC][yC]}".replaceRange(
                                                i + j - 1,
                                                i + j,
                                                "${_sudoku[xC][yC]}".substring(i + j - 1, i + j) == "${i + j}"
                                                    ? "0"
                                                    : "${i + j}",
                                              );
                                            }

                                            _sudokuKutu.put('sudokuRows', _sudoku);
                                            _adimKaydet();
                                            print("${i + j}");
                                          }
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
