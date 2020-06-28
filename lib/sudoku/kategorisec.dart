import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sudoku/login/login.dart';

import '../utils/fonksiyonlar.dart';
import 'finished_puzzle.dart';
import 'sudoku_main.dart';
import 'sudoku_replay.dart';
import '../utils/renkler.dart';

class KategoriSec extends StatefulWidget {
  @override
  _KategoriSecState createState() => _KategoriSecState();
}

class _KategoriSecState extends State<KategoriSec> {
  final List<String> _levels = ["Çok Kolay", "Kolay", "Orta", "Zor", "Çok Zor", "Yıpratıcı"];
  StreamSubscription<List<PurchaseDetails>> _subscription;

  Box _boxSudoku;
  Box<FinishedPuzzle> _boxfinishedPuzzles;

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
          _boxSudoku.put('izleme', _boxSudoku.get('izleme', defaultValue: 0) + 2);
          Fluttertoast.showToast(
            msg:
                "Tebrikler 2 izleme hakkı kazandınız. İzleme hakları profinize tanımlandı istediğiniz zaman kullanabilirsiniz.",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 3,
          );
          break;

        case RewardedVideoAdEvent.loaded:
          print("object RewardedVideoAdEvent.loaded");
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

  void _izlemeHakkiBul() {
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
                title: Text("Tekrar izleme hakkınız bitmiş :("),
                content: Text(
                  "Yeni izleme hakkı istiyorsanız. Size iki teklifimiz var. Kısa bir Reklam izleyerek 2 izleme hakkı kazanabilirsiniz. Veya 7 TL karşılığında 200 izleme ve 200 ipucu hakkı satın alarak dilediğiniz gibi kullanabilirsiniz.",
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

  void _showResumeAlert(String seviye) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Devam Eden Sudoku Var"),
          content: Text(
            "Daha önce açtığınız ve devam edebileceğiniz aktif bir sudokunuz var. Yeni sudoku oluşturmanız durumunda önceki sudoku silinecektir. Yeni sudoku açmak istedğinizden emin misiniz?",
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
                _newPuzzle();
              },
              child: Text(
                "Önceki Sudokuyu Aç",
                style: GoogleFonts.courgette(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Renk.yesil,
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                _boxSudoku.put('resume', false);
                _boxSudoku.put('level', seviye);
                Navigator.pop(context);
                _newPuzzle();
              },
              child: Text(
                "Yeni Sudoku Aç",
                style: GoogleFonts.courgette(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Renk.gKirmizi,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _newPuzzle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return SudokuMain();
        },
      ),
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> pList) {
    for (PurchaseDetails p in pList) {
      switch (p.status) {
        case PurchaseStatus.purchased:
          _boxSudoku.put('izleme', _boxSudoku.get('izleme', defaultValue: 0) + 200);
          _boxSudoku.put('ipucu', _boxSudoku.get('ipucu', defaultValue: 0) + 200);
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
          }).then((dr) => print(dr.documentID));

          if (p.error.message == "BillingResponse.itemAlreadyOwned") {
            _boxSudoku.put('izleme', _boxSudoku.get('izleme', defaultValue: 0) + 200);
            _boxSudoku.put('ipucu', _boxSudoku.get('ipucu', defaultValue: 0) + 200);
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
        try {
          bool sonuc = await InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);

          print("buyConsumable: $sonuc");
        } on PlatformException catch (e) {
          String error = "PlatformException code: ${e.code}, message: ${e.message}, details: ${e.details}";
          print(error);

          Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 3);
        } catch (e) {
          String error = "catch error: ${e.toString()}";
          print(error);

          Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 3);
        }
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

    super.initState();
  }

