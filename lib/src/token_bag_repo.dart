import 'dart:async';

import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';

import '../bdaya_token_auth.dart';

abstract class UserTokenRepoBase<T extends UserTokenBag>
    extends ActiveRepo<String, T> {
  @override
  String get boxName => 'user_token';
  final Future<T> Function(T oldBag) requestNewTokenBag;
  Timer _authTimer;
  Future<void> registerTokenBag(String userId, T tokenBag) async {
    tokenBag.fillFromAccessTokenJwt();
    await assignAll({userId: tokenBag});
  }

  StreamSubscription _selfStream;
  void _initStream() {
    if (_selfStream != null) return;
    _selfStream = firstEntryStream(Duration(milliseconds: 200)).listen(
      (event) {
        _authTimer?.cancel();
        if (event == null) {
          //no token bags == no users, do nothing
          _authTimer = null;
        } else {
          //there is a token bag, init timer
          _authTimer = Timer(
            event.value.accessTokenExpireAt.difference(DateTime.now()).abs() +
                Duration(seconds: 10),
            initAuthLogic,
          );
        }
      },
    );
  }

  /// true if auth successful, false if not, null if no user exists
  Future<bool> initAuthLogic() async {
    _initStream();
    final entry = this.firstOrNull;
    if (entry == null) return null;
    final userId = entry.key;
    final bag = entry.value;
    if (!bag.isValid) {
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

  UserTokenRepoBase(this.requestNewTokenBag);

  Future<void> dispose() async {
    await _selfStream?.cancel();
  }
}
