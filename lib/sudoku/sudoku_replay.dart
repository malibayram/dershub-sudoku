import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../utils/renkler.dart';
import 'finished_puzzle.dart';
import 'sudoku_board.dart';

class SudokuReplay extends StatefulWidget {
  final FinishedPuzzle fp;

  const SudokuReplay({Key key, @required this.fp}) : super(key: key);
  @override
  _SudokuReplayState createState() => _SudokuReplayState();
}

class _SudokuReplayState extends State<SudokuReplay> {
  FinishedPuzzle _fp;
  int _sudokuIndex = 0;
  double _playVelocity = 1200.0;
  bool _isPlaying = false;
  Timer _timer;

  void _playPause() {
    if (!_isPlaying && _sudokuIndex < _fp.sudokuHistory.length - 1) {
      _isPlaying = true;
      if (_timer != null && _timer.isActive) {
        _timer.cancel();
        _timer = null;
      }
      _timer = Timer.periodic(
          Duration(milliseconds: 2200 - _playVelocity.floor()), (timer) {
        if (_sudokuIndex < _fp.sudokuHistory.length - 1) {
          _sudokuIndex++;
          setState(() {});
        } else {
          timer.cancel();
          _timer.cancel();
          _timer = null;
          _isPlaying = false;
          setState(() {});
        }
      });
    } else {
      if (_timer != null && _timer.isActive) {
        _timer.cancel();
        _timer = null;
      }
      _isPlaying = false;
      setState(() {});
    }
  }

  Future<Map> _getSudoku() async {
    Map historyItem = jsonDecode(_fp.sudokuHistory[_sudokuIndex]);
    List sudoku = historyItem['sudoku'], sudokuBoxes = [], sudokuCols = [];

    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        sudokuBoxes.add([
          ...sudoku[i * 3].getRange(j * 3, (j + 1) * 3),
          ...sudoku[i * 3 + 1].getRange(j * 3, (j + 1) * 3),
          ...sudoku[i * 3 + 2].getRange(j * 3, (j + 1) * 3),
        ]);

    sudokuCols =
        List.generate(9, (i) => List.generate(9, (j) => "${sudoku[j][i]}"));

    return Future.value({
      'sudoku': sudoku,
      'sudokuBoxes': sudokuBoxes,
      'sudokuCols': sudokuCols,
      'xC': int.tryParse(historyItem['xy'][0]),
      'yC': int.tryParse(historyItem['xy'][1]),
      'sure': historyItem['sure'],
      'ipucu': historyItem['ipucu'],
    });
  }

  @override
  void initState() {
    _fp = widget.fp;

    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat("dd MMMM yyyy HH:mm", "tr-TR").format(_fp.date)),
      ),
      backgroundColor: Renk.forumRenkleri[12],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<Map>(
          future: _getSudoku(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map box = snapshot.data;
              List _sudoku = box['sudoku'];
              List _sudokuCols = box['sudokuCols'];
              List _sudokuBoxes = box['sudokuBoxes'];
              int _xC = box['xC'];
              int _yC = box['yC'];
              return Column(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      width: double.maxFinite,
                      color: Renk.dkrem,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          color: Renk.gmavi,
                          child: SudokuBoard(
                            xC: _xC,
                            yC: _yC,
                            sudoku: _sudoku,
                            sudokuCols: _sudokuCols,
                            sudokuBoxes: _sudokuBoxes,
                            rply: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text("Süre: ", style: TextStyle(color: Renk.beyaz)),
                        Text(
                          "${Duration(seconds: box['sure'])}".split('.')[0],
                          style: TextStyle(
                            color: Renk.beyaz,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Spacer(),
                        Text("İpucu: ", style: TextStyle(color: Renk.beyaz)),
                        Text(
                          "${box['ipucu']}",
                          style: TextStyle(
                            color: Renk.beyaz,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        RaisedButton(
                          color: Renk.dkrem,
                          onPressed: _sudokuIndex > 0
                              ? () => setState(() => _sudokuIndex--)
                              : null,
                          child: Text("Geri"),
                        ),
                        Expanded(
                          child: Center(
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              iconSize: 64,
                              icon: Icon(
                                _isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              onPressed: _playPause,
                              color: Renk.dkrem,
                            ),
                          ),
                        ),
                        RaisedButton(
                          color: Renk.dkrem,
                          onPressed: _sudokuIndex < _fp.sudokuHistory.length - 1
                              ? () => setState(() => _sudokuIndex++)
                              : null,
                          child: Text("İleri"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Theme(
                      data: ThemeData(
                        sliderTheme: SliderThemeData(
                          thumbColor: Renk.dkrem,
                          valueIndicatorColor: Renk.dkrem,
                          valueIndicatorTextStyle: TextStyle(color: Renk.siyah),
                        ),
                      ),
                      child: Slider(
                        value: _playVelocity,
                        max: 2000.0,
                        min: 200.0,
                        divisions: 9,
                        label:
                            "${((2200 - _playVelocity) / 1000).toStringAsFixed(1)} sn/adım",
                        onChanged: (v) => setState(() => _playVelocity = v),
                        onChangeEnd: (v) {
                          setState(() => _playVelocity = v);

                          if (_isPlaying &&
                              _sudokuIndex < _fp.sudokuHistory.length - 1) {
                            if (_timer != null && _timer.isActive) {
                              _timer.cancel();
                              _timer = null;
                            }
                            _timer = Timer.periodic(
                                Duration(
                                    milliseconds: 2200 - _playVelocity.floor()),
                                (timer) {
                              if (_sudokuIndex < _fp.sudokuHistory.length - 1) {
                                _sudokuIndex++;
                                setState(() {});
                              } else {
                                timer.cancel();
                                _timer.cancel();
                                _timer = null;
                                _isPlaying = false;
                                setState(() {});
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
