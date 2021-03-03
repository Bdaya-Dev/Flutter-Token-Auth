import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:jose/jose.dart';

abstract class UserTokenBag<TKey> extends HiveObject {
  @override
  TKey get key => super.key;

  String? get accessToken;
  set accessToken(String? accessToken);

  DateTime? get accessTokenExpireAt;
  set accessTokenExpireAt(DateTime? accessTokenExpireAt);

  String? get refreshToken;
  set refreshToken(String? refreshToken);

  JsonWebToken? _cacheAccessToken;
  JsonWebToken? get accessTokenParsed {
    if (_cacheAccessToken?.toString() != accessToken && accessToken != null) {
      _cacheAccessToken = JsonWebToken.unverified(accessToken!);
    }
    return _cacheAccessToken;
  }

  void fillFromAccessTokenJwt() {
    if (accessToken == null) return;
    final parsed = JsonWebToken.unverified(accessToken!);

    accessTokenExpireAt = parsed.claims.expiry;
  }

  bool get isValid => accessTokenExpireAt?.isBefore(DateTime.now()) ?? false;
}
