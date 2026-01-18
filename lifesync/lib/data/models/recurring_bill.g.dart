// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringBillModelAdapter extends TypeAdapter<RecurringBillModel> {
  @override
  final int typeId = 12;

  @override
  RecurringBillModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringBillModel(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      categoryId: fields[3] as String,
      frequency: fields[4] as BillFrequency,
      dayOfMonth: fields[5] as int,
      nextDueDate: fields[6] as DateTime?,
      autoAdd: fields[7] as bool,
      reminderEnabled: fields[8] as bool,
      reminderDaysBefore: fields[9] as int,
      notes: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      isActive: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringBillModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.dayOfMonth)
      ..writeByte(6)
      ..write(obj.nextDueDate)
      ..writeByte(7)
      ..write(obj.autoAdd)
      ..writeByte(8)
      ..write(obj.reminderEnabled)
      ..writeByte(9)
      ..write(obj.reminderDaysBefore)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringBillModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillFrequencyAdapter extends TypeAdapter<BillFrequency> {
  @override
  final int typeId = 13;

  @override
  BillFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillFrequency.weekly;
      case 1:
        return BillFrequency.monthly;
      case 2:
        return BillFrequency.quarterly;
      case 3:
        return BillFrequency.yearly;
      default:
        return BillFrequency.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, BillFrequency obj) {
    switch (obj) {
      case BillFrequency.weekly:
        writer.writeByte(0);
        break;
      case BillFrequency.monthly:
        writer.writeByte(1);
        break;
      case BillFrequency.quarterly:
        writer.writeByte(2);
        break;
      case BillFrequency.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
