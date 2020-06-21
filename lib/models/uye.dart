import 'package:flutter/material.dart';

class Uye {
  String uid, displayName, email, photoUrl;

  Map jetonlar;

  Uye({
    @required this.uid,
    this.displayName,
    this.photoUrl,
    @required this.email,
    this.jetonlar = const {},
  });

  Uye.fromMap(Map veri)
      : this(
          uid: veri['uid'],
          displayName: veri['displayName'],
          photoUrl: veri['photoUrl'],
          email: veri['email'],
          jetonlar: veri['jetonlar'] ?? {},
        );

  Map<String, dynamic> toMap() => {
        'uid': this.uid,
        'displayName': this.displayName,
        'photoUrl': this.photoUrl,
        'email': this.email,
        'jetonlar': this.jetonlar ?? {},
      };
}
