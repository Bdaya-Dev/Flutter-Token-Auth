import 'dart:async';

import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';

import '../bdaya_token_auth.dart';

abstract class UserTokenRepoBase<TKey, T extends UserTokenBag<TKey>>
    extends ActiveRepo<TKey, T> {
  @override
  String get boxName => 'user_token';
  Future<T> requestNewTokenBag(T oldBag);

  Timer? _authTimer;
  Future<void> registerTokenBag(TKey userId, T tokenBag) async {
    tokenBag.fillFromAccessTokenJwt();
    await assignAll({userId: tokenBag});
  }

  StreamSubscription? _selfStream;
  void _initStream() {
    if (_selfStream != null) return;
    _selfStream = firstEntryStream(Duration(milliseconds: 200)).listen(
      (event) {
        _authTimer?.cancel();
        if (event == null || event.value.accessTokenExpireAt == null) {
          //no token bags == no users, do nothing
          _authTimer = null;
        } else {
          //there is a token bag, init timer
          _authTimer = Timer(
            event.value.accessTokenExpireAt!.difference(DateTime.now()).abs() +
                Duration(seconds: 10),
            initAuthLogic,
          );
        }
      },
    );
  }

  /// true if auth successful, false if not, null if no user exists
  Future<bool?> initAuthLogic() async {
    _initStream();
    final MapEntry<TKey, T>? entry = this.firstOrNull;
    if (entry == null) return null;
    final userId = entry.key;
    final bag = entry.value;
    if (!bag.isValid || !await extraValidation(userId, bag)) {
      //token bag expired
      if (bag.refreshToken == null) {
        //no refresh token
        return false;
      } else {
        try {
          final token = await requestNewTokenBag(bag);
          await registerTokenBag(userId, token);
          return true;
        } catch (e) {
          await clear();
          return false;
        }
      }
    }
    return true;
  }

  /// override this if you want to do extra validation on the token bag after checking its expiration date
  Future<bool> extraValidation(TKey userId, T bag) => Future.value(true);

  UserTokenRepoBase();

  Future<void> dispose() async {
    await _selfStream?.cancel();
  }
}
