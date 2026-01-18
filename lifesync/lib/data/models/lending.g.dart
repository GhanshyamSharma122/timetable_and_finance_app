// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lending.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LendingModelAdapter extends TypeAdapter<LendingModel> {
  @override
  final int typeId = 7;

  @override
  LendingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LendingModel(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as LendingType,
      date: fields[4] as DateTime,
      dueDate: fields[5] as DateTime?,
      notes: fields[6] as String?,
      status: fields[7] as LendingStatus,
      createdAt: fields[8] as DateTime,
      settledAt: fields[9] as DateTime?,
      phoneNumber: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LendingModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.settledAt)
      ..writeByte(10)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LendingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LendingTypeAdapter extends TypeAdapter<LendingType> {
  @override
  final int typeId = 8;

  @override
  LendingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LendingType.borrowed;
      case 1:
        return LendingType.lent;
      default:
        return LendingType.borrowed;
    }
  }

  @override
  void write(BinaryWriter writer, LendingType obj) {
    switch (obj) {
      case LendingType.borrowed:
        writer.writeByte(0);
        break;
      case LendingType.lent:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LendingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LendingStatusAdapter extends TypeAdapter<LendingStatus> {
  @override
  final int typeId = 9;

  @override
  LendingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LendingStatus.pending;
      case 1:
        return LendingStatus.paid;
      default:
        return LendingStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, LendingStatus obj) {
    switch (obj) {
      case LendingStatus.pending:
        writer.writeByte(0);
        break;
      case LendingStatus.paid:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LendingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
