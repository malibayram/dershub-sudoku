import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dil.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dil['sudoku_title']),
      ),
      body: Center(
        child: Text(
          Hive.box('sudoku').get('seviye', defaultValue: "Kolay"),
        ),
      ),
    );
  }
}
