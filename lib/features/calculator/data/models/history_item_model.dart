import 'package:hive/hive.dart';

/// Elite representation model of calculated items in persistent history caches.
@HiveType(typeId: 0)
class HistoryItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String expression;

  @HiveField(2)
  final String result;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String inputMethod; // 'manual', 'voice', 'handwriting', 'scanner'

  HistoryItemModel({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    required this.inputMethod,
  });
}

/// Custom Manual Hive Adapter to bypass any compilation requirements for build_runner.
/// Ensures the project compiles 100% instantly out of the box!
class HistoryItemModelAdapter extends TypeAdapter<HistoryItemModel> {
  @override
  final int typeId = 0;

  @override
  HistoryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItemModel(
      id: fields[0] as String,
      expression: fields[1] as String,
      result: fields[2] as String,
      timestamp: fields[3] as DateTime,
      inputMethod: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expression)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.inputMethod);
  }
}
