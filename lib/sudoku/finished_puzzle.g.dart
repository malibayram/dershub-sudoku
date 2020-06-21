// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finished_puzzle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinishedPuzzleAdapter extends TypeAdapter<FinishedPuzzle> {
  @override
  final typeId = 1;

  @override
  FinishedPuzzle read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinishedPuzzle(
      sudokustring: fields[0] as String,
      sudokuHistory: fields[1] as List,
      unsolved: fields[2] as String,
      solved: fields[3] as String,
      date: fields[4] as DateTime,
      time: fields[5] as int,
      puan: fields[6] as int,
      level: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FinishedPuzzle obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sudokustring)
      ..writeByte(1)
      ..write(obj.sudokuHistory)
      ..writeByte(2)
      ..write(obj.unsolved)
      ..writeByte(3)
      ..write(obj.solved)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.puan)
      ..writeByte(7)
      ..write(obj.level);
  }
}
