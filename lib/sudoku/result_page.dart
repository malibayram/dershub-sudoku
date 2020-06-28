import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/renkler.dart';
import 'finished_puzzle.dart';

class ResultPage extends StatelessWidget {
  final FinishedPuzzle fs;

  const ResultPage({Key key, @required this.fs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.dhMavi.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("Tebrikler")),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Renk.petrolmavisi,
                  Renk.petrolmavisi,
                  Renk.forumRenkleri[12],
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 32.0),
                Center(
                  child: Text(
                    "Çözdünüz!",
                    style: GoogleFonts.courgette(
                      textStyle: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Renk.dkrem,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.0),
                Icon(
                  FontAwesomeIcons.thumbsUp,
                  color: Renk.beyaz,
                  size: 120,
                ),
                Spacer(),
                Text(
                  fs.level,
                  style: TextStyle(
                    fontSize: 30,
                    color: Renk.dkrem.withOpacity(0.5),
                  ),
                ),
                Text(
                  "${Duration(seconds: fs.time)}".split('.')[0],
                  style: TextStyle(
                    fontSize: 50,
                    color: Renk.dkrem.withOpacity(0.7),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "${fs.puan}",
                      style: TextStyle(
                        fontSize: 50,
                        color: Renk.beyaz,
                      ),
                    ),
                    Text(
                      " Puan",
                      style: TextStyle(
                        fontSize: 30,
                        color: Renk.dkrem.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
