import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../utils/fonksiyonlar.dart';
import '../utils/renkler.dart';
import 'finished_puzzle.dart';
import 'result_page.dart';
import 'show_second.dart';
import 'sudoku_board.dart';
import 'sudoku_list.dart';

class SudokuMain extends StatefulWidget {
  @override
  _SudokuMainState createState() => _SudokuMainState();
}

class _SudokuMainState extends State<SudokuMain> {
  final String tag = "_SudokuMainState";
  final Map _levels = {
    "Çok Kolay": 62,
    "Kolay": 53,
    "Orta": 44,
    "Zor": 35,
    "Çok Zor": 26,
    "Yıpratıcı": 17,
  };
  final Box _kutu = Hive.box('Sudoku');
  StreamSubscription<List<PurchaseDetails>> _subscription;

  Timer _timer;

  String _sudokuString;
  List<dynamic> _sudoku = [], _sudokuBoxes = [], _sudokuCols = [], _sudokuHistory = [];

  bool _note = false, _pause = false;

  Future _reklamIzle() async {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: <String>['bilgisayar', 'oyun', 'bulmaca'],
      contentUrl: 'https://dershub.com/oyun/sudoku',
      childDirected: false,
      testDevices: <String>[],
    );

    // izleme => ca-app-pub-6288838616447002/6577912952
    String adiOSUnit = "ca-app-pub-6288838616447002/6991304900";
    String adAndroidUnit = "ca-app-pub-6288838616447002/7073165572";
    bool tryAgain = false;

    await RewardedVideoAd.instance
        .load(adUnitId: Platform.isIOS ? adiOSUnit : adAndroidUnit, targetingInfo: targetingInfo);

