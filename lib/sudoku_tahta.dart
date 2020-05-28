import 'package:flutter/material.dart';

class SudokuTahta extends StatelessWidget {
  final List sudokuRows;
  final int xC, yC;
  final Function tikla;

  const SudokuTahta({Key key, @required this.sudokuRows, @required this.xC, @required this.yC, @required this.tikla})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
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
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              print("$x$y");
                                              //box.put('xy', "$x$y");
                                              tikla("$x$y");
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
                                                                        "${sudokuRows[x][y]}".split('')[i + j] == "0"
                                                                            ? ""
                                                                            : "${sudokuRows[x][y]}".split('')[i + j],
                                                                        style: TextStyle(fontSize: 10.0),
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
  }
}
