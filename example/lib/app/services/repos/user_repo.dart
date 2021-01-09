import 'package:bdaya_token_auth/bdaya_token_auth.dart';
import 'package:bearer_example/app/data/user_model.dart';

Future<UserModel> requestNewTokenBag(UserModel userModel) async {
  //TODO: call api here to refresh token bag based on old token
  return userModel;
}

class UserRepo extends UserTokenRepoBase<UserModel> {
  UserRepo() : super(requestNewTokenBag);
}