    try {
      await RewardedVideoAd.instance.show();
    } on PlatformException catch (e) {
      tryAgain = true;
      print(e.message);
    }

    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      switch (event) {
        case RewardedVideoAdEvent.rewarded:
          _kutu.put('ipucu', _kutu.get('ipucu') + 2);
          Fluttertoast.showToast(
            msg: "Tebrikler 2 ipucu kazandınız. İpucları profinize tanımlandı istediğiniz zaman kullanabilirsiniz.",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
          );
          break;

        case RewardedVideoAdEvent.loaded:
          if (tryAgain) {
            RewardedVideoAd.instance.show();
            Navigator.pop(context);
          }
          break;

        default:
          print(event.toString());
          break;
      }
    };
  }

  void _ipucuBul() {
    showDialog(
      context: context,
      builder: (context) {
        bool isleniyor = false;
        return StatefulBuilder(
          builder: (context, setstate) {
            if (isleniyor)
              return Center(child: CircularProgressIndicator());
            else
              return AlertDialog(
                title: Text("İpucu hakkınız bitmiş :("),
                content: Text(
                  "Yeni ipucu istiyorsanız. Size iki teklifimiz var. Kısa bir Reklam izleyerek 2 ipucu kazanabilirsiniz. Veya 7 TL karşılığında 200 ipucu ve 200 İzleme hakkı satın alarak dilediğiniz gibi kullanabilirsiniz.",
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      setstate(() => isleniyor = true);
                      _reklamIzle();
                    },
                    child: Text("Reklam izle"),
                  ),
                  FlatButton(
                    onPressed: () {
                      _loadingProductsForSale();
                      Navigator.pop(context);
                    },
                    child: Text("Satın al"),
                  ),
                  FlatButton(textColor: Renk.gKirmizi, onPressed: () => Navigator.pop(context), child: Text("Vazgeç")),
                ],
              );
          },
        );
      },
    );
  }

  void _pauseResume() {
    if (_timer == null) {
      _pause = false;
      _timer = Timer.periodic(Duration(seconds: 1), (callback) {
        int sure = _kutu.get('sure', defaultValue: 0);
        _kutu.put('sure', ++sure);
      });
    } else {
      _timer.cancel();
      _timer = null;
      _pause = true;
    }
    setState(() {});
  }

  void _sudokuOlustur() {
    if (_kutu.get('resume', defaultValue: false)) {
      _sudokuString = _kutu.get('sudokustring');
      _sudoku = _kutu.get('sudoku');
      _sudokuHistory = _kutu.get('sudokuHistory', defaultValue: []);
    } else {
      _sudokuString = sudokular[Random().nextInt(sudokular.length)];

      _sudoku = List.generate(
        9,
        (i) => _sudokuString.substring(i * 9, (i + 1) * 9).split('').map((e) => "s$e").toList(),
      );

      int i = 0;
      while (i < 81 - _levels[_kutu.get('level', defaultValue: 'Kolay')]) {
        int rx = Random().nextInt(9);
        int ry = Random().nextInt(9);

        if (_sudoku[rx][ry] != '0') {
          _sudoku[rx][ry] = '0';
          i++;
        }
      }

      _kutu.put('sudokustring', _sudokuString);
      _kutu.put('sure', 0);
      _kutu.put('ipucu', Fnks.uye.jetonlar['sudoku_ipucu'] ?? 5);
      _kutu.put('xy', "99");
      _kutu.put('sudokuHistory', _sudokuHistory);
    }

    _pauseResume();

    _makeColsAndBox();
  }

  void _makeColsAndBox() {
    _sudokuBoxes.clear();
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        _sudokuBoxes.add([
          ..._sudoku[i * 3].getRange(j * 3, (j + 1) * 3),
          ..._sudoku[i * 3 + 1].getRange(j * 3, (j + 1) * 3),
          ..._sudoku[i * 3 + 2].getRange(j * 3, (j + 1) * 3),
        ]);

    _sudokuCols = List.generate(9, (i) => List.generate(9, (j) => "${_sudoku[j][i]}"));

    _kutu.put('sudokuBoxes', _sudokuBoxes);
    _kutu.put('sudokuCols', _sudokuCols);
    _kutu.put('sudoku', _sudoku);

                                      /// Buradaki karşılaştırma işlemi daha önce List nesnesi üzeinden yapılınca her zaman true oluyordu.
                                      /// Çünkü iki listedeki elemanların aynı olması iki listeyi eşit yapmıyor.
                                      /// Bu yüzden ikisini de string olarak karşılaştırmak gerekti.
    if (_sudokuHistory.length == 0 || jsonEncode(jsonDecode(_sudokuHistory.last)['sudoku']) != jsonEncode(_sudoku)) {
      Map historyItem = {
        'sudoku': _sudoku,
        'xy': _kutu.get('xy', defaultValue: "99"),
        'sure': _kutu.get('sure', defaultValue: 0),
        'ipucu': _kutu.get('ipucu', defaultValue: 3),
      };

      _sudokuHistory.add(jsonEncode(historyItem));

      _kutu.put('sudokuHistory', _sudokuHistory);
    }

    List pureList = _sudoku.map((e) => e.toString().replaceAll(RegExp(r'[s, ]'), '')).toList();

    int hintCount = pureList.where((t) => t.length > 15).length;

    if (hintCount == 0 &&
        !_sudoku.toString().contains("0") &&
        pureList.toString().replaceAll(RegExp(r'[[, \]]'), '') == _sudokuString) _finishSudoku();

    _kutu.put('resume', true);
  }

  Future<void> _finishSudoku() async {
    setState(() => _pause = true);

    Box<FinishedPuzzle> finishedPuzzles = await Hive.openBox<FinishedPuzzle>('finishedPuzzles');

    int puan = (1500 - _kutu.get('sure')) +
        ((81 - RegExp("s").allMatches(jsonDecode(_sudokuHistory.first)['sudoku'].toString()).length) * 200) +
        ((_kutu.get('ipucu') % 4) * 300);

    FinishedPuzzle finishedPuzzle = FinishedPuzzle(
      sudokustring: _sudokuString,
      sudokuHistory: _sudokuHistory,
      unsolved: jsonEncode(jsonDecode(_sudokuHistory.first)['sudoku']),
      solved: jsonEncode(_sudoku),
      date: DateTime.now(),
      time: _kutu.get('sure'),
      puan: puan,
      level: _kutu.get('level'),
    );

    finishedPuzzles.add(finishedPuzzle);
    if (_timer != null) _timer.cancel();
    _kutu.put('resume', false);

    finishedPuzzles.compact();

    Firestore.instance.collection('finishedPuzzles').add({
      'oynayan': Fnks.uye.uid,
      'sudokustring': _sudokuString,
      'sudokuHistory': _sudokuHistory,
      'unsolved': jsonEncode(jsonDecode(_sudokuHistory.first)['sudoku']),
      'solved': jsonEncode(_sudoku),
      'date': Timestamp.now(),
      'serverdate': FieldValue.serverTimestamp(),
      'time': _kutu.get('sure'),
      'puan': puan,
      'level': _kutu.get('level'),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultPage(fs: finishedPuzzle)),
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> pList) {
    for (PurchaseDetails p in pList) {
      switch (p.status) {
        case PurchaseStatus.purchased:
          _kutu.put('izleme', _kutu.get('izleme', defaultValue: 0) + 200);
          _kutu.put('ipucu', _kutu.get('ipucu', defaultValue: 0) + 200);
          Firestore.instance.collection('oyunlar').document('sudoku').collection('succedPurchases').add({
            "kullanici_id": Fnks.uye.uid,
            "islem_zamani_server": FieldValue.serverTimestamp(),
            "islem_zamani_phone": Timestamp.now(),
            "transactionDate": "${p.transactionDate}",
            "verificationData": "${p.verificationData}",
            "status": "${p.status}",
            "purchaseID": "${p.purchaseID}",
            "p": "${p.toString()}",
            "billingClientPurchase": "${p.billingClientPurchase.toString()}",
          }).then((dr) => print(dr.documentID));
          Fluttertoast.showToast(
            msg:
                "Teşekkür ederiz. 200 izleme hakkı ve 200 ipucu aldınız. Haklar profinize tanımlandı istediğiniz zaman kullanabilirsiniz.",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
          );
          break;
        case PurchaseStatus.pending:
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text("Ödemeniz bekleme durumunda"),
                content: Text(
                  "İşlem başarıyla tamamlandığında haklarınız profilinize tanımlanacaktır. Herhangi bir sorun durumunda gerekli ekran görüntüleri ve belgeleri de ekleyerek hubders@gmail.com 'a mail atmaktan çekinmeyin.",
                ),
                actions: <Widget>[
                  FlatButton(onPressed: () => Navigator.pop(context), child: Text("Tamam")),
                ],
              );
            },
          );
          break;
        case PurchaseStatus.error:
          Firestore.instance.collection('oyunlar').document('sudoku').collection('failedPurchases').add({
            "kullanici_id": Fnks.uye.uid,
            "islem_zamani_server": FieldValue.serverTimestamp(),
            "islem_zamani_phone": Timestamp.now(),
            "hata_kodu": "${p.error.code}",
            "hata_mesajı": "${p.error.message}",
            "hata_kaynağı": "${p.error.source.index}",
            "ek": "${p.error.details}",
          });

          if (p.error.message == "BillingResponse.itemAlreadyOwned") {
            _kutu.put('izleme', _kutu.get('izleme', defaultValue: 0) + 200);
            _kutu.put('ipucu', _kutu.get('ipucu', defaultValue: 0) + 200);
            Fluttertoast.showToast(
              msg:
                  "Teşekkür ederiz. 200 izleme hakkı ve 200 ipucu aldınız. Haklar profinize tanımlandı istediğiniz zaman kullanabilirsiniz.",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 3,
            );
          }

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text("Ödeme işleminde hata oluştu"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Hata kodu: ${p.error.code}"),
                      Text("Hata mesajı: ${p.error.message}"),
                      Text("Hata kaynağı: ${p.error.source.index}"),
                      Text("Ek: ${p.error.details}"),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(onPressed: () => Navigator.pop(context), child: Text("Tamam")),
                ],
              );
            },
          );
          break;
        default:
          break;
      }
    }
  }

  Future<void> _loadingProductsForSale() async {
    final bool available = await InAppPurchaseConnection.instance.isAvailable();
    print("bool _loadingProductsForSale");
    if (!available) {
      Fluttertoast.showToast(
        msg: "Maalesef satın alma aktif değil. Daha sonra tekrar deneyebilirsiniz.",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
      );
      print("false _loadingProductsForSale");
    } else {
      print("true _loadingProductsForSale");
      // Set literals require Dart 2.2. Alternatively, use `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
      const Set<String> _kIds = {'sudoku_ipucu'};
      final ProductDetailsResponse response = await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        Fluttertoast.showToast(
          msg: "Maalesef satın alma kimliği bulunamadı. Daha sonra tekrar deneyebilirsiniz.",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
        );
        print("true esponse.notFoundIDs.isNotEmpty");
      }
      List<ProductDetails> products = response.productDetails;
      for (ProductDetails p in products.take(1)) {
        print(p.title);
        print(p.price);
        final PurchaseParam purchaseParam = PurchaseParam(productDetails: p);
        /* if (_isConsumable(productDetails)) {
          InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);
        } else {
          InAppPurchaseConnection.instance.buyNonConsumable(purchaseParam: purchaseParam);
        } */
        bool sonuc = await InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);
        print("buyConsumable: $sonuc");
      }
    }
  }

  @override
  void initState() {
    InAppPurchaseConnection.enablePendingPurchases();
    final Stream<List<PurchaseDetails>> purchaseUpdates = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
    _sudokuOlustur();
    // The following line will enable the Android and iOS wakelock.
    Wakelock.enable();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    _subscription.cancel();

    // The next line disables the wakelock again.
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.gKirmizi.withOpacity(0.65),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: ValueListenableBuilder<Box>(
              valueListenable: _kutu.listenable(keys: ['sure']),
              builder: (context, box, widget) {
                List<String> _a = "${Duration(seconds: box.get('sure'))}".split('.')[0].split(':');
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ShowSecond(_a[0], box.get('sure') > 60 && _a[1] == "00"),
                    Text(":"),
                    ShowSecond(_a[1], _a[2] == "00"),
                    Text(":"),
                    ShowSecond(_a[2], !_pause),
                  ],
                );
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  _pause ? Icons.play_circle_outline : Icons.pause_circle_outline,
                ),
                onPressed: _pauseResume,
              ),
            ],
          ),
          backgroundColor: Renk.forumRenkleri[12],
          body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: 18.0),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      width: double.maxFinite,
                      color: Renk.dkrem,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          color: Renk.gmavi,
                          child: ValueListenableBuilder<Box>(
                            valueListenable: _kutu.listenable(keys: ['sudoku', 'xy']),
                            builder: (context, box, _) {
                              List _sudoku = box.get('sudoku');
                              List _sudokuCols = box.get('sudokuCols');
                              List _sudokuBoxes = box.get('sudokuBoxes');

                              int _xC = int.tryParse(box.get('xy', defaultValue: "99")[0]),
                                  _yC = int.tryParse(box.get('xy', defaultValue: "99")[1]);

                              return SudokuBoard(
                                xC: _xC,
                                yC: _yC,
                                sudoku: _sudoku,
                                sudokuCols: _sudokuCols,
                                sudokuBoxes: _sudokuBoxes,
                                changeXY: (String xy) => box.put('xy', xy),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Card(
                                                color: Renk.dkrem,
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      int _xC = int.tryParse(_kutu.get('xy', defaultValue: "99")[0]),
                                                          _yC = int.tryParse(_kutu.get('xy', defaultValue: "99")[1]);
                                                      if (_xC < 9) {
                                                        _sudoku[_xC][_yC] = "0";
                                                        _makeColsAndBox();
                                                      }
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(Icons.delete),
                                                        Text(
                                                          "Sil",
                                                          style: GoogleFonts.courgette(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Card(
                                                color: Renk.dkrem,
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (_sudokuHistory.length > 1) {
                                                        _sudokuHistory.removeLast();
                                                        _sudoku = jsonDecode(_sudokuHistory.last)['sudoku'];
                                                        _makeColsAndBox();
                                                      }
                                                      print(_sudokuHistory.length);
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(Icons.replay),
                                                        Text(
                                                          "Geri al",
                                                          style: GoogleFonts.courgette(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
                                                color: _note ? Renk.gGri9 : Renk.dkrem,
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() => _note = !_note);
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          "Not",
                                                          style: GoogleFonts.courgette(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Card(
                                                color: Renk.dkrem,
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      int ipucu = _kutu.get('ipucu', defaultValue: 0);
                                                      if (ipucu > 0) {
                                                        int _xC = int.tryParse(_kutu.get('xy', defaultValue: "99")[0]),
                                                            _yC = int.tryParse(_kutu.get('xy', defaultValue: "99")[1]);
                                                        if (_xC < 9) {
                                                          print("$_xC]$_yC]");
                                                          List cozum = List.generate(
                                                            9,
                                                            (i) => _sudokuString
                                                                .substring(i * 9, (i + 1) * 9)
                                                                .split('')
                                                                .map((e) => "$e")
                                                                .toList(),
                                                          );

                                                          if (_sudoku[_xC][_yC] != cozum[_xC][_yC]) {
                                                            _sudoku[_xC][_yC] = cozum[_xC][_yC];
                                                            _makeColsAndBox();
                                                            _kutu.put('ipucu', ipucu - 1);
                                                          }
                                                        }
                                                      } else
                                                        _ipucuBul();
                                                    },
                                                    child: ValueListenableBuilder<Box>(
                                                      valueListenable: _kutu.listenable(keys: ['ipucu', 'izleme']),
                                                      builder: (context, box, _) {
                                                        int izleme = box.get('izleme', defaultValue: 0);
                                                        int ipucu = box.get('ipucu', defaultValue: 0);
                                                        if (Fnks.uye.jetonlar['sudoku_ipucu'] != ipucu) {
                                                          Fnks.uye.jetonlar['sudoku_izleme'] = izleme;
                                                          Fnks.uye.jetonlar['sudoku_ipucu'] = ipucu;

                                                          print(Fnks.uye.uid);

                                                          Hive.box('ayarlar').put('uye', Fnks.uye.toMap());

                                                          Firestore.instance
                                                              .collection('uyeler')
                                                              .document(Fnks.uye.uid)
                                                              .updateData({'jetonlar': Fnks.uye.jetonlar});
                                                        }

                                                        return Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: <Widget>[
                                                                Icon(
                                                                  ipucu > 0
                                                                      ? Icons.lightbulb_outline
                                                                      : FontAwesomeIcons.magic,
                                                                ),
                                                                Text(ipucu > 0 ? "$ipucu" : " Bul"),
                                                              ],
                                                            ),
                                                            Text(
                                                              "İpucu",
                                                              style: GoogleFonts.courgette(),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
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
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Column(
                                  children: <Widget>[
                                    for (int i = 1; i < 10; i += 3)
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            for (int i2 = 0; i2 < 3; i2++)
                                              Expanded(
                                                child: AspectRatio(
                                                  aspectRatio: 1,
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        color: Renk.beyaz,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius: BorderRadius.circular(
                                                        100,
                                                      ),
                                                    ),
                                                    color: Renk.dkrem,
                                                    child: MaterialButton(
                                                      padding: EdgeInsets.all(0),
                                                      onPressed: () {
                                                        int _xC = int.tryParse(_kutu.get('xy', defaultValue: "99")[0]),
                                                            _yC = int.tryParse(_kutu.get('xy', defaultValue: "99")[1]);
                                                        if (_xC < 9) {
                                                          if (_note) {
                                                            String c = _sudoku[_xC][_yC].toString();
                                                            if (c.length < 8) c = "000000000";

                                                            _sudoku[_xC][_yC] = c.replaceRange((i + i2) - 1, (i + i2),
                                                                c.contains("${i + i2}") ? "0" : "${i + i2}");
                                                            print(c);
                                                          } else
                                                            _sudoku[_xC][_yC] = "${i + i2}";

                                                          _makeColsAndBox();
                                                        }
                                                      },
                                                      child: Text(
                                                        "${i + i2}",
                                                        style: TextStyle(
                                                          fontSize: 28,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_pause)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
