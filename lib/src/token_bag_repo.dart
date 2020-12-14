import 'dart:async';

import 'package:bdaya_flutter_token_auth/src/token_bag.dart';
import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:corsac_jwt/corsac_jwt.dart';

import 'access_token.dart';

class UserTokenRepo extends ActiveRepo<String, UserTokenBag> {
  @override
  String get boxName => 'user_token';
  final Future<String> Function(String accessToken, String refreshToken)
      requestNewAccessToken;
  final Future<void> Function(UserTokenBag tokenBag) handleNewTokenBag;
  final Future<void> Function() requestUserRelogin;

  final Duration accessTokenRecheckInterval;
  Future<void> registerTokenBag(
    String userId, {
    String accessToken,
    String refreshToken,
  }) async {
    final parsed = JWT.parse(accessToken);
    await dataBox.put(
        userId,
        UserTokenBag()
          ..accessToken = accessToken
          ..accessTokenExpireAt =
              DateTime.fromMillisecondsSinceEpoch(parsed.expiresAt * 1000)
          ..accessTokenIssuedAt =
              DateTime.fromMillisecondsSinceEpoch(parsed.issuedAt * 1000)
          ..refreshToken = refreshToken);
  }

  Future<void> logoutUser(String userId) async {
    await deleteKeys([userId]);
  }

  UserTokenRepo(
    this.requestNewAccessToken, {
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
            if (bag.refreshToken == null) {
              //no refresh token
              await requestUserRelogin?.call();
            } else {
              try {
                final token = await requestNewAccessToken(
                  bag.accessToken,
                  bag.refreshToken,
                );
                await registerTokenBag(
                  userId,
                  accessToken: token,
                  refreshToken: bag.refreshToken,
                );

                await handleNewTokenBag?.call(bag);
              } catch (e) {
                await requestUserRelogin?.call();
                await clear();
              }
            }
          }
        }
      },
    );
  }
}