  @override
  void dispose() {
    _boxSudoku.compact();

    _boxfinishedPuzzles.compact();

    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Renk.dhMavi.withOpacity(0.85),
      child: SafeArea(
        child: FutureBuilder<Box>(
          future: Hive.openBox('sudoku'),
          builder: (context, ss) {
            if (ss.connectionState == ConnectionState.done && ss.hasData) {
              _boxSudoku = ss.data;
              return Scaffold(
                appBar: AppBar(
                  leading: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:
                            NetworkImage(Fnks.uye.photoUrl ?? "https://image.flaticon.com/icons/png/512/16/16363.png"),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.grey[350], offset: Offset(0, 0), blurRadius: 15),
                      ],
                    ),
                  ),
                  title: Text(Fnks.uye.displayName ?? "Anonim"),
                  actions: <Widget>[
                    if (ss.data.length > 0)
                      HiveListener(
                        box: ss.data,
                        keys: ['resume'],
                        builder: (box) {
                          if (ss.data.get('resume', defaultValue: false))
                            return IconButton(
                              icon: Icon(Icons.play_circle_outline),
                              tooltip: "Devam",
                              onPressed: _newPuzzle,
                            );
                          else
                            return SizedBox();
                        },
                      ),
                    PopupMenuButton<String>(
                      onSelected: (String seviye) {
                        if (seviye == 'cikisYap')
                          signOut();
                        else if (ss.data.get('resume', defaultValue: false))
                          _showResumeAlert(seviye);
                        else {
                          ss.data.put('resume', false);
                          ss.data.put('level', seviye);
                          _newPuzzle();
                        }
                      },
                      tooltip: "Seviye Seçimi",
                      icon: Icon(Icons.add),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'Seviye Seçimi',
                          enabled: false,
                          child: Text(
                            "Seviye Seçimi",
                            style: TextStyle(
                              color: Renk.siyah,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuDivider(),
                        for (String level in _levels)
                          PopupMenuItem<String>(
                            value: level,
                            child: Text(level),
                          ),
                        PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'cikisYap',
                          textStyle: TextStyle(color: Renk.gKirmizi),
                          child: Text("Çıkış Yap"),
                        ),
                      ],
                    ),
                  ],
                ),
                backgroundColor: Renk.forumRenkleri[12],
                body: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      alignment: Alignment.center,
                      child: Text(
                        "Çözdükleriniz",
                        style: GoogleFonts.courgette(
                          textStyle: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Renk.dkrem,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(18.0),
                          child: FutureBuilder<Box<FinishedPuzzle>>(
                            future: Hive.openBox<FinishedPuzzle>('finishedPuzzles'),
                            builder: (context, sfp) {
                              if (sfp.connectionState == ConnectionState.done && sfp.hasData) {
                                _boxfinishedPuzzles = sfp.data;
                                return HiveListener(
                                    box: _boxfinishedPuzzles,
                                    builder: (box) {
                                      return ListView(
                                        children: <Widget>[
                                          if (box.isEmpty)
                                            Container(
                                              margin: EdgeInsets.all(16.0),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Henüz hiç sudoku çözmemişsiniz. Sağ üst köşedeki artı ikonundan yeni sudoku oluşturup hemen çözmeye başlayabilirsiniz",
                                                style: GoogleFonts.cabin(
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Renk.dkrem,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          for (FinishedPuzzle fp in box.values.toList().reversed.take(20))
                                            Card(
                                              child: ListTile(
                                                leading: SizedBox(
                                                  width: 74,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Text("Puan: "),
                                                          Text(
                                                            "${fp.puan}",
                                                            style: GoogleFonts.courgette(),
                                                          ),
                                                        ],
                                                      ),
                                                      Text("Seviye"),
                                                      Text(
                                                        fp.level,
                                                        style: GoogleFonts.courgette(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                title: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 42,
                                                          child: Text(
                                                            "Tarih: ",
                                                            style: TextStyle(fontSize: 14),
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat("dd/MM/yyyy", 'tr-TR').format(fp.date),
                                                          style: GoogleFonts.courgette(),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 42,
                                                          child: Text(
                                                            "Saat: ",
                                                            style: TextStyle(fontSize: 14),
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat("HH:mm:ss", 'tr-TR').format(fp.date),
                                                          style: GoogleFonts.courgette(),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 42,
                                                          child: Text(
                                                            "Süre: ",
                                                            style: TextStyle(fontSize: 14),
                                                          ),
                                                        ),
                                                        Text(
                                                          "${Duration(seconds: fp.time)}".split('.')[0],
                                                          style: GoogleFonts.courgette(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    int izleme = ss.data.get('izleme', defaultValue: 3);
                                                    if (izleme > 0)
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (_) {
                                                          ss.data.put('izleme', izleme - 1);
                                                          return SudokuReplay(fp: fp);
                                                        }),
                                                      );
                                                    else
                                                      _izlemeHakkiBul();
                                                  },
                                                  tooltip: "Tekrar İzle",
                                                  icon: Icon(Icons.queue_play_next),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    });
                              }
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ),
                    ),
                    if (ss.data.length > 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Tekrar İzleme Hakkı: ",
                              style: GoogleFonts.concertOne(
                                textStyle: TextStyle(
                                  color: Renk.beyaz,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            HiveListener(
                              box: ss.data,
                              keys: ['izleme'],
                              builder: (box) {
                                int izleme = box.get('izleme', defaultValue: 3);
                                int ipucu = box.get('ipucu', defaultValue: 3);
                                if (Fnks.uye.jetonlar['sudoku_izleme'] != izleme) {
                                  Fnks.uye.jetonlar['sudoku_izleme'] = izleme;
                                  Fnks.uye.jetonlar['sudoku_ipucu'] = ipucu;

                                  print(Fnks.uye.uid);

                                  Hive.box('ayarlar').put('uye', Fnks.uye.toMap());

                                  Firestore.instance.collection('uyeler').document(Fnks.uye.uid)
                                      //silme işlemi
                                      /* .delete(); */

                                      //guncelleme işlemi
                                      .updateData({'jetonlar': Fnks.uye.jetonlar});
                                }
                                return InkWell(
                                  onTap: izleme > 0 ? null : _izlemeHakkiBul,
                                  child: Text(
                                    izleme > 0 ? "$izleme" : "Bul",
                                    style: GoogleFonts.concertOne(
                                      textStyle: TextStyle(color: Renk.beyaz, fontSize: 24.0),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
