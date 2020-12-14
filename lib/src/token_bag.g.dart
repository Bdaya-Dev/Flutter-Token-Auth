// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_bag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserTokenBagAdapter extends TypeAdapter<UserTokenBag> {
  @override
  final int typeId = 222;

  @override
  UserTokenBag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserTokenBag()
      ..accessToken = fields[0] as String
      ..accessTokenIssuedAt = fields[1] as DateTime
      ..accessTokenExpireAt = fields[2] as DateTime
      ..refreshToken = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, UserTokenBag obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.accessTokenIssuedAt)
      ..writeByte(2)
      ..write(obj.accessTokenExpireAt)
      ..writeByte(3)
      ..write(obj.refreshToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTokenBagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
