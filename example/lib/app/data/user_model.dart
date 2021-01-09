import 'package:bdaya_token_auth/bdaya_token_auth.dart';
import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends UserTokenBag {
  @HiveField(0)
  @override
  String accessToken;

  @HiveField(1)
  @override
  DateTime accessTokenExpireAt;

  @HiveField(2)
  @override
  String refreshToken;
}
