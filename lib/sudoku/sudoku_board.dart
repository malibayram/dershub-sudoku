import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/renkler.dart';

class SudokuBoard extends StatelessWidget {
  final int xC, yC;
  final List sudoku, sudokuCols, sudokuBoxes;
  final bool rply;
  final Function changeXY;

  const SudokuBoard({
    Key key,
    @required this.xC,
    @required this.yC,
    @required this.sudoku,
    @required this.sudokuCols,
    @required this.sudokuBoxes,
    this.rply = false,
    this.changeXY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                                child: MaterialButton(
                                  padding: EdgeInsets.all(0),
                                  color: xC == x && yC == y
                                      ? Renk.gmavi.withRed(255)
                                      : xC == x || yC == y ? Renk.gmavi.withRed(200) : null,
                                  textColor: sudoku[x][y].startsWith('s')
                                      ? Renk.gGri65
                                      : sudoku[x][y].length < 8 &&
                                              (sudoku[x][y].allMatches(sudoku[x].toString()).length >= 2 ||
                                                  sudoku[x][y].allMatches(sudokuCols[y].toString()).length >= 2 ||
                                                  sudoku[x][y]
                                                          .allMatches(sudokuBoxes[(y / 3).floor() + (x / 3).floor() * 3]
                                                              .toString())
                                                          .length >=
                                                      2)
                                          ? Renk.gKirmizi
                                          : Renk.siyah,
                                  onPressed: () {
                                    if (sudoku[x][y].startsWith('s') || rply)
                                      print("$xC == $x && $yC == $y");
                                    else
                                      changeXY("$x$y");
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          offset: Offset(-1.0, -1.0),
                                          blurRadius: 1.0,
                                        ),
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: sudoku[x][y].length > 8
                                        ? Column(
                                            children: <Widget>[
                                              for (int ix = 0; ix < 9; ix += 3)
                                                Expanded(
                                                  child: Row(
                                                    children: <Widget>[
                                                      for (int iy = 0; iy < 3; iy++)
                                                        Expanded(
                                                          child: Container(
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              sudoku[x][y].split('')[ix + iy] == '0'
                                                                  ? ""
                                                                  : sudoku[x][y].split('')[ix + iy],
                                                              style: TextStyle(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          )
                                        : Text(
                                            "${sudoku[x][y] == '0' ? '' : sudoku[x][y].replaceAll('s', '')}",
                                            style: GoogleFonts.courgette(
                                              textStyle: TextStyle(fontSize: 24.0),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              if (y == 2 || y == 5)
                                Container(
                                  color: Renk.dkrem,
                                  width: 4,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (x == 2 || x == 5)
                  Container(
                    color: Renk.dkrem,
                    height: 4,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
