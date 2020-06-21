import 'package:hive/hive.dart';

part 'finished_puzzle.g.dart';

//flutter packages pub run build_runner build

@HiveType(typeId: 1)
class FinishedPuzzle {
  @HiveField(0)
  String sudokustring;
  @HiveField(1)
  List sudokuHistory;
  @HiveField(2)
  String unsolved;
  @HiveField(3)
  String solved;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  int time;
  @HiveField(6)
  int puan;
  @HiveField(7)
  String level;

  FinishedPuzzle({
    this.sudokustring,
    this.sudokuHistory,
    this.unsolved,
    this.solved,
    this.date,
    this.time,
    this.puan,
    this.level,
  });

  FinishedPuzzle.fromJson(Map<String, dynamic> json) {
    sudokustring = json['sudokustring'];
    sudokuHistory = json['sudokuHistory'];
    unsolved = json['unsolved'];
    solved = json['solved'];
    date = json['date'];
    time = json['time'];
    puan = json['puan'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sudokustring'] = this.sudokustring;
    data['sudokuHistory'] = this.sudokuHistory;
    data['unsolved'] = this.unsolved;
    data['solved'] = this.solved;
    data['date'] = this.date;
    data['time'] = this.time;
    data['puan'] = this.puan;
    data['level'] = this.level;
    return data;
  }
}
