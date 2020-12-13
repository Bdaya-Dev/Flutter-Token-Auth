import 'dart:async';

import 'package:bdaya_flutter_token_auth/src/token_bag.dart';
import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';

import 'access_token.dart';

class UserTokenRepo extends ActiveRepo<String, UserTokenBag> {
  @override
  String get boxName => 'user_token';
  final Future<AccessToken> Function(String accessToken, String refreshToken)
      requestTokenRefresh;
  final Future<void> Function(UserTokenBag tokenBag) handleNewTokenBag;
  final Future<void> Function() requestUserRelogin;

  final Duration accessTokenRecheckInterval;
  Future<void> registerTokenBag(
    String userId, {
    String accessToken,
    DateTime accessTokenIssuedAt,
    DateTime accessTokenExpireAt,
    String refreshToken,
    DateTime refreshTokenIssuedAt,
    DateTime refreshTokenExpireAt,
  }) async {
    await dataBox.put(
      userId,
      UserTokenBag()
        ..accessToken = accessToken
        ..accessTokenExpireAt = accessTokenExpireAt
        ..accessTokenIssuedAt = accessTokenIssuedAt
        ..refreshToken = refreshToken
        ..refreshTokenExpireAt = refreshTokenExpireAt
        ..refreshTokenIssuedAt = refreshTokenIssuedAt,
    );
  }

  Future<void> logoutUser(String userId) async {
    await deleteKeys([userId]);
  }

  UserTokenRepo(
    this.requestTokenRefresh, {
    this.handleNewTokenBag,
    this.requestUserRelogin,
    this.accessTokenRecheckInterval = const Duration(minutes: 5),
  }) {
    Timer.periodic(
      accessTokenRecheckInterval,
      (timer) async {
        final vals = getAllValues().entries;
        for (var userEntry in vals) {
          final userId = userEntry.key;
          final bag = userEntry.value;
          if (bag.accessTokenExpireAt.isAfter(DateTime.now())) {
            //access token is expired
            if (bag.refreshTokenExpireAt.isBefore(DateTime.now())) {
              //refresh token is expired
              try {
                final res = await requestTokenRefresh(
                  bag.accessToken,
                  bag.refreshToken,
                );
                await dataBox.put(userId, res);
                handleNewTokenBag?.call(res);
              } catch (e) {
                if (requestUserRelogin != null) {
                  await requestUserRelogin();
                }
              }
            } else {
              if (requestUserRelogin != null) {
                await requestUserRelogin();
              }
            }
          }
        }
      },
    );
  }
}
