import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:corsac_jwt/corsac_jwt.dart';

abstract class UserTokenBag extends GuidHiveObject {
  String get accessToken;
  set accessToken(String accessToken);

  DateTime get accessTokenExpireAt;
  set accessTokenExpireAt(DateTime accessTokenExpireAt);

  String get refreshToken;
  set refreshToken(String refreshToken);

  JWT _cacheAccessToken;
  JWT get accessTokenParsed {
    if (_cacheAccessToken?.toString() != accessToken) {
      _cacheAccessToken = JWT.parse(accessToken);
    }
    return _cacheAccessToken;
  }

  void fillFromAccessTokenJwt() {
    if (accessToken == null) return;
    final parsed = JWT.parse(accessToken);
    accessTokenExpireAt =
        DateTime.fromMillisecondsSinceEpoch(parsed.expiresAt * 1000);
  }

  bool get isValid => accessTokenExpireAt?.isBefore(DateTime.now()) ?? false;
}
