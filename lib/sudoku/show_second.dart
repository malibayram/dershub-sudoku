import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/material.dart';

import '../utils/renkler.dart';

class ShowSecond extends StatelessWidget {
  final String sayi;
  final bool anime;

  const ShowSecond(this.sayi, this.anime);
  @override
  Widget build(BuildContext context) {
    if (anime)
      return FlipPanel.builder(
        itemsCount: 1,
        period: Duration(seconds: 1),
        loop: 1,
        spacing: 1.0,
        itemBuilder: (context, index) {
          return Card(
            color: Renk.dkrem,
            child: SizedBox(
              width: 45.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "$sayi",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Renk.gKirmizi,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    else
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.5,
              child: Card(
                color: Renk.dkrem,
                child: SizedBox(
                  width: 45.0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "$sayi",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Renk.gKirmizi,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.0),
          ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.5,
              child: Card(
                color: Renk.dkrem,
                child: SizedBox(
                  width: 45.0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "$sayi",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Renk.gKirmizi,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
  }
}
