import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';

@HiveType(typeId: 255)
class UserTokenBag extends GuidHiveObject {
  @HiveField(0)
  String accessToken;
  @HiveField(1)
  DateTime accessTokenIssuedAt;
  @HiveField(2)
  DateTime accessTokenExpireAt;

  @HiveField(3)
  String refreshToken;
  @HiveField(4)
  DateTime refreshTokenIssuedAt;
  @HiveField(5)
  DateTime refreshTokenExpireAt;
}
